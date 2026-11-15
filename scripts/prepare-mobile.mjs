import { cp, mkdir, rm } from 'node:fs/promises';
import { resolve } from 'node:path';

const root = process.cwd();
const webDir = resolve(root, 'www');
const files = [
  'index.html',
  'lobby.html',
  'ficha.html',
  'mesa.html',
  'dice.html',
  'vinculo-ui.css',
  'vinculo-ui.js',
  'friends-vtt-ui.js',
  'fundo-livro.png',
  'capa-mestre.png',
  'capa-jogador.png',
  'capa-monstros.png',
  'capa-mundo.png'
];

await rm(webDir, { recursive: true, force: true });
await mkdir(webDir, { recursive: true });
for (const file of files) {
  await cp(resolve(root, file), resolve(webDir, file));
}
console.log('Pacote web Android preparado: ' + files.length + ' arquivos em www/.');
