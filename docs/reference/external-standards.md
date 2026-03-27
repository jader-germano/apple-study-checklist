# Padrões Externos

- Categoria: `reference`
- Escopo: `repository`

## Hierarquia da documentação

Este repositório segue uma hierarquia orientada por categoria inspirada em Diataxis:

- manter tutoriais, guias práticos, referência e explicação separados quando o conjunto crescer
- usar landing pages para cada seção
- dividir listas longas em grupos menores

Para este repositório, as categorias adaptadas são `product`, `design`, `engineering`, `architecture`, `api` e `reference`.

## API docs

Para packages Swift e código de plataformas Apple, o caminho preferido de API docs é DocC:

- manter uma página de visão geral
- adicionar artigos focados para contratos por feature
- conectar a documentação a símbolos e tipos conforme a superfície ficar mais explícita

Para portais maiores de documentação multi-sistema no futuro, estas opções distribuídas em npm foram identificadas via MCP:

- `docusaurus-plugin-openapi-docs`
- `redocusaurus`

Essas são opções futuras de portal, não dependências atuais do repositório.

## Regra de rastreabilidade

Uma árvore grande de documentação só continua navegável se cada documento importante conseguir responder:

1. a que categoria ele pertence
2. qual escopo ele cobre
3. que código ele descreve
4. que testes o verificam
5. que API docs o espelham
