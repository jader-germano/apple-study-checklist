# Padrão de Idioma e Escrita

- Categoria: `reference`
- Escopo: `repository`

## Regra principal

Este repositório adota a seguinte separação:

- documentação em `pt-BR`
- código em inglês
- UI apresentada no idioma selecionado pelo usuário

## Documentação

Vale para:

- `README.md`
- pasta `docs/`
- artigos DocC narrativos
- handoffs, briefs e documentação de arquitetura, produto, design, engenharia e referência

Regras:

- escrever a narrativa em `pt-BR`
- manter nomes técnicos de código como símbolos em inglês, entre crases
- evitar misturar títulos em inglês quando houver equivalente claro em `pt-BR`
- ao tocar um documento já misto, normalizar pelo menos a seção alterada

## Código

Vale para:

- nomes de arquivo
- tipos, protocolos, enums e propriedades
- testes
- contratos e modelos técnicos
- comentários de código, quando necessários

Regras:

- usar inglês como idioma padrão
- não transformar texto de UI em contrato técnico
- manter nomes estáveis e claros para integração e rastreabilidade

## UI e apresentação

Regras:

- `pt-BR` só aparece quando esse idioma estiver selecionado
- `English` continua disponível como alternativa de interface
- conteúdo localizado deve entrar por camada de apresentação, vault ou strings localizáveis

## Aplicação prática

Ao criar uma nova fatia:

1. escrever docs da fatia em `pt-BR`
2. manter código e testes em inglês
3. localizar texto de UI sem vazar idioma de apresentação para o domínio
4. atualizar a documentação tocada para reduzir mistura residual
