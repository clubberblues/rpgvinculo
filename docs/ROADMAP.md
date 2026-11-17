# Roadmap — criação das fichas D&D 3.5

A execução permanece subordinada a `PROJECT_CHARTER.md`. O roadmap não autoriza automações fora do escopo.

## Fase 1 — Mago como ficha-modelo
- [x] Formalizar a especificação funcional da ficha do Mago.
- [~] Corrigir os dados básicos da escolha de familiar no código existente (a interface segue o SRD; falta atualizar a allowlist do RPC para aceitar Doninha).
- [~] Auditar os campos e etapas existentes de criação do Mago; o fluxo inicial foi mapeado e ajustado, mas ainda precisa de homologação no navegador.
- [~] Confirmar persistência/recarga das anotações de equipamento via JSONB; edição pós-criação aguarda RPC segura, pois `authenticated` não tem UPDATE direto na tabela.
- [~] Substituir o catálogo e estados de equipamento por campos livres repetíveis na criação; a ficha persistida já consulta esses registros, mas a edição posterior aguarda RPC segura.
- [~] Grimório inicial, especialização e escolas proibidas estão integrados/validados; escolha de Doninha aguarda correção da allowlist do servidor e a ficha completa do familiar ainda falta.
- [~] As etapas iniciais de identidade, atributos, perícias, talentos, idiomas e características estão presentes; falta concluir edição pós-criação consistente e homologação.
- [ ] Validar criação, saída, retorno, edição e abertura da ficha pelo token.

## Fase 2 — Ficha-base compartilhada
- [ ] Definir os campos comuns e seções condicionais.
- [ ] Garantir que raça, classe e nível apresentem apenas conteúdo pertinente.
- [ ] Definir padrão consistente de edição e persistência de cada seção.

## Fase 3 — Outras dez classes básicas
- [ ] Implementar e validar cada classe usando a ficha-base.
- [ ] Conferir progressões e escolhas nível a nível contra fontes D&D 3.5.

## Fase 4 — Validação integrada
- [ ] Testar personagem criado em mesa nova.
- [ ] Confirmar ficha do jogador editável e rolagem de dados.
- [ ] Confirmar clique no token abre a ficha correta para o Mestre.
- [ ] Verificar persistência e permissões.

## Fora deste roadmap
Motor de combate, execução de testes, conjuração automatizada, aplicação de efeitos, gerenciamento de turnos e automação de equipamentos.

### Bloqueios para concluir a Fase 1
- RPC dedicado para atualizar somente `identidade.equipment_notes`, sem conceder UPDATE amplo em `srd_character_sheets`.
- Migration para alinhar a allowlist de familiares do RPC ao SRD (`weasel` no lugar de `badger`).
- Teste autenticado em navegador cobrindo criação de Mago, gravação, recarga, consulta e edição.
