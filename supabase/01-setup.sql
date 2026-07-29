-- ============================================================
-- PEDEJÁ TEMPLATE — schema base do delivery (v2.3)
-- Rodar no SQL Editor de um projeto Supabase NOVO. Idempotente.
-- Identidade (nome, cores, whatsapp, pix) fica na tabela config e é
-- lida pelo site via a view config_publica — não hardcode no HTML.
-- ============================================================

-- CARDÁPIO ----------------------------------------------------
create table if not exists categorias (
  id serial primary key, nome text not null unique, emoji text, sub text,
  ordem int default 0, ativa boolean default true, hora_ini time, hora_fim time
);
create table if not exists produtos (
  id serial primary key, categoria_id int references categorias(id) on delete cascade,
  nome text not null, descricao text, preco numeric(10,2),
  tamanhos jsonb, adicionais jsonb, opcoes jsonb,
  img text, selos text[],
  destaque boolean default false, ativo boolean default true,
  esgotado boolean default false, estoque int, custo numeric(10,2), ordem int default 0
);
create table if not exists bairros (
  id serial primary key, nome text not null unique, taxa numeric(10,2) not null, ativo boolean default true
);
-- ANÚNCIOS / BANNERS (faixa promocional no topo do cardápio, editável pela dona) ---
create table if not exists banners (
  id serial primary key, img text not null, titulo text, link text,
  ordem int default 0, ativo boolean default true, criado_em timestamptz default now()
);

-- PEDIDOS -----------------------------------------------------
create table if not exists pedidos (
  id uuid default gen_random_uuid() primary key,
  created_at timestamptz default now(),
  cliente text, telefone text, tipo text, bairro text,
  itens jsonb, subtotal numeric(10,2), taxa_entrega numeric(10,2) default 0,
  desconto numeric(10,2) default 0, cupom text,
  total numeric(10,2), pagamento text,
  localizacao text, referencia text, endereco text, obs text,
  origem text default 'cardapio', status text default 'recebido', agendado_para text, ip text
);
create index if not exists idx_pedidos_tel_data on pedidos (telefone, created_at);
create index if not exists idx_pedidos_created  on pedidos (created_at desc);
create index if not exists idx_pedidos_ip_data  on pedidos (ip, created_at);

-- CONFIG / IDENTIDADE / SEGURANÇA / MARKETING -----------------
create table if not exists config (
  id int primary key default 1, loja_aberta boolean default true,
  senha_hash text,
  cashback_pct numeric(5,2) default 0, cashback_dias int[] default '{}',
  pixel_meta text, ga4 text,
  nome text, tagline text, cidade text, emoji text, whatsapp text, pix text,
  pix_nome text, pix_cidade text,
  cor1 text, cor2 text, cor3 text, cor4 text, cor5 text
);
insert into config (id) values (1) on conflict (id) do nothing;

create table if not exists cupons (
  codigo text primary key, tipo text check (tipo in ('valor','pct')),
  valor numeric(10,2) not null, minimo numeric(10,2) default 0,
  validade date, limite_uso int, usados int default 0, ativo boolean default true
);
create table if not exists clientes (
  telefone text primary key, nome text, creditos numeric(10,2) default 0,
  pedidos int default 0, total_gasto numeric(12,2) default 0, ultimo_pedido timestamptz
);
create table if not exists login_tentativas ( ip text, quando timestamptz default now() );
create index if not exists idx_login_ip_quando on login_tentativas (ip, quando);
create table if not exists sessoes ( token_hash text primary key, expira timestamptz not null );

-- GESTÃO (caixa / despesas) -----------------------------------
create table if not exists caixa (
  id serial primary key, aberto_em timestamptz default now(), fechado_em timestamptz,
  valor_inicial numeric(10,2) default 0, valor_conferido numeric(10,2)
);
create table if not exists caixa_movimentos (
  id serial primary key, caixa_id int references caixa(id) on delete cascade,
  quando timestamptz default now(), tipo text check (tipo in ('entrada','saida','retirada')),
  valor numeric(10,2) not null, descricao text
);
create table if not exists despesas (
  id serial primary key, data date default current_date, categoria text,
  descricao text, valor numeric(10,2) not null, recorrente boolean default false
);

-- RLS ---------------------------------------------------------
alter table categorias enable row level security;
alter table produtos  enable row level security;
alter table bairros   enable row level security;
alter table banners   enable row level security;
alter table pedidos   enable row level security;
alter table config    enable row level security;
alter table cupons    enable row level security;
alter table clientes  enable row level security;
alter table login_tentativas enable row level security;
alter table sessoes   enable row level security;
alter table caixa     enable row level security;
alter table caixa_movimentos enable row level security;
alter table despesas  enable row level security;

drop policy if exists cat_pub  on categorias;
drop policy if exists prod_pub on produtos;
drop policy if exists bai_pub  on bairros;
drop policy if exists ban_pub on banners;
create policy cat_pub  on categorias for select using (ativa);
create policy prod_pub on produtos  for select using (ativo);
create policy bai_pub  on bairros   for select using (ativo);
create policy ban_pub  on banners   for select using (ativo);
-- pedidos/cupons/clientes/sessoes/caixa/despesas: sem policy pública -> só Edge Functions.

drop view if exists config_publica;
create view config_publica as
  select loja_aberta, cashback_pct, pixel_meta, ga4,
         nome, tagline, cidade, emoji, whatsapp, pix, pix_nome, pix_cidade,
         cor1, cor2, cor3, cor4, cor5
  from config where id=1;
grant select on config_publica to anon;

-- STORAGE: bucket público de fotos do cardápio --------------
insert into storage.buckets (id, name, public) values ('fotos','fotos', true)
on conflict (id) do update set public = true;

-- ============================================================
-- PRÓXIMOS PASSOS (por cliente):
-- 1) update config set nome='...', tagline='...', cidade='...', emoji='🍞',
--       whatsapp='5588999990000', pix='CHAVE', pix_nome='NOME RECEBEDOR',
--       pix_cidade='CIDADE', cor1='#...', cor2='#...', cor3='#...', cor4='#...', cor5='#...'
--    where id=1;
-- 2) Publicar as Edge Functions pedido e painel.
-- 3) Definir a 1ª senha via ação bootstrap_senha (só funciona com senha_hash null).
-- 4) Cadastrar categorias, produtos e bairros (pelo painel ou INSERT).
-- ============================================================
