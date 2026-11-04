-- Verify the six recently added SRD spells against their source pages and correct their Portuguese rules summaries.
UPDATE public.srd_spells
SET descricao = 'Um cone de chamas alcança 4,5 m. Cada criatura na área sofre 1d4 de dano de fogo por nível de conjurador (máximo 5d4); um teste de Reflexos bem-sucedido reduz o dano à metade. Resistência à magia se aplica. Materiais inflamáveis podem pegar fogo; uma criatura pode apagar itens em chamas com uma ação de rodada completa.',
    source_status = 'verified_srd',
    source_notes = 'Campos e resumo conferidos na página oficial do SRD 3.5. O motor ainda não automatiza este efeito de área.',
    updated_at = now()
WHERE id = 'srd35_spell_burning_hands';

UPDATE public.srd_spells
SET descricao = 'Criaturas caóticas são imunes. Criaturas leais sofrem 1d8 de dano por cada dois níveis de conjurador (máximo 5d8); extraplanares leais sofrem 1d6 por nível (máximo 10d6). Um teste de Vontade bem-sucedido reduz o dano à metade e evita lentidão por 1d6 rodadas. Criaturas neutras sofrem metade do dano, não ficam lentas e podem reduzir o dano à metade novamente com um sucesso no teste de Vontade. Resistência à magia se aplica.',
    source_status = 'verified_srd',
    source_notes = 'Campos e resumo conferidos na página oficial do SRD 3.5. O motor ainda não automatiza o efeito de área, alinhamento ou condição.',
    updated_at = now()
WHERE id = 'srd35_spell_chaos_hammer';

UPDATE public.srd_spells
SET descricao = 'A vegetação da área tenta enredar as criaturas. Um sucesso no teste de Reflexos evita a condição, mas ainda limita o deslocamento à metade enquanto a criatura estiver na área. Uma criatura enredada pode gastar uma ação de rodada completa para tentar se libertar com Força CD 20 ou Arte da Fuga CD 20; se conseguir, move-se à metade do deslocamento. No início de cada turno do conjurador, as plantas tentam enredar novamente quem escapou ou resistiu. Duração: 1 minuto por nível, dissipável; resistência à magia não se aplica.',
    source_status = 'verified_srd',
    source_notes = 'Campos e resumo conferidos na página oficial do SRD 3.5. O motor ainda não automatiza a área recorrente nem a condição.',
    updated_at = now()
WHERE id = 'srd35_spell_entangle';

UPDATE public.srd_spells
SET descricao = 'Criaturas bondosas são imunes. Cada criatura maligna na área sofre 1d8 de dano por cada dois níveis de conjurador (máximo 5d8); extraplanares malignos sofrem 1d6 por nível (máximo 10d6) e ficam cegos por 1 rodada. Um sucesso no teste de Vontade reduz o dano à metade e evita a cegueira. Criaturas neutras sofrem metade do dano e não ficam cegas; um sucesso no teste de Vontade reduz o dano à metade novamente. Resistência à magia se aplica.',
    source_status = 'verified_srd',
    source_notes = 'Campos e resumo conferidos na página oficial do SRD 3.5. O motor ainda não automatiza o efeito de área, alinhamento ou condição.',
    updated_at = now()
WHERE id = 'srd35_spell_holy_smite';

UPDATE public.srd_spells
SET descricao = 'Criaturas leais são imunes. Criaturas caóticas sofrem 1d8 de dano por cada dois níveis de conjurador (máximo 5d8); extraplanares caóticos sofrem 1d6 por nível (máximo 10d6) e ficam pasmas por 1 rodada. Um sucesso no teste de Vontade reduz o dano à metade e evita a condição. Criaturas neutras sofrem metade do dano e não ficam pasmas; um sucesso no teste de Vontade reduz o dano à metade novamente. Resistência à magia se aplica.',
    source_status = 'verified_srd',
    source_notes = 'Campos e resumo conferidos na página oficial do SRD 3.5. “Dazed” foi traduzido como “pasmo”, distinto de “stunned” (atordoado). O motor ainda não automatiza este efeito de área.',
    updated_at = now()
WHERE id = 'srd35_spell_orders_wrath';

UPDATE public.srd_spells
SET descricao = 'Criaturas malignas são imunes. Cada criatura bondosa na área sofre 1d8 de dano por cada dois níveis de conjurador (máximo 5d8); extraplanares bondosos sofrem 1d6 por nível (máximo 10d6) e ficam enjoados por 1d4 rodadas. Um sucesso no teste de Vontade reduz o dano à metade e evita a condição. Remover doença ou cura não anulam esses efeitos; remover maldição funciona. Criaturas neutras sofrem metade do dano, não ficam enjoadas e podem reduzir o dano à metade novamente com um sucesso no teste de Vontade. Resistência à magia se aplica.',
    source_status = 'verified_srd',
    source_notes = 'Campos e resumo conferidos na página oficial do SRD 3.5. O motor ainda não automatiza o efeito de área, alinhamento ou condição.',
    updated_at = now()
WHERE id = 'srd35_spell_unholy_blight';
