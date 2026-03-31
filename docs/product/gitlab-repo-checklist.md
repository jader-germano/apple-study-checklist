# Checklist de Repositório GitLab

- Categoria: `product`
- Escopo: `repository`

## Objetivo

Manter o `apple-study-checklist` operando com governança e CI/CD no `GitLab`
sem acoplar o produto agora a uma VPS nem a uma lane de publicação Apple que
continua bloqueada pela ausência de `Apple Developer`.

## Prioridade real do produto

A prioridade atual é o próprio checklist Apple.

Isso significa:

- consolidar qualidade de repositório, fluxo Git e rastreabilidade no `GitLab`
- manter o app evoluindo até o bloqueio real de distribuição externa
- adiar a trilha de publicação `App Store` e `TestFlight` até existir conta de
  `Apple Developer`
- manter qualquer vínculo com VPS como uma trilha paralela de serviços, não do
  app em si

## Estado validado em 2026-03-30

Já existe no `GitLab`:

- projeto público `jader-germano/apple-study-checklist`
- `main` protegida
- `develop` publicada
- branches `feature/*` operacionais
- remoção automática da source branch após merge habilitada
- bootstrap de CI em `.gitlab-ci.yml`
- gate inicial de qualidade Swift com `SwiftLint`

Ainda não existe no `GitLab`:

- approval rule mínima para `main`
- `only_allow_merge_if_pipeline_succeeds = true`
- variáveis de `CI/CD`
- environments
- pipelines de `Swift`, `xcodebuild` ou `DocC`
- runner macOS dedicado
- lane de `App Store` ou `TestFlight`

## Checklist de governança

### Fechado agora

- `origin` operando no `GitLab`
- `github` preservado como remoto secundário
- fluxo `feature/* -> develop -> main`
- branch `main` protegida
- credential helper do repositório operando via `glab auth git-credential`

### Pendente curto prazo

- criar approval rule mínima para merge em `main`
- proteger `develop` depois que a rotina de merge estabilizar
- ativar `only_allow_merge_if_pipeline_succeeds` quando o bootstrap CI estiver
  verde de forma consistente
- decidir se labels e templates de merge request precisam ser recriados no
  `GitLab`

## Checklist de pipeline do checklist

### Fase 1. Agora, sem runner macOS

Escopo permitido:

- contrato do repositório
- rastreabilidade documental
- checagens leves de estrutura e fluxo
- gates de merge e governança

Jobs adequados:

- presença dos arquivos obrigatórios do repositório
- coerência mínima entre os documentos de produto ligados ao `GitLab`
- validação do fluxo GitLab em `feature/*`, `develop` e `main`
- lint estático de Swift com saída nativa para `GitLab Code Quality`

## Checklist de qualidade Swift

### Fechado agora

- `SwiftLint` integrado ao `GitLab CI`
- job `swiftlint_quality` publicando `gl-code-quality-report.json`
- job `swiftlint_quality` também emitindo `sonar-swiftlint-report.json`
- configuração inicial focada em regressão real, excluindo artefatos gerados e
  ruído histórico

### Papel desse gate

No curto prazo, `SwiftLint` cumpre o papel mais próximo de um `Sonar` pragmático
para Swift dentro desta esteira:

- análise estática rápida
- feedback em merge request
- padronização de maintainability findings
- base para futura importação em `Sonar`, se for desejado um dashboard central

### Pendente quando existir runner macOS

- `swiftlint analyze` com contexto mais rico de toolchain
- cobertura com `xcodebuild` + `profdata`
- build iOS host com `xcodebuild`
- `DocC` em CI
- possível endurecimento do gate com regras adicionais ou `SwiftFormat --lint`

### Fase 2. Quando existir runner macOS

Escopo a abrir:

- `swift test`
- `swift test --parallel`
- `xcodegen generate`
- `xcodebuild` do host iOS
- `docbuild` do catálogo `DocC`

Pré-condição crítica:

- runner macOS próprio registrado no `GitLab`, porque o app depende de `Xcode`
  e de ferramentas Apple que não fecham no runner Linux padrão

## Checklist de publicação Apple

### Fora do escopo agora

Não abrir ainda:

- `fastlane match`
- `fastlane deliver`
- `fastlane pilot`
- archive assinado para `App Store Connect`
- secrets de `App Store Connect`

Motivo:

- ainda não existe conta de `Apple Developer` para publicação real

### Próximo gate real

Assim que a conta existir:

- definir bundle e release contract
- criar lane manual de archive/TestFlight
- adicionar secrets protegidos para distribuição
- revisar assinatura, provisioning e export options

## Trilha paralela de VPS

O vínculo com VPS deve existir, mas fora do `apple-study-checklist`.

Referência operacional atual:

- `pi-local-app` já usa `ssh-agent` + `rsync/scp` + `systemctl restart` + smoke
  test `/health`
- esse padrão deve ser reaproveitado para serviços server-side no `GitLab`
- o checklist Apple continua `local-first` e não deve depender de deploy em VPS
  para evoluir

## Próximos passos recomendados

1. manter este bootstrap CI no repositório
2. ativar `only_allow_merge_if_pipeline_succeeds` depois de validar alguns runs
3. preparar um runner macOS dedicado para a fase real de build/test do app
4. só abrir trilha `App Store` quando a conta `Apple Developer` existir
5. tratar a integração com VPS como backlog separado de serviços
