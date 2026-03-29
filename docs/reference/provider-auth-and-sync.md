# Referências Oficiais para Auth e Sync

- Categoria: `reference`
- Escopo: `repository`

## Objetivo

Registrar as fontes oficiais que sustentam a decisão arquitetural do `Antigravity session hub`.

## Apple platform

### Browser sign-in

- `ASWebAuthenticationSession` / `WebAuthenticationSession`
- URL: `https://developer.apple.com/documentation/authenticationservices/webauthenticationsession`

Decisão:

- usar browser-based auth para login no `Antigravity`

### Armazenamento seguro de credenciais

- `Using the keychain to manage user secrets`
- URL: `https://developer.apple.com/documentation/security/using-the-keychain-to-manage-user-secrets`

Decisão:

- guardar credenciais de sessão do app no Keychain

### Coordenação e observação de arquivos

- `NSFileCoordinator`
- URL: `https://developer.apple.com/documentation/foundation/nsfilecoordinator`
- `NSFilePresenter`
- URL: `https://developer.apple.com/documentation/foundation/nsfilepresenter`

Decisão:

- tratar o vault como documentos coordenados, não como diretório bruto compartilhado sem mediação

### Versionamento de arquivo

- `NSFileVersion`
- URL: `https://developer.apple.com/documentation/foundation/nsfileversion`

Decisão:

- usar `versionSync` para preservar histórico e conflito, em vez de overwrite silencioso

## LLM providers

### OpenAI

- URL: `https://developers.openai.com/api/reference/overview/#authentication`

Resumo:

- a documentação oficial usa API keys
- a própria documentação diz para não expor a chave em código client-side, browsers ou apps

Decisão:

- `OpenAI` deve ficar atrás do backend `Antigravity`

### Anthropic

- URL: `https://docs.anthropic.com/en/api/getting-started`

Resumo:

- a documentação oficial usa `x-api-key` e versionamento de API por header

Decisão:

- `Anthropic` também deve ficar atrás do backend `Antigravity`

### Gemini

- URL: `https://ai.google.dev/gemini-api/docs/oauth`
- URL: `https://ai.google.dev/gemini-api/docs/api-key`

Resumo:

- a documentação oficial oferece caminhos com API key e OAuth

Decisão:

- mesmo com suporte a OAuth, a experiência do app continua mais coerente se `Gemini` também entrar pelo `Antigravity`

## Conclusão arquitetural

O app móvel deve:

- autenticar no `Antigravity` via browser
- guardar só credenciais do app no Keychain
- manter provedores LLM escondidos atrás do backend
- sincronizar o vault por arquivo e versão
- manter histórico e conflito visíveis
