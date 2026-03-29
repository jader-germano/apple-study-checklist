# Antigravity Session Hub

## Visão geral

O `Antigravity session hub` é a fronteira planejada de feature que traz para o app sessões de LLM autenticadas por navegador, memória compartilhada do vault e estado de sync.

Ele foi pensado para suportar:

- ativação de providers como `Codex`, `Claude` e `Gemini`
- login por navegador no backend `Antigravity`
- memória compartilhada ancorada no vault Markdown
- sync explícito por arquivo e versão entre dispositivos

## Restrições principais

- chaves de API de provider não devem morar no app cliente
- o app deve autenticar contra `Antigravity`, não diretamente contra cada provider
- atualizações do vault devem continuar orientadas a arquivo e conscientes de versão

## Documentação relacionada do repositório

- `docs/architecture/antigravity-session-hub.md`
- `docs/api/antigravity-session-api.md`
- `docs/reference/provider-auth-and-sync.md`
