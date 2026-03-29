# Antigravity Session Hub

- Categoria: `architecture`
- Escopo: `system`

## Propósito

Definir a camada planejada que traz para o app uma sessão/menu de planejamento e revisão com LLMs, mantendo o vault como fonte compartilhada de memória e conteúdo.

O objetivo do produto é consolidar estudo, notas, planejamento e revisão assistida em um único app móvel, em vez de espalhar esse fluxo por múltiplos apps.

## Decisão principal

O iPhone não deve autenticar diretamente em `OpenAI` ou `Anthropic` com secrets do provedor embutidos no cliente.

A arquitetura preferida é:

1. `browserSignIn` para o backend `Antigravity`
2. `Antigravity` como broker autenticado para provedores como `Codex`, `Claude` e `Gemini`
3. tokens de sessão do app armazenados no Keychain
4. vault Markdown sincronizado por arquivo e versão, não por acesso bruto ao filesystem

## Etapa prévia obrigatória

Antes da implementação das quatro fases, esta arquitetura pede uma etapa prévia de prototipação.

Essa etapa existe para validar:

- o lugar do menu de sessões dentro do app
- a relação entre vault local, vault compartilhado e sessão ativa
- os estados de `fileSync`, `versionSync`, conflito e histórico
- a adaptação cross-platform sem quebrar o modelo local-first

Sem esse protótipo, o risco é codificar cedo demais uma navegação errada para a entrega.

## Fronteiras planejadas

### Session menu

Responsabilidades:

- mostrar provedores disponíveis
- exibir sessões ativas e paralelas
- expor nível de permissão antes de iniciar uma sessão
- mostrar se a memória compartilhada vem do vault local, remoto ou sincronizado

### Auth broker

Responsabilidades:

- iniciar login via browser
- trocar o callback autenticado por credenciais do app
- manter o cliente sem API keys sensíveis do provedor

### Session orchestration

Responsabilidades:

- criar sessões de planejamento e revisão
- associar a sessão a um perfil de permissão salvo
- ligar a sessão a um root de vault explicitamente autorizado

### Sync engine

Responsabilidades:

- manter working copy local
- sincronizar mudanças por `fileSync`
- manter histórico e conflito por `versionSync`
- evitar overwrite invisível entre dispositivos

## Escolhas validadas pela documentação

### Browser auth

No ecossistema Apple, o caminho correto para login via navegador no app é `ASWebAuthenticationSession`.

### Secrets

Credenciais persistidas no cliente devem ficar no Keychain.

### Provider auth

- `OpenAI`: documentação oficial exige API key e proíbe expor a chave em apps cliente
- `Anthropic`: documentação oficial usa `x-api-key` no request
- `Gemini`: a documentação oficial oferece caminhos com API key e OAuth

Inferência arquitetural:

Mesmo que `Gemini` tenha suporte a OAuth, o produto deve unificar a experiência no `Antigravity`, para manter um único modelo de sessão, permissão e auditoria.

### Sync e versionamento

Para arquivos locais sincronizados entre dispositivos, o desenho deve usar coordenação e versionamento de documento:

- `NSFileCoordinator`
- `NSFilePresenter`
- `NSFileVersion`

Isso é mais coerente com um vault Markdown do que tratar tudo como mensagens efêmeras de chat.

## Modelo de sync planejado

### fileSync

- working copy local no app
- refresh explícito
- save explícito
- status visível por arquivo

### versionSync

- revision ID local e remoto
- histórico de versões
- conflito detectado e resolvido na UI
- merge assistido só depois, nunca no primeiro corte

## Regras de segurança

- sem acesso direto do app ao filesystem do container host
- sem provider secret persistido no cliente
- sem sessão de execução sem perfil de permissão salvo
- sem atualização silenciosa de arquivo alterado por outro dispositivo

## Rastreabilidade

Docs relacionados:

- `docs/api/antigravity-session-api.md`
- `docs/architecture/secure-container-access.md`
- `docs/design/system-ui-ux-spec.md`
- `docs/design/figma-prototype-brief.md`
- `docs/reference/provider-auth-and-sync.md`

Código relacionado hoje:

- `Sources/AppleStudyChecklist/StudyStore.swift`
- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`
- `Sources/AppleStudyChecklist/ContentView.swift`

Status:

- arquitetura planejada
- sem implementação ainda
