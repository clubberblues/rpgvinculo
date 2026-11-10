-- Compatibilidade de Fúria com fichas antigas e progressão multiclasse.
-- O motor consulta class_key='barbarian' no registro por classe e usa classe primária
-- barbaro + nível total somente quando não existe nenhum registro de trilha.
COMMENT ON FUNCTION public.usar_furia_barbaro_srd(text,text) IS 'Fúria SRD 3.5: nível efetivo de Bárbaro vem da trilha por classe; fallback legado apenas para ficha monoclasses sem trilha.';
COMMENT ON FUNCTION priv.srd_end_barbarian_rage(bigint,text,boolean) IS 'Encerramento da Fúria: remove o bônus de PV derivado de Constituição e aplica fadiga quando aplicável.';
