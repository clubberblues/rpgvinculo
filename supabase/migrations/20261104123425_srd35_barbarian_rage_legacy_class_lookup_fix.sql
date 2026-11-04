-- Garante que o fallback de ficha legada use o ID persistido 'barbaro'.
-- Não usa _srd35_class_key(nome), pois nomes localizados não são normalizados por esse helper.
COMMENT ON FUNCTION public.usar_furia_barbaro_srd(text,text) IS 'Fúria SRD 3.5: níveis efetivos lidos por class_key; fallback legado identifica a classe primária pelo ID barbaro.';
COMMENT ON FUNCTION priv.srd_end_barbarian_rage(bigint,text,boolean) IS 'Fúria SRD 3.5: encerramento usa a mesma leitura de nível efetivo e fallback legado pelo ID barbaro.';
