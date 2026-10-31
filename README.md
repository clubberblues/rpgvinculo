# Vínculo — entrega D&D 3.5 SRD

## Arquivos e publicação

Publique `index.html`, `lobby.html`, `ficha.html` e `mesa.html` na raiz do site. O pacote preserva `lobby_atualizado.html` como espelho, `dice.html`, `fundo-livro.png` e as capas `capa-mestre.png`, `capa-jogador.png`, `capa-monstros.png` e `capa-mundo.png`.

O modo D&D 3.5 usa `srd_character_sheets`; a compatibilidade arquivada usa `vinculo_character_sheets`. Não deve haver consulta direta à relação removida `public.character_sheets`.

## Banco de dados e implantação

O usuário informou que as migrações SRD anteriores foram executadas com sucesso. Esta atualização **não acessou nem alterou o Supabase remoto**. Para habilitar o Grimório e a conjuração, a migração `srd35_spellcasting_migration.sql` deve estar aplicada depois das tabelas/migrações base de personagens, classes, magias, compêndio e CBA — em especial `srd35_character_migration.sql`, `srd35_skills_feats_migration.sql`, `srd35_compendium_migration.sql` e `vtt_dnd35_final_migration.sql`.

**Aplique agora a nova migração** `srd35_action_economy_migration.sql` no SQL Editor do Supabase, depois de `srd35_spellcasting_migration.sql`. Ela é aditiva: não cria colunas nem altera fichas existentes; registra o uso de ações em `campaigns.combat_data`, cria uma RPC autenticada para consumir ações e cria um wrapper transacional para conjuração. O wrapper só consome uma ação padrão quando o combate está ativo; em exploração, preserva o custo anterior. A migração também revoga o acesso direto do navegador à RPC antiga de conjuração para impedir que a interface contorne o controle de ação.

Não reexecute migrações anteriores já aplicadas com sucesso. Use uma campanha de teste antes de campanha ativa. As validações deste pacote são locais e com Supabase simulado; a execução real da migração, RLS, funções SQL, dados existentes e realtime ainda precisa ser confirmada no seu projeto Supabase.

## Grimório e conjuração

Na `ficha.html`, Mago, Feiticeiro, Clérigo e Druida têm um painel com progressão, espaços disponíveis e acesso ao Grimório. O jogador pesquisa as magias presentes em `srd_spells`, registra magias no livro, seleciona conhecidas (Feiticeiro) ou preparadas (Mago/Clérigo/Druida), escolhe o círculo do espaço e pode repor após descanso diário. A seleção é persistida em JSONB. A interface e as RPCs consideram o atributo-chave, espaços-base, espaços bônus, nível da classe, círculo da magia e requisito mínimo de atributo; usos do Feiticeiro e espaços preparados gastos não podem ser restaurados apenas alterando a lista no navegador.

Na `mesa.html`, **Conjurar Magia** abre o catálogo conhecido/preparado da ficha própria. O VTT oferece espaços compatíveis, alvo opcional, mensagem pública de chat e uma rolagem de ataque pela regra de mesa solicitada: `1d20 + BBA + modificador de INT/SAB/CAR`. A RPC valida ficha, classe, campanha, magia, espaço e alvo. Magias de cura rolam no servidor, atualizam PV sem passar do máximo e sincronizam a ficha/CBA quando há um token correspondente. Dano/CA e efeitos que dependem de resistência continuam sob confirmação/aplicação do Mestre.

**Limitações de regras:** espaços de domínio do Clérigo não são incluídos porque não há seleção de domínio na ficha. A migração semeia apenas 13 magias iniciais (truques e magias de 1º círculo); o restante depende do conteúdo já existente em `srd_spells` ou de uma carga adicional. Não há ainda controle automatizado de componentes, resistência/CD, duração, concentração, condições ou efeitos de magias utilitárias.

As progressões e regras foram conferidas com as páginas SRD indicadas em `srd35_spellcasting_sources.md`. A fórmula de ataque mágico acima é uma regra de mesa pedida pelo usuário, não uma descrição da regra geral de ataque mágico do SRD 3.5.

## Bestiário, menu contextual e combate

O botão **+ Monstros** do Mestre consulta `srd_monsters`, com busca/filtro, cartões e ações para adicionar a criatura ou publicar seu bloco técnico no chat. O token adicionado preserva o ID SRD, estatísticas, PV máximo/atual e URL de fonte; clicar com o botão direito no token de monstro também pode publicar suas informações. O Mestre pode clicar no token para abrir opções de ataque manual, ajuste de PV e publicação da ficha. O ataque de uma criatura abre uma rolagem de d20 para o Mestre; o bônus, alvo, CA e dano continuam sob resolução do Mestre, sem aplicação automática. O ajuste de PV continua sujeito à autorização de Mestre no servidor.

Ao clicar no próprio token, o jogador encontra atalhos para ataque corpo a corpo, ataque à distância, conjuração e inventário da ficha selecionada. Os tokens aceitam teclado; Escape fecha o menu e devolve o foco. O clique/arraste e o botão de PV não se sobrepõem: o ajuste de PV do Mestre está no menu contextual (o duplo clique legado também permanece).

O CBA usa quadrados de 1,5 m, encaixe no grid, suporte a toque/zoom e barras de PV. Durante o próprio turno, o jogador vê uma prévia do movimento racial acumulado; exceder o deslocamento aparece em vermelho, mas a RPC continua sendo a validação autoritativa. O painel de economia mostra ação padrão, movimento e ação rápida do turno. Ataques e magias consomem atomicamente a ação padrão; movimentação é contabilizada pela RPC existente, e o consumo não é reiniciado por renderizações do navegador. A iniciativa de NPCs/monstros usa `1d20 + DES`; jogadores rolam manualmente `d20 + DES`, com talentos aplicáveis.

O Mestre pode entregar itens do catálogo ao inventário SRD. A ficha lê armas/armaduras equipadas para exibir CA, bônus de ataque e dado de dano; ataques à distância verificam alcance conhecido. Poção de cura consome uma unidade, rola `2d4+2` e não ultrapassa o PV máximo.

## Biblioteca SRD

No lobby, clique em **Biblioteca SRD** no menu lateral esquerdo — logo abaixo de **Minhas Fichas** — para abrir diretamente o compêndio. O botão **Abrir Biblioteca SRD · D&D 3.5** também continua disponível em **Livros**. A Biblioteca pesquisa monstros, magias, equipamentos e classes, pagina os resultados, filtra por categoria, mostra blocos técnicos e abre a fonte SRD em nova aba. Os dados são renderizados como texto seguro.

O compêndio inclui dez criaturas canônicas iniciais, não o bestiário completo do SRD. “Rato atroz (rato gigante)” usa o bloco oficial **Dire Rat**; dados de rato comum foram descartados. O compêndio não cria conteúdo completo para todos os itens, magias ou classes.

## Licença e atribuição

As descrições em português incluídas são paráfrases; os valores de jogo mantêm referências às fontes. O pacote contém o texto da OGL 1.0a em `OPEN_GAME_LICENSE_1.0a.txt` e notas/fontes do compêndio e da conjuração em `srd35_compendium_sources.md` e `srd35_spellcasting_sources.md`. Confira o aviso de copyright/licença antes de redistribuir fora do seu projeto.

## Validação

Passaram localmente: parse de HTML e JavaScript inline com Node/HTMLParser; parse PostgreSQL das migrações de conjuração e economia de ações com `pglast`; smoke tests Playwright com Supabase simulado da ficha (carregar, abrir Grimório e conferir payload RPC) e da mesa (conjurar via wrapper, conferir economia de ações, abrir menus por papel, carregar bestiário, publicar estatísticas, adicionar token e validar alerta de movimento racial acima de 9 m). Estes testes não acessam nem comprovam o banco, os dados ou as permissões de produção.
