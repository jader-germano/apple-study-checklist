# Faça e Não Faça do Produto

## Faça

- Manter o produto como `local-first`
- Preferir fluxos explícitos em vez de automação escondida
- Tornar o estado de progresso visível e reversível
- Manter edições em Markdown com preview antes do save
- Preservar a sensação de um único produto entre plataformas, adaptando apenas o
  modelo de interação
- Brokerar acesso a providers por backend autenticado em vez de embutir secrets
  no app
- Manter níveis de permissão explícitos antes de liberar revisão ou execução
- Preferir estados explícitos de `fileSync` e `versionSync` em vez de overwrite
  silencioso
- Extrair o conceito de produto do `FrankMD` sem herdar o web app como
  superfície de runtime
- Manter contratos de domínio reaproveitáveis para Android e Windows no futuro
- Usar mount curado ou read-only em companions quando o objetivo não exigir
  edição completa

## Não faça

- Transformar o app em editor de notas genérico sem fluxos orientados a estudo
- Esconder versionamento futuro atrás de commits automáticos
- Misturar experimentos de roadmap com fluxos centrais de estudo na mesma
  superfície
- Depender de MCP para casos básicos de leitura e edição
- Criar definições separadas de produto para macOS e iOS quando o domínio é o
  mesmo
- Guardar chaves de `OpenAI`, `Anthropic` ou outros providers diretamente no app
  do iPhone
- Auto-merge de arquivos remotos sem estado de conflito ou visibilidade de
  versão
- Liberar sessões de execução sem perfil salvo de sandbox ou permissão
- Portar a UI Rails do `FrankMD` diretamente para o app
- Deixar Android ou Windows divergirem da mesma semântica de vault e sync
- Tratar um wrapper local como substituto de isolamento real de dados

## UI: Faça

- Manter a navegação principal rasa
- Deixar o contexto de estudo selecionado óbvio
- Expor o estado de save perto do editor
- Favorecer tipografia legível e espaçamento estável em vez de densidade

## UI: Não faça

- Sobrecarregar a tela de checklist com controles que pertencem só ao editor
- Copiar split panes de desktop diretamente para layouts compactos no iPhone
- Assumir que visionOS deve espelhar o desktop um para um
- Tratar dark mode como simples inversão em vez de decisão de design
