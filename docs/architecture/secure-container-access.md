# Acesso Seguro ao Container no iPhone

- Categoria: `architecture`
- Escopo: `feature`

## Objetivo

Permitir que o app no iPhone leia e, depois, edite arquivos do vault que vivem dentro de um container de forma segura, sem expor acesso bruto ao filesystem do host ou do container.

## Diretriz principal

O iPhone não deve acessar o filesystem do container diretamente.

A forma segura é expor um gateway de aplicação com autenticação, autorização e escopo de diretório, e deixar o app consumir esse gateway como uma fonte remota opcional de vault.

Para uso desktop companion com `FrankMD`, a mesma lógica vale:

- não montar o workspace inteiro por padrão
- preferir recorte curado do vault
- preferir leitura em modo somente leitura quando o objetivo for consulta

## Modelo recomendado

### 1. Gateway remoto de vault

Criar um serviço HTTP pequeno, na mesma VPS ou no mesmo host do container, responsável por:

- listar arquivos autorizados
- ler conteúdo Markdown
- salvar arquivos em caminhos permitidos
- bloquear qualquer caminho fora do root configurado
- registrar operações sensíveis

### 2. Escopo de acesso

O gateway deve trabalhar com um root explícito, por exemplo:

- `/app/notes`
- `/app/vault`

Nada fora desse root deve ser acessível, mesmo se o cliente enviar path traversal ou caminhos absolutos.

Esse princípio também se aplica ao companion local em Docker: o mount precisa
ser menor que o workspace sempre que isso for viável.

### 3. Segurança mínima

- autenticação por token curto ou sessão autenticada
- TLS obrigatório
- allowlist de diretórios
- auditoria de leitura e escrita
- separação entre modo leitura e modo edição
- mount curado ou read-only quando o consumo for indireto via companion

### 4. Modelo no app

O `StudyStore` deve tratar essa origem como uma nova fonte:

- `vault embutido`
- `vault local editável`
- `pasta externa`
- `vault remoto do container`

O comportamento padrão continua local-first. A fonte remota é opcional.

## Fatias de implementação

### Fase 1. Leitura remota segura

- listar arquivos
- abrir arquivo
- mostrar origem remota no app
- modo somente leitura

### Fase 2. Edição remota segura

- salvar arquivo
- sinalizar conflito de versão
- registrar último sync e resultado

### Fase 3. Operação confiável

- refresh manual
- retry explícito
- fallback para conteúdo local já carregado
- auditoria de ações

## Riscos a evitar

- montar volume bruto do container no iPhone
- montar o root inteiro do workspace num companion quando um recorte resolve
- expor Docker socket
- usar compartilhamento SMB/SFTP sem escopo por app
- deixar o app navegar livremente pelo filesystem do host
- acoplar leitura básica do app a essa origem remota

## Observação sobre sandbox

Sandbox do shell ou do cliente ajuda no bootstrap e no comando executado, mas
não substitui o isolamento real depois que o Docker sobe o container.

Para este cenário, a proteção mais importante continua sendo:

- escopo do diretório montado
- modo read-only quando possível
- gateway autenticado para acesso remoto

## Rastreabilidade

Código que deve evoluir nesta fatia:

- `Sources/AppleStudyChecklist/Models.swift`
- `Sources/AppleStudyChecklist/StudyStore.swift`
- `Sources/AppleStudyChecklist/StudyVaultLoader.swift`
- `Sources/AppleStudyChecklist/ContentView.swift`

Testes esperados quando a implementação começar:

- `Tests/AppleStudyChecklistTests/Integration/VaultWorkspaceFlowTests.swift`
- nova suite para cliente remoto e autorização de paths

Documentos relacionados:

- `docs/api/vault-workspace-api.md`
- `docs/architecture/system-overview.md`
- `docs/product/roadmap.md`
