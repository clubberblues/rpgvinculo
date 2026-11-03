# Vínculo — entrega D&D 3.5 SRD

## Arquivos e publicação

Publique `index.html`, `lobby.html`, `ficha.html` e `mesa.html` na raiz do site. O pacote preserva `lobby_atualizado.html` como espelho, `dice.html`, `fundo-livro.png` e as capas `capa-mestre.png`, `capa-jogador.png`, `capa-monstros.png` e `capa-mundo.png`.

O modo D&D 3.5 usa `srd_character_sheets`; a compatibilidade arquivada usa `vinculo_character_sheets`. Não deve haver consulta direta à relação removida `public.character_sheets`.

## Banco de dados e implantação

`role_ownership_migration.sql` corrige o papel de Mestre usando `campaigns.owner_id` como fonte única: o proprietário fica como Mestre, os demais membros como Jogador (ou Observador quando já designado assim), e um gatilho impede que um não proprietário obtenha papel de Mestre. A migração também substitui `lobby_list_v2` para retornar o papel calculado pelo proprietário e cria `sentar_personagem_na_mesa`, que só permite ao próprio jogador associar sua ficha à campanha. Esta migração ainda precisa ser aplicada no projeto Supabase antes de publicar/usar o fluxo atualizado do lobby.

`srd35_initiative_turn_controls_migration.sql` corrige aliases SQL inválidos na RPC de iniciativa que impediam abrir a ordem; inclui na espera apenas personagens jogadores com token publicado; mantém o início automático quando a última ficha solicitada registra a rolagem; e cria `mover_token_gm_cba_srd`, que valida turno, deslocamento, ocupação do quadrado e ação de movimento do token controlado pelo Mestre. Aplique este arquivo no Supabase antes de publicar o `mesa.html` atualizado.

`srd35_token_equipment_migration.sql` cria inventário para NPCs e monstros, amplia as categorias do compêndio para mochila/acessórios, aplica a regra de guardar na mochila ou equipar automaticamente quando não há mochila, atualiza CA ao equipar tokens e inclui tabelas de presença/fichas/equipamento na publicação Realtime. Aplique depois de `vtt_dnd35_final_migration.sql` e `srd35_compendium_migration.sql`.

Na mesa, o rodapé agora reúne a ordem da iniciativa e cards de jogadores, NPCs e monstros; os cards exibem a iniciativa, PV atual e CA. A CA do personagem é derivada da ficha e dos itens equipados; tokens de criaturas recebem seu inventário e podem ter itens equipados pelo Mestre. O chat anuncia em uma frase curta a ativação da rodada e cada troca de turno.

O lobby exibe “Administrar Mesa” apenas ao proprietário e exige que os demais escolham uma ficha própria. A mesa confere propriedade e ficha vinculada antes de montar os controles; cada interface recebe grupos de ações próprios. Na ficha, os controles do Grimório não são liberados por parâmetros da URL. A criação foi dividida em etapas curtas, com ajuda aberta apenas quando solicitada; a etapa de magia aparece somente para classes com espaços de magia no nível escolhido e as seleções ficam como rascunho até salvar a ficha.

O usuário informou que as migrações SRD anteriores foram executadas com sucesso. A entrega anterior não acessou nem alterou o Supabase remoto. Para habilitar o Grimório e a conjuração, a migração `srd35_spellcasting_migration.sql` deve estar aplicada depois das tabelas/migrações base de personagens, classes, magias, compêndio e CBA — em especial `srd35_character_migration.sql`, `srd35_skills_feats_migration.sql`, `srd35_compendium_migration.sql` e `vtt_dnd35_final_migration.sql`.

`srd35_action_economy_migration.sql` foi aplicada no projeto Supabase conectado depois de `srd35_spellcasting_migration.sql`. Ela é aditiva: não cria colunas nem altera fichas existentes; registra o uso de ações em `campaigns.combat_data`, cria uma RPC autenticada para consumir ações e cria um wrapper transacional para conjuração. O wrapper só consome uma ação padrão quando o combate está ativo; em exploração, preserva o custo anterior. A migração também revoga o acesso direto do navegador à RPC antiga de conjuração para impedir que a interface contorne o controle de ação.

Não reexecute migrações anteriores já aplicadas com sucesso. Use uma campanha de teste antes de campanha ativa. As validações originais deste pacote foram locais e com Supabase simulado. Em 31/10/2026, `security_hardening_migration.sql` e `security_rpc_guards_migration.sql` foram aplicadas no projeto conectado: ativaram RLS nas tabelas expostas, restringiram campanhas, membros e fichas, mantiveram os catálogos como leitura pública, moveram a listagem, entrada por código e criação de campanha para RPCs autenticadas e corrigiram verificações de papel nulo em RPCs antigas. O estado de RLS, códigos de convite e permissões das RPCs foi conferido no Supabase; os fluxos da interface ainda precisam de validação funcional com contas de teste.


## Equipamento inicial de personagens

A migração `srd35_character_starting_equipment_migration.sql` cria os kits sugeridos por classe e a RPC autenticada `finalizar_equipamento_inicial_srd`. Ela já foi aplicada no Supabase conectado em 01/11/2026. Na criação da ficha, a etapa **Equipamento inicial** permite escolher o kit sugerido pelo Vínculo ou rolar os dados de riqueza inicial da classe e comprar equipamentos mundanos no catálogo, com saldo atualizado. A rolagem usa as fórmulas de riqueza de D&D 3.5; por exemplo, Monge rola 5d4 po e Guerreiro 6d4×10 po. A RPC confere no servidor propriedade da ficha, resultados dos d4, IDs/quantidades/preços do catálogo e limite de compra; grava inventário, itens equipados e ouro restante. O inventário recebe uma única finalização por ficha. Os kits são sugestões próprias do Vínculo, baseadas nos itens e preços disponíveis, não transcrições integrais dos pacotes raça/classe do Livro do Jogador.

## Grimório e conjuração

Na `ficha.html`, Mago, Feiticeiro, Bardo, Clérigo, Druida, Paladino e Patrulheiro têm painel de progressão, espaços disponíveis e acesso ao Grimório, respeitando a progressão própria de cada classe. O jogador pesquisa as magias presentes em `srd_spells`, registra magias no livro, seleciona conhecidas (Feiticeiro) ou preparadas (Mago/Clérigo/Druida), escolhe o círculo do espaço e pode repor após descanso diário. A seleção é persistida em JSONB. A interface e as RPCs consideram o atributo-chave, espaços-base, espaços bônus, nível da classe, círculo da magia e requisito mínimo de atributo; usos do Feiticeiro e espaços preparados gastos não podem ser restaurados apenas alterando a lista no navegador.

Na `mesa.html`, **Conjurar Magia** abre o catálogo conhecido/preparado da ficha própria. O VTT oferece espaços compatíveis, alvo opcional, mensagem pública de chat e uma rolagem de ataque pela regra de mesa solicitada: `1d20 + BBA + modificador de INT/SAB/CAR`. A RPC valida ficha, classe, campanha, magia, espaço e alvo. Magias de cura rolam no servidor, atualizam PV sem passar do máximo e sincronizam a ficha/CBA quando há um token correspondente. Dano/CA e efeitos que dependem de resistência continuam sob confirmação/aplicação do Mestre.

**Limitações de regras:** espaços de domínio do Clérigo não são incluídos porque não há seleção de domínio na ficha. A migração semeia apenas 13 magias iniciais (truques e magias de 1º círculo); o restante depende do conteúdo já existente em `srd_spells` ou de uma carga adicional. Não há ainda controle automatizado de componentes, resistência/CD, duração, concentração, condições ou efeitos de magias utilitárias.

As progressões e regras foram conferidas com as páginas SRD indicadas em `srd35_spellcasting_sources.md`. A fórmula de ataque mágico acima é uma regra de mesa pedida pelo usuário, não uma descrição da regra geral de ataque mágico do SRD 3.5.

## Bestiário, menu contextual e combate

O botão **+ Monstros** do Mestre consulta `srd_monsters`, com busca/filtro, cartões e ações para adicionar a criatura ou publicar seu bloco técnico no chat. O token adicionado preserva o ID SRD, estatísticas, PV máximo/atual e URL de fonte; clicar com o botão direito no token de monstro também pode publicar suas informações. O Mestre pode clicar no token para abrir opções de ataque manual, ajuste de PV e publicação da ficha. O ataque de uma criatura abre uma rolagem de d20 para o Mestre; o bônus, alvo, CA e dano continuam sob resolução do Mestre, sem aplicação automática. O ajuste de PV continua sujeito à autorização de Mestre no servidor.

Ao clicar no próprio token, o jogador encontra atalhos para ataque corpo a corpo, ataque à distância, conjuração e inventário da ficha selecionada. Os tokens aceitam teclado; Escape fecha o menu e devolve o foco. O clique/arraste e o botão de PV não se sobrepõem: o ajuste de PV do Mestre está no menu contextual (o duplo clique legado também permanece).

O CBA usa quadrados de 1,5 m, encaixe no grid, suporte a toque/zoom e barras de PV. Durante o próprio turno, o jogador vê uma prévia do movimento racial acumulado; exceder o deslocamento aparece em vermelho, mas a RPC continua sendo a validação autoritativa. O painel de economia mostra ação padrão, movimento e ação rápida do turno. Ataques e magias consomem atomicamente a ação padrão; movimentação é contabilizada pela RPC existente, e o consumo não é reiniciado por renderizações do navegador. A iniciativa de NPCs/monstros usa `1d20 + DES`; jogadores rolam manualmente `d20 + DES`, com talentos aplicáveis.

O Mestre pode entregar itens do catálogo ao inventário SRD. A ficha lê armas/armaduras equipadas para exibir CA, bônus de ataque e dado de dano; ataques à distância verificam alcance conhecido. Poção de cura consome uma unidade, rola `2d4+2` e não ultrapassa o PV máximo.

## Cards de combate, CA e equipamentos da mesa

Os cards inferiores reúnem fichas de jogadores e tokens de NPCs/monstros, mostram PV atual, CA e posição na iniciativa. A ordem de iniciativa e os controles do Mestre ficam junto desses cards; as mensagens de turno no chat são curtas. A CA do personagem é calculada a partir de Destreza, limite de Destreza da armadura e bônus dos itens equipados. A CA de NPC/monstro é mantida no token, com bônus de armadura, escudo e acessório somados aos itens equipados.

O catálogo da mesa consulta `srd_equipment`. O Mestre pode entregar itens para uma ficha de jogador ou token de NPC/monstro. Se o destinatário não tiver mochila, itens equipáveis são equipados automaticamente; com mochila, os itens são guardados. Jogadores equipam e desequipam itens da própria ficha; o Mestre controla o inventário de NPCs/monstros. O recálculo de CA do token acontece dentro da mesma RPC transacional que entrega o equipamento.

As migrações `srd35_initiative_turn_controls_migration.sql`, `srd35_token_equipment_migration.sql` e `srd35_equipment_category_mapping_migration.sql` foram aplicadas ao projeto Supabase `Vinculo` em 01/11/2026, depois das tabelas e funções base de iniciativa, combate, ficha e compêndio. A migração `srd35_character_hp_rpc_migration.sql` recompõe `alterar_pv_personagem`, ausente no schema cache, e foi aplicada em 01/11/2026. O catálogo SRD atual possui 1.021 registros; a mesa pagina a busca para carregá-los integralmente e normaliza categorias importadas na hora de equipar, preservando a categoria de origem.

## Biblioteca SRD

No lobby, clique em **Biblioteca SRD** no menu lateral esquerdo — logo abaixo de **Minhas Fichas** — para abrir diretamente o compêndio. O botão **Abrir Biblioteca SRD · D&D 3.5** também continua disponível em **Livros**. A Biblioteca pesquisa monstros, magias, equipamentos e classes, pagina os resultados, filtra por categoria, mostra blocos técnicos e abre a fonte SRD em nova aba. Os dados são renderizados como texto seguro.

O compêndio inclui dez criaturas canônicas iniciais, não o bestiário completo do SRD. “Rato atroz (rato gigante)” usa o bloco oficial **Dire Rat**; dados de rato comum foram descartados. O compêndio não cria conteúdo completo para todos os itens, magias ou classes.

## Licença e atribuição

As descrições em português incluídas são paráfrases; os valores de jogo mantêm referências às fontes. O pacote contém o texto da OGL 1.0a em `OPEN_GAME_LICENSE_1.0a.txt` e notas/fontes do compêndio e da conjuração em `srd35_compendium_sources.md` e `srd35_spellcasting_sources.md`. Confira o aviso de copyright/licença antes de redistribuir fora do seu projeto.

## Validação

Passaram localmente: parse de HTML e JavaScript inline com Node/HTMLParser; parse PostgreSQL das migrações de conjuração e economia de ações com `pglast`; smoke tests Playwright com Supabase simulado da ficha (carregar, abrir Grimório e conferir payload RPC) e da mesa (conjurar via wrapper, conferir economia de ações, abrir menus por papel, carregar bestiário, publicar estatísticas, adicionar token e validar alerta de movimento racial acima de 9 m). Estes testes não acessam nem comprovam o banco, os dados ou as permissões de produção.

## Atualização de NPCs e resolução de combate

As migrações `srd35_npc_archetypes_migration.sql` e `srd35_combat_resolution_migration.sql` registram no repositório as alterações aplicadas ao projeto Supabase em 31/10/2026. A primeira cria cinco arquétipos por combinação de raça e classe para geração de NPCs com nível selecionável. A segunda adiciona as rotinas autenticadas de resolução/aplicação de dano e consumo de ações do Mestre por token. A geração de fichas e os controles de combate do Mestre dependem dessas estruturas e da interface correspondente.

Na mesa, Mestre e jogador recebem identificações e ações próprias. O menu de cada token mostra somente os comandos compatíveis com o papel e com o turno ativo; no turno de uma criatura administrada pelo Mestre, o painel permite atacar, registrar uma ação e encerrar o turno. O ataque compara o resultado com a CA e, em caso de acerto, abre a rolagem do dado de dano e aplica o dano aos PV do alvo. Mover o token ativo do Mestre consome a ação de movimento no servidor. O gerador **Criar NPC** oferece cinco arquétipos por raça/classe e nível, e insere a criatura na mesa e na iniciativa.

A ficha recebeu um tema de HUD rústico e um guia contextual na criação: ao focar um campo de nome, atributo, perícia, talento ou grimório, aparece uma explicação que pode ser fechada ou dispensada. Os dados da ficha continuam carregados pelo identificador de personagem e protegidos pelas políticas/RPCs existentes; o parâmetro `role=gm` altera recursos de interface legados, não concede acesso no banco.


## Correções de combate de tokens (01/11/2026)

A migração `srd35_cba_token_combat_migration.sql` foi aplicada ao Supabase conectado. A nova RPC `adicionar_token_cba_completo` mantém no CBA os dados de combate que o banco antes descartava (bloco SRD, CA, PV, Destreza, bônus/fórmula de ataque e estado de magia); ela delega a validação de Mestre, identidade e posição à RPC existente. `alterar_pv_token_cba(bigint,text,integer,integer)` permite ao Mestre aplicar dano/cura em NPCs e monstros, limita PV ao máximo e devolve a cena atualizada. A assinatura fica disponível no cache do PostgREST após o aviso de recarga emitido pela migração.

Na mesa, o botão **Adicionar à mesa** do bestiário usa o catálogo definido antes do clique e salva tokens com as estatísticas numéricas. Fichas do Mestre usadas como NPCs levam PV, CA, atributos e arma equipada para o token. Armas equipadas no inventário do token substituem a fórmula de dano padrão; o ataque também usa o modificador de Força registrado. O rodapé organiza todos os cards pela iniciativa a partir do combatente atual, fazendo a fila avançar para a esquerda com movimento suave (respeitando a preferência do sistema por movimento reduzido). Os cards mostram PV, CA, bônus de ataque e dado de dano quando esses dados estão disponíveis.


Além disso, ao abrir a mesa como Mestre, a interface busca no catálogo SRD os dados de CA, PV e bloco de ataque de monstros antigos que já estavam no CBA sem esses campos e salva a correção na cena.

## Mesa: cards de combate e ordem do turno

A interface da mesa reúne fichas, NPCs e monstros em uma faixa horizontal no rodapé, com rolagem horizontal e cards lado a lado. O chat e o Dice ficam na coluna esquerda; o mapa ocupa o centro e as ações ficam à direita. Durante combate, a fila acompanha a iniciativa e destaca o combatente ativo. O card e o token no tabuleiro usam a mesma entrada de iniciativa (incluindo a distinção entre ficha de jogador e token controlado pelo Mestre), para manter o destaque sincronizado.

O controle de combate e a economia de ações ficam no painel lateral do turno ativo. Os tokens mostram CA numérica: fichas usam atributos e equipamento; monstros usam o bloco SRD; NPCs sem bloco completo recebem um valor derivado dos atributos, armadura natural e equipamento. Ao abrir a mesa como Mestre, tokens antigos sem CA são reparados e salvos na cena.

Tokens do Mestre com magias preparadas podem selecionar uma delas no turno correspondente. O sistema consome a ação padrão e marca o espaço como gasto; o alcance, resistência e efeitos específicos continuam sob resolução do Mestre quando os dados da ficha não permitem cálculo automático seguro.


## Motor de regras D&D 3.5 SRD/OGL — estado em 01/11/2026

A arquitetura e a migração-base do motor estão documentadas em [DND35_RULE_ENGINE_ARCHITECTURE.md](DND35_RULE_ENGINE_ARCHITECTURE.md); o plano e a auditoria estão em [PLANO_MESTRE_MESA.md](PLANO_MESTRE_MESA.md). A migração `srd35_rule_engine_foundation_migration.sql` foi aplicada ao Supabase de produção.

O estado confirmado contém 220 progressões de classe e 1.400 registros de progressão de espaços de magia, além de 7 trilhas de classe normalizadas para as fichas existentes. Os catálogos têm 7 raças, 11 classes, 49 perícias, 110 talentos, 1.021 equipamentos, 601 magias e 445 monstros. Esses totais não significam que cada entrada e regra tenha sido verificada.

**O motor SRD ainda não está completo.** O ledger conserva as 11 áreas de cobertura como pendentes. Domínios, características por nível, condições, efeitos tipados de magia e estado relacional de grimório/preparação ainda não têm dados completos; cálculos e resoluções dessas regras ainda precisam ser implementados e conferidos. Nenhum livro fechado foi copiado para o catálogo.

## Atualização da interface e fluxo de habilidades (03/11/2026)

A mesa foi ajustada para manter os cards dos combatentes lado a lado no rodapé, com rolagem horizontal; o painel de dados do jogador divide a coluna esquerda com o chat somente enquanto estiver aberto, e o título do Dice foi compactado. A identidade carvão/verde-musgo/dourado foi aplicada aos painéis de ações da mesa e aos componentes D&D 3.5 da ficha.

O menu do aventureiro agora inclui **Habilidades da Classe** em combate e exploração. Ele consulta `srd_class_level_features` para exibir características registradas até o nível da ficha e permite anunciar o uso no chat para confirmação do Mestre. O catálogo atual cobre 11 classes, mas possui 131 características distribuídas de forma desigual; algumas classes ainda têm níveis sem registros suficientes. A interface não inventa habilidades nem consome usos que ainda não estejam estruturados no banco.

A conjuração da mesa agora inclui Bardo no fluxo espontâneo, além de Feiticeiro. Magias sem resolver automático de dano, ataque, resistência ou duração podem ser registradas e encaminhadas para resolução do Mestre, em vez de ficarem bloqueadas antes do uso. Isso não significa que os 607 registros do catálogo tenham efeitos automáticos: os 607 registros atuais de `srd_spell_effects` permanecem classificados como resolução manual. Cura e Míssil Mágico mantêm os resolvers específicos já existentes.

A validação desta atualização inclui parse sintático dos scripts inline de `mesa.html` e `ficha.html` e leitura das tabelas de progressão/efeitos no Supabase. Não foi executado teste visual de navegador com sessões simultâneas de Mestre e jogador. Nenhum dado de campanha foi atualizado nesta etapa.