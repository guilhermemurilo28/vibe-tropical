-- ============================================================
-- VIBE TROPICAL — Açaiteria (Aracati-CE)
-- Dados do cliente. Rodar DEPOIS do setup.sql (schema) no mesmo projeto.
-- Idempotente: limpa cardápio e recria. NÃO mexe em pedidos/clientes.
-- Preços reconstruídos do cardápio em PDF — confirmar os marcados com (?) no painel.
-- ============================================================

-- 1) IDENTIDADE / CONFIG ------------------------------------
update config set
  nome       = 'Vibe Tropical',
  tagline    = 'Açaí cremoso do seu jeito 💜',
  cidade     = 'Aracati - CE',
  emoji      = '🍧',
  whatsapp   = '5588981802611',
  pix        = '08498731690',
  pix_nome   = 'VIBE TROPICAL',      -- nome exibido no Pix copia-e-cola (confirmar recebedor)
  pix_cidade = 'ARACATI',
  cor1 = '#2A0050', cor2 = '#6B21A8', cor3 = '#1A0030', cor4 = '#F5C518', cor5 = '#D4A900'
where id = 1;

-- 2) LIMPAR CARDÁPIO ANTERIOR (mantém pedidos/clientes) ------
delete from produtos;
delete from categorias;
alter sequence if exists categorias_id_seq restart with 1;
alter sequence if exists produtos_id_seq   restart with 1;

-- 3) CATEGORIAS ---------------------------------------------
insert into categorias (nome, emoji, sub, ordem, ativa) values
  ('Monte seu Açaí', '🍧', 'Escolha o tamanho e capriche nos adicionais', 1, true),
  ('Copos Trufados', '🍫', 'Cremosos e irresistíveis', 2, true),
  ('Especiais',      '✨', 'Criações da casa', 3, true),
  ('Açaí na Garrafa','🍶', 'Prático pra levar — 500ml', 4, true);

-- Grupos de opções GRÁTIS (adicionais + coberturas) reutilizados no "Monte seu Açaí".
-- min/max são um chute razoável — ajuste as quantidades grátis no painel se precisar.
-- adicionais PAGOS: Nutella extra R$5, Creme extra R$5, Adicional variado R$3.

-- 4) MONTE SEU AÇAÍ ------------------------------------------
insert into produtos (categoria_id, nome, descricao, tamanhos, opcoes, adicionais, destaque, ordem, ativo)
values
(1, 'Açaí Tradicional',
 'Acompanha leite, banana e granola. Monte com adicionais e coberturas grátis.',
 '[{"nome":"400ml","preco":12.00},{"nome":"500ml","preco":15.00}]',
 '[{"titulo":"Adicionais grátis","min":0,"max":4,"itens":["Granola","Banana","Morango","Uva","Kiwi","Leite em pó","Creme de avelã","Leite condensado","Ovomaltine","Marshmallow","Gotas de chocolate","Paçoca","Canudinho","Brigadeiro de chocolate","Brigadeiro de beijinho","Brownie","KitKat","Bis","Granulado","Farinha láctea","Amendoim","Choco Power","Micro Ball","Jujuba","Cereja","Oreo","M&M","Creme de cookies"]},
   {"titulo":"Coberturas grátis","min":0,"max":2,"itens":["Nutella","Leite condensado","Chocolate","Morango","Beijos Finni","Dentadura Finni","Mel","Cookies","Ferrero Rocher","Abacaxi"]}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]',
 true, 1, true),
(1, 'Açaí Turbinado',
 'Acompanha leite, banana, morango, granola, amendoim e paçoca.',
 '[{"nome":"400ml","preco":17.00},{"nome":"500ml","preco":21.00}]',
 '[{"titulo":"Adicionais grátis","min":0,"max":4,"itens":["Granola","Banana","Morango","Uva","Kiwi","Leite em pó","Creme de avelã","Leite condensado","Ovomaltine","Marshmallow","Gotas de chocolate","Paçoca","Canudinho","Brigadeiro de chocolate","Brigadeiro de beijinho","Brownie","KitKat","Bis","Granulado","Farinha láctea","Amendoim","Choco Power","Micro Ball","Jujuba","Cereja","Oreo","M&M","Creme de cookies"]},
   {"titulo":"Coberturas grátis","min":0,"max":2,"itens":["Nutella","Leite condensado","Chocolate","Morango","Beijos Finni","Dentadura Finni","Mel","Cookies","Ferrero Rocher","Abacaxi"]}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]',
 true, 2, true),
(1, 'Açaí Zero (sem açúcar)',
 'Açaí zero açúcar, do mesmo jeito cremoso.',
 '[{"nome":"300ml","preco":14.00},{"nome":"400ml","preco":18.00},{"nome":"500ml","preco":20.00},{"nome":"700ml","preco":30.00}]',
 '[{"titulo":"Adicionais grátis","min":0,"max":4,"itens":["Granola","Banana","Morango","Uva","Kiwi","Leite em pó","Creme de avelã","Ovomaltine","Paçoca","Amendoim","Cereja","Oreo","M&M"]},
   {"titulo":"Coberturas grátis","min":0,"max":2,"itens":["Chocolate","Morango","Mel","Cookies","Abacaxi"]}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]',
 false, 3, true),
(1, 'Açaí na Marmita',
 'Porção família na marmita.',
 '[{"nome":"300ml","preco":15.00},{"nome":"500ml","preco":22.00},{"nome":"700ml","preco":32.00}]',
 '[{"titulo":"Adicionais grátis","min":0,"max":4,"itens":["Granola","Banana","Morango","Uva","Kiwi","Leite em pó","Creme de avelã","Leite condensado","Ovomaltine","Marshmallow","Gotas de chocolate","Paçoca","Canudinho","Brigadeiro de chocolate","Brigadeiro de beijinho","Brownie","KitKat","Bis","Granulado","Farinha láctea","Amendoim","Choco Power","Micro Ball","Jujuba","Cereja","Oreo","M&M","Creme de cookies"]},
   {"titulo":"Coberturas grátis","min":0,"max":2,"itens":["Nutella","Leite condensado","Chocolate","Morango","Beijos Finni","Dentadura Finni","Mel","Cookies","Ferrero Rocher","Abacaxi"]}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]',
 false, 4, true);

-- 5) COPOS TRUFADOS -----------------------------------------
insert into produtos (categoria_id, nome, descricao, tamanhos, adicionais, destaque, ordem, ativo)
values
(2, 'Trufado de Ferrero Rocher', 'Nutella, bombom Ferrero Rocher, amendoim e açaí.',
 '[{"nome":"300ml","preco":17.99},{"nome":"500ml","preco":25.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', true, 1, true),
(2, 'Trufado de Oreo', 'Creme de Oreo, biscoito Oreo, leite em pó e açaí.',
 '[{"nome":"300ml","preco":15.99},{"nome":"500ml","preco":21.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', false, 2, true),
(2, 'Trufado de Ninho', 'Creme de Ninho, leite em pó Ninho, creme de leitinho e açaí.',
 '[{"nome":"300ml","preco":15.99},{"nome":"500ml","preco":21.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', false, 3, true),
(2, 'Trufado de Nutella', 'Nutella, wafer de Nutella e açaí.',
 '[{"nome":"300ml","preco":16.99},{"nome":"500ml","preco":24.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', true, 4, true),
(2, 'Trufado de Prestígio', 'Brigadeiro de coco, creme de avelã, bombom Prestígio e açaí.',
 '[{"nome":"300ml","preco":15.99},{"nome":"500ml","preco":21.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', false, 5, true),
(2, 'Trufado Napolitano', 'Creme de leitinho, creme de morango, creme de avelã e açaí.',
 '[{"nome":"300ml","preco":15.99},{"nome":"500ml","preco":21.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', false, 6, true),
(2, 'Trufado Dois Amores', 'Creme de Ninho, Nutella, leite em pó, morangos frescos e açaí.',
 '[{"nome":"300ml","preco":16.99},{"nome":"500ml","preco":24.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', false, 7, true),
(2, 'Trufado de Cookies', 'Creme de cookies, leite em pó, biscoito cookies e açaí.',
 '[{"nome":"300ml","preco":15.99},{"nome":"500ml","preco":21.99}]',
 '[{"nome":"Nutella extra","preco":5.00},{"nome":"Creme extra","preco":5.00},{"nome":"Adicional variado","preco":3.00}]', false, 8, true);

-- 6) ESPECIAIS ----------------------------------------------
insert into produtos (categoria_id, nome, descricao, preco, destaque, ordem, ativo)
values
(3, 'Açaí no Pote da Nutella 350g', 'Leite condensado, açaí, leite em pó, morangos, Nutella e KitKat.', 17.00, true, 1, true),
(3, 'Açaí no Pote da Nutella 650g', 'Leite condensado, açaí, leite em pó, morangos, Nutella e KitKat.', 28.50, false, 2, true),
(3, 'Copo Brownie com Morango', 'Creme de ninho, brigadeiro de chocolate, morangos e brownie.', 18.00, false, 3, true),
(3, 'Roleta de Açaí', '4 adicionais, 1 creme e 1 cobertura à sua escolha.', 25.00, false, 4, true);

-- 7) AÇAÍ NA GARRAFA (500ml) --------------------------------
insert into produtos (categoria_id, nome, descricao, preco, ordem, ativo)
values
(4, 'Garrafa Tradicional', 'Leite em pó + leite condensado. Garrafa 500ml.', 17.00, 1, true),
(4, 'Garrafa Creme de Morango', 'Açaí com creme de morango. Garrafa 500ml.', 17.00, 2, true),
(4, 'Garrafa Creme de Maracujá', 'Açaí com creme de maracujá. Garrafa 500ml.', 17.00, 3, true),
(4, 'Garrafa Creme de Ninho', 'Açaí com creme de Ninho. Garrafa 500ml.', 17.00, 4, true),
(4, 'Garrafa Creme de Oreo', 'Açaí com creme de Oreo. Garrafa 500ml.', 17.00, 5, true),
(4, 'Garrafa Nutella / Ninho c/ Nutella', 'Açaí com Nutella ou Ninho com Nutella. Garrafa 500ml.', 20.00, 6, true);

-- 8) BAIRROS (a dona ajusta no painel — exemplos p/ Aracati) --
insert into bairros (nome, taxa, ativo) values
  ('Centro', 3.00, true),
  ('Retirar na loja', 0.00, true)
on conflict (nome) do nothing;
