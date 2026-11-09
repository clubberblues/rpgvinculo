# Snapshot de Storage — 2026-11-09

> Inventário somente de configuração. Não foram consultados nem exportados objetos/arquivos de usuários, nomes de arquivos armazenados ou conteúdo de Storage.

## Buckets

| Bucket | Público | Limite | MIME permitidos |
|---|---:|---:|---|
| `mesa-media` | não | 50 MiB | JPEG, PNG, GIF, WebP, AVIF, SVG, MP4, WebM, MPEG audio, OGG, WAV |
| `midia` | sim | sem limite configurado | sem allowlist configurada |

## Policies em `storage.objects`

| Policy | Bucket | Papel | Operação | Condição |
|---|---|---|---|---|
| `mesa_media_ler` | mesa-media | authenticated | SELECT | `can_read_media(name)` |
| `mesa_media_enviar` | mesa-media | authenticated | INSERT | `priv.pasta_gm(name)` |
| `mesa_media_trocar` | mesa-media | authenticated | UPDATE | `priv.pasta_gm(name)` em USING e WITH CHECK |
| `mesa_media_apagar` | mesa-media | authenticated | DELETE | `priv.pasta_gm(name)` |
| `midia read` | midia | PUBLIC | SELECT | `bucket_id='midia'` |
| `midia_insert_scoped` | midia | authenticated | INSERT | `priv.can_write_midia(name)` |
| `midia_update_scoped` | midia | authenticated | UPDATE | `priv.can_write_midia(name)` em USING e WITH CHECK |
| `midia_delete_scoped` | midia | authenticated | DELETE | `priv.can_delete_midia(name)` |

## Regras de caminho observadas

- `priv.can_write_midia` valida o usuário autenticado e caminhos de avatar, retrato, cabeçalho, capa de mesa e mídia da campanha.
- Avatares usam `avatars/<user_id>/...`; retratos e cabeçalhos usam prefixos com ID do personagem e verificam `characters.user_id`.
- Capas `capas_mesas/mesa-<id>-...` exigem `campaigns.owner_id` e bloqueiam escrita quando a campanha está em limpeza de exclusão.
- Mídia `campaigns/<id>/...` permite owner ou GM da campanha e bloqueia operações durante limpeza de exclusão.
- `priv.can_delete_midia` também permite ao owner concluir a remoção de caminhos de campanha/capa durante a saga de exclusão, consultando `priv.campaign_deletion_cleanup`.
- `priv.pasta_gm` resolve o primeiro segmento da pasta como campaign_id e exige `public.my_role(id)='GM'`.
- `can_read_media` é usado pela policy privada de leitura de `mesa-media`; o bucket `midia` é público para leitura.

## Riscos e decisões pendentes

1. `midia` é público, sem limite de tamanho e sem allowlist MIME no bucket. As policies restringem os caminhos de escrita, mas não restringem tipo de conteúdo ou tamanho. Confirmar se essa abertura é intencional e se os uploads são sempre imagens/arquivos esperados.
2. `mesa-media` aceita SVG e mídia de áudio/vídeo até 50 MiB. Confirmar que o frontend realmente precisa de todos esses MIME types e que consumo/visualização é seguro.
3. Não mudar bucket, políticas ou allowlists sem revisar uploads existentes, URLs públicas, compatibilidade do frontend e fluxo de exclusão.
4. O bucket `midia` público pode expor permanentemente os objetos cujos caminhos sejam conhecidos; isso é característica do bucket e não deve ser confundido com o acesso privado de `mesa-media`.
5. A saga de exclusão de campanha continua dependente do browser para remover objetos do Storage entre prepare e finalize; os helpers de caminho bloqueiam gravações/exclusões fora do escopo, mas não fornecem worker de recuperação autônomo.

## Limites

- Este snapshot não contém linhas de `storage.objects`, IDs de arquivos, nomes de objetos, URLs privadas, nem conteúdo de usuários.
- As policies e funções estão registradas aqui para comparação. A definição completa das funções também consta nos snapshots SQL de `public` e `priv`.
- Não houve alteração de bucket, policy, ACL ou arquivo.
