# Aplicativo Android — Vínculo RPG

O projeto Android empacota as páginas atuais do VTT localmente com Capacitor. Login, campanhas, fichas, mesa, dados e demais dados continuam usando o mesmo projeto Supabase; não há um segundo banco nem cópia de contas.

## Gerar APK automaticamente

O workflow `.github/workflows/android-apk.yml` é executado quando os arquivos do aplicativo mudam na branch `main`, ou manualmente em **GitHub → Actions → Build Android APK → Run workflow**.

Ao terminar com sucesso, abra a execução e baixe o artefato **Vinculo-Android-APK**. O arquivo dentro do ZIP é `app-debug.apk`, instalável para testes em Android.

## Gerar localmente

Requisitos: Node.js 22+, JDK 21 e Android Studio/Android SDK configurado.

```bash
npm install
npm run mobile:prepare
npx cap add android
npx cap sync android
cd android
./gradlew assembleDebug
```

No Windows, use `gradlew.bat assembleDebug`.

## Conteúdo incluído

O script `scripts/prepare-mobile.mjs` copia as páginas ativas, scripts, estilos e imagens locais para `www/`. O Capacitor usa esses arquivos embarcados no APK, em vez de abrir o site hospedado dentro de uma aba do navegador. O backend Supabase e os serviços externos continuam acessados pela internet.

## Observações

- Esta primeira entrega gera um APK **debug** para instalação e testes; ainda não é uma versão assinada para distribuição pública na Play Store.
- O aplicativo não força orientação fixa: telas como a mesa podem usar o modo horizontal, enquanto login, lobby e ficha continuam podendo ser usados na vertical.
- A primeira inicialização e os recursos que dependem do Supabase exigem conexão com a internet.
