# Padrões do Projeto

## Forma do produto

- Um produto
- Um repositório
- Camada compartilhada de domínio e conteúdo
- Adaptações de UI por plataforma quando necessário

## Padrões de arquitetura

### Modelo de domínio primeiro

- `Models.swift` continua como contrato estável para planos de estudo, dias, tarefas, labels e arquivos do vault.
- Loaders de Markdown e serviços do vault devem mapear para o modelo de domínio em vez de inventar estruturas específicas de UI.

### Store como fronteira de comportamento

- `StudyStore` é dono do progresso do checklist, do estado do workspace, da aparência e das decisões de integração do vault.
- `StudyVaultLoader` é dono do mapeamento de Markdown para modelo.
- Comportamentos futuros específicos de Git devem ir para uma fronteira de serviço dedicada, em vez de crescer dentro das views.

### Views enxutas

- Views SwiftUI devem compor layout e bindar estado.
- Parsing, navegação de filesystem e lógica de persistência não devem crescer dentro do corpo das views.

### Costuras de serviço para testabilidade

- Operações de filesystem devem ficar isoladas atrás de helpers ou tipos de serviço.
- Nova lógica de importação de Markdown deve nascer atrás de uma costura de provider antes da integração com UI.
- Fluxos futuros de versionamento devem ser abstraídos o bastante para rodar contra repositórios temporários em testes.

### Adaptadores de plataforma

- APIs específicas de macOS devem ficar isoladas.
- Suporte a iOS e visionOS deve entrar trocando adaptadores de plataforma, não duplicando o app.

## Padrão de idioma

- documentação do repositório em `pt-BR`
- código-fonte, nomes de tipos, enums, testes e contratos em inglês
- strings de UI localizadas por idioma selecionado
- comentários de código em inglês quando forem necessários
- nomes técnicos referenciados em docs devem permanecer como símbolos em inglês, entre crases

## Faça

- Reutilize a camada compartilhada de modelo
- Prefira serviços pequenos com um único motivo para mudar
- Mantenha ações do vault explícitas e visíveis
- Versione mudanças de Markdown de forma intencional
- Documente todo desvio arquitetural

## Não faça

- Não bifurque o produto em apps separados para iPhone, iPad e macOS
- Não coloque regras de carregamento de arquivo dentro de `ContentView`
- Não deixe o texto de UI virar contrato de armazenamento
- Não una redesign de UI e redesign de storage na mesma fatia quando puder separá-los
- Não introduza padrões específicos de visionOS no fluxo compartilhado sem um adaptador dedicado
