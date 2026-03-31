# ThemeKit — Integração e Contrato de Uso

## Origem

`ThemeKit.swift` foi adaptado a partir de um vocabulário de tokens já usado em
outro app Apple-platform do mesmo workspace.

O objetivo aqui não é preservar um path ou branch externos como contrato do
repositório, e sim documentar como os tokens foram reduzidos e reinterpretados
para este app.

Adaptações realizadas:
- Bloco `AIProvider.themeColor` removido (dependia de tipos exclusivos do PiPhone).
- Tokens de study adicionados: `progressActive`, `progressComplete`,
  `progressLocked`, `progressGreen`.
- Helper estático `Theme.progressTint(for:)` adicionado.

Localização no projeto: `Sources/AppleStudyChecklist/Design/ThemeKit.swift`

---

## Contrato de uso

Este projeto é nativo Apple (iOS 17+ / macOS 14+), com suporte a `light`, `dark` e `automatic`.
ThemeKit é um vocabulário de tokens — **não é um tema visual completo para Views adaptativas**.

### Tokens seguros em contexto adaptativo (light + dark)

Estes tokens têm contraste suficiente como `tint`, ícone ou badge em ambos os modos:

| Token | Valor | Uso correto |
|---|---|---|
| `Theme.accent` | `#F97316` laranja | `.tint()`, ícones de destaque, botões primários |
| `Theme.accentHi` | `#F59E0B` âmbar | gradientes de acento, segundos planos de badge |
| `Theme.sea` | `#2DD4BF` teal | ícones de conclusão, badges de sucesso |
| `Theme.steel` | `#60A5FA` azul | ícones informativos, badges de provider |
| `Theme.purple` | `#A78BFA` — | badges de destaque secundário |
| `Theme.red` | `#FB7185` — | erros, alertas críticos |
| `Theme.progressActive` | alias de `accent` | `.tint()` em ProgressView com progresso parcial |
| `Theme.progressComplete` | alias de `sea` | `.tint()` em ProgressView 100% + ícones de check |
| `Theme.progressLocked` | `white × 0.20` | `.tint()` em ProgressView sem progresso |
| `Theme.progressGreen` | `#34D399` | badge de semana concluída (fundo tonal escuro/claro) |
| `Theme.progressTint(for:)` | helper | tint calculado para ProgressView conforme ratio |

### Tokens reservados — dark-first, não usar em Views adaptativas

Estes tokens são hardcoded para fundos escuros. Usar em Views que suportam
`light` quebra hierarquia e legibilidade.

| Token | Motivo da restrição |
|---|---|
| `Theme.bg`, `Theme.surface`, `Theme.elevated` | Fundos escuros fixos — invisíveis em light |
| `Theme.textPrimary`, `Theme.textSecondary`, `Theme.textMuted` | Branco com opacidade — legível só em dark |
| `Theme.border`, `Theme.borderStrong` | Branco com baixa opacidade — invisível em light |

Estes tokens serão úteis quando as superfícies de sessão LLM (Antigravity)
forem implementadas com modo dark explícito, ou para componentes de
overlay com `colorScheme(.dark)` forçado.

---

## Regras de uso em Views nativas Apple

```
✅  ProgressView(value: p).tint(Theme.progressTint(for: p))
✅  Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.progressComplete)
✅  .tint(Theme.accent)                         // no root view
✅  .foregroundStyle(Theme.accent)              // ícone de destaque dentro de List row

❌  .foregroundStyle(Theme.textSecondary)       // use .foregroundStyle(.secondary)
❌  .background(Theme.surface)                  // use .background(.fill) ou GroupBox
❌  RoundedRectangle(...).stroke(Theme.border)  // use .background(.thinMaterial)
```

### Texto — sempre semântico

```swift
// Correto — adapta automaticamente a light/dark
Text(week.title).foregroundStyle(.secondary)

// Errado — branco não funciona em light mode
Text(week.title).foregroundStyle(Theme.textSecondary)
```

### Containers e fundos — sempre system materials

```swift
// Correto
GroupBox { ... }
.listRowBackground(Color(.systemGroupedBackground))
.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

// Errado
.background(Theme.surface)
```

### ProgressView — único ponto de tint explícito

```swift
ProgressView(value: store.progress(for: week))
    .tint(Theme.progressTint(for: store.progress(for: week)))
```

---

## Padrão de aplicação por view

### WeekRowView (lista de semanas)

```swift
// ProgressView com tint de estado
ProgressView(value: progress)
    .tint(Theme.progressTint(for: progress))

// Ícone de conclusão quando 100%
if progress >= 1.0 {
    Image(systemName: "checkmark.circle.fill")
        .foregroundStyle(Theme.progressComplete)
}
```

### WeekDetailView (header da semana)

```swift
ProgressView(value: store.progress(for: week))
    .tint(Theme.progressTint(for: store.progress(for: week)))
```

### DayCardView (card de dia)

```swift
// Badge de progresso completo
if completedCount == totalCount {
    Image(systemName: "checkmark.seal.fill")
        .foregroundStyle(Theme.progressComplete)
}
```

### Root view

```swift
// Define o accent color do app inteiro via SwiftUI tint
ContentView(store: store)
    .tint(Theme.accent)
```

---

## Tokens reservados para o LLM session hub (futuro)

Quando a superfície de sessão Antigravity for implementada — e tiver
`colorScheme(.dark)` explícito — os tokens dark-first passam a ser seguros:

```swift
// Exemplo: painel de sessão com dark mode forçado
AntigravitySessionView()
    .colorScheme(.dark)
    // Aqui sim: Theme.surface, Theme.textSecondary, Theme.border são seguros
```

Os tokens de provider já estão prontos para esse momento:
- `Theme.colorClaude` — `#FDBA74`
- `Theme.colorGPT` — `#60A5FA`
- `Theme.colorGemini` — `#A7F3D0`
- `Theme.colorLocal` — `#2DD4BF`

---

## Referências

- `Sources/AppleStudyChecklist/Design/ThemeKit.swift` — fonte canônica dos tokens
- `docs/design/system-ui-ux-spec.md` — direção visual e regras de plataforma
- `docs/architecture/antigravity-session-hub.md` — onde os tokens dark-first serão usados
