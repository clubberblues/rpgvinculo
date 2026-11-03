-- Completa descrições ausentes dos quatro catálogos SRD 3.5
-- usando estatísticas já armazenadas e fontes canônicas.
BEGIN;

UPDATE public.srd_equipment AS e
SET descricao = CASE
  WHEN e.categoria = 'arma' OR e.tipo = 'arma' THEN
    concat_ws(' · ',
      'Arma SRD 3.5',
      CASE WHEN nullif(e.dano,'') IS NOT NULL THEN 'Dano '||e.dano END,
      CASE WHEN nullif(e.critico,'') IS NOT NULL THEN 'Crítico '||e.critico END,
      CASE WHEN nullif(e.tipo_dano,'') IS NOT NULL THEN 'Tipo '||e.tipo_dano END,
      CASE WHEN e.peso IS NOT NULL AND e.peso > 0 THEN 'Peso '||trim(to_char(e.peso,'FM999990D00'))||' kg' END,
      CASE WHEN coalesce(e.custo_po,e.preco) IS NOT NULL THEN 'Preço '||trim(to_char(coalesce(e.custo_po,e.preco),'FM999999990D00'))||' po' END
    )
  WHEN e.categoria IN ('armadura','escudo') OR e.tipo IN ('armadura','escudo') THEN
    concat_ws(' · ',
      CASE WHEN e.categoria='escudo' OR e.tipo='escudo' THEN 'Escudo SRD 3.5' ELSE 'Armadura SRD 3.5' END,
      CASE WHEN coalesce(e.bonus_ca,e.ca_bonus) IS NOT NULL THEN 'Bônus de CA +'||coalesce(e.bonus_ca,e.ca_bonus)::text END,
      CASE WHEN coalesce(e.bonus_max_des,e.max_des) IS NOT NULL THEN 'DES máxima +'||coalesce(e.bonus_max_des,e.max_des)::text END,
      CASE WHEN e.penalidade_armadura IS NOT NULL THEN 'Penalidade de armadura '||e.penalidade_armadura::text END,
      CASE WHEN e.peso IS NOT NULL AND e.peso > 0 THEN 'Peso '||trim(to_char(e.peso,'FM999990D00'))||' kg' END,
      CASE WHEN coalesce(e.custo_po,e.preco) IS NOT NULL THEN 'Preço '||trim(to_char(coalesce(e.custo_po,e.preco),'FM999999990D00'))||' po' END
    )
  WHEN e.id='pocao_armadura_mago' THEN 'Poção de Armadura Arcana: concede bônus de armadura +4 na CA por 1 hora por nível de conjurador.'
  WHEN e.id='pocao_cura_grav' THEN 'Poção de Curar Ferimentos Graves: recupera 3d8+5 PV; causa dano a mortos-vivos, que podem realizar resistência de Vontade para metade.'
  WHEN e.id='pocao_cura_lig' THEN 'Poção de Curar Ferimentos Leves: recupera 1d8+1 PV; causa dano a mortos-vivos, que podem realizar resistência de Vontade para metade.'
  WHEN e.id='pocao_cura_mod' THEN 'Poção de Curar Ferimentos Moderados: recupera 2d8+3 PV; causa dano a mortos-vivos, que podem realizar resistência de Vontade para metade.'
  WHEN e.id='pocao_escudo_fe' THEN 'Poção de Escudo da Fé: concede bônus de deflexão +2 na CA por 1 minuto por nível de conjurador.'
  WHEN e.id='pocao_forca_touro' THEN 'Poção de Força do Touro: concede bônus de aprimoramento +4 em Força por 3 minutos.'
  ELSE concat_ws(' · ',
    CASE WHEN e.tipo='montaria' THEN 'Montaria SRD 3.5' WHEN e.tipo='veiculo' THEN 'Veículo SRD 3.5' ELSE 'Equipamento SRD 3.5' END,
    CASE WHEN e.peso IS NOT NULL AND e.peso > 0 THEN 'Peso '||trim(to_char(e.peso,'FM999990D00'))||' kg' END,
    CASE WHEN coalesce(e.custo_po,e.preco) IS NOT NULL THEN 'Preço '||trim(to_char(coalesce(e.custo_po,e.preco),'FM999999990D00'))||' po' END
  )
END,
source_status=CASE WHEN coalesce(source_status,'')='' THEN 'source_attached' ELSE source_status END,
source_notes=coalesce(nullif(source_notes,''),'Descrição de catálogo derivada dos campos numéricos existentes; conferir a fonte para texto integral.')
WHERE nullif(btrim(e.descricao),'') IS NULL;

UPDATE public.srd_monsters
SET nome='Esqueleto de Dragão Vermelho Adulto Jovem',
    descricao='Variante esquelética de dragão vermelho adulto jovem. CA 12; 123 PV; mordida +17 corpo a corpo (2d8+10).'
WHERE id='young_adult_red_dragon_skeleton' AND nullif(btrim(descricao),'') IS NULL;

UPDATE public.srd_monsters
SET nome='Esqueleto de Megarraptor Avançado',
    descricao='Variante esquelética de megarraptor avançado. CA 14; 78 PV; garras +9 corpo a corpo (2d8+5).'
WHERE id='advanced_megaraptor_skeleton' AND nullif(btrim(descricao),'') IS NULL;

UPDATE public.srd_monsters
SET nome='Esqueleto de Gigante das Nuvens',
    descricao='Variante esquelética de gigante das nuvens. CA 13; 110 PV; ataques com estrela da manhã, garra ou rocha conforme o bloco SRD.'
WHERE id='cloud_giant_skeleton' AND nullif(btrim(descricao),'') IS NULL;

UPDATE public.srd_monsters
SET nome='Zumbi Wyvern',
    descricao='Variante zumbi de wyvern. CA 20; 94 PV; pancada +11 (2d6+7) ou garras +11 (2d6+5).'
WHERE id='wyvern_zombie' AND nullif(btrim(descricao),'') IS NULL;

UPDATE public.srd_monsters
SET nome='Zumbi de Render Cinzento',
    descricao='Variante zumbi de render cinzento. CA 16; 133 PV; mordida +16 (2d6+7) ou pancada +16 (1d8+10).'
WHERE id='gray_render_zombie' AND nullif(btrim(descricao),'') IS NULL;

COMMIT;

