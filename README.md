# Pedidos Restaurante

Aplicativo Flutter para operacao de pedidos de restaurante, recriado a partir
do sistema Delphi/PHP legado.

## Plataformas

- Web/PWA mobile-first
- Android
- iOS
- Windows desktop

## Fluxo principal

1. Configurar servidor PHP.
2. Selecionar funcionario.
3. Selecionar ou consultar comanda.
4. Lancar produtos, acompanhamentos, adicionais e observacoes.
5. Enviar comanda para cozinha.
6. Acompanhar pedidos prontos e entregues.

## Teclado operacional

Quando a opcao `Teclado fisico` esta desligada, o app usa teclados proprios em
tela cheia, inspirados no app Delphi original:

- teclado numerico para funcionario, comanda, mesa, tag, quantidade e senha;
- teclado alfanumerico para produto, servidor, contexto e observacoes;
- acoes grandes de `limpar`, `listar`, `del`, `voltar` e `confirmar`.

Quando `Teclado fisico` esta ligado, os campos usam o teclado nativo do sistema.

## Base local

O projeto possui uma fundacao de base local em `lib/core/local` usando
`sembast`:

- Web/PWA: IndexedDB do navegador;
- Android/iOS/Windows: arquivo local no aparelho ou computador.

Essa camada ainda e uma base para cache/fila offline. Os repositorios principais
continuam integrados aos scripts PHP existentes.

## Versoes minimas

- Android: API 24 / Android 7.0 ou superior.
- iOS: iOS 13.0 ou superior.
- Windows: Windows 10 ou 11.
- Web/PWA: navegadores modernos com suporte atual do Flutter.

## Validacao

Comandos usados para validar:

```sh
flutter analyze
flutter test
flutter build web
flutter build windows
flutter build apk --debug
```

## Publicar PWA local de teste

Para compilar e copiar a versao Web/PWA para o Apache local:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\deploy_pwa.ps1
```

O script publica em:

```text
C:\httpd-2.4.46-win64-VS16\htdocs\pedidos-app
```

URL de teste:

```text
http://192.168.3.10/pedidos-app/
```
