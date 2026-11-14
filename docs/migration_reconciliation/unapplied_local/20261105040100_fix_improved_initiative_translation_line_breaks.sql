UPDATE public.srd_feats
SET descricao_pt =
  'Benefício: Você recebe +4 de bônus nos testes de iniciativa.'
  || chr(10) || chr(10) ||
  'Especial: Um guerreiro pode escolher Iniciativa Aprimorada como um de seus talentos adicionais de guerreiro.'
WHERE id='iniciativa_aprimorada';
