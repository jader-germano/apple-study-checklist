import SwiftUI

enum Theme {
    enum ProgressPhase: Equatable {
        case locked
        case active
        case complete
    }

    // Background layers reserved for dark-only surfaces.
    static let bg       = Color(hex: "17171A")   // fundo mais profundo
    static let surface  = Color(hex: "212125")   // cards e containers
    static let elevated = Color(hex: "2C2C31")   // elementos elevados sobre surface

    // Accent palette safe to use in both light and dark appearances.
    static let accent     = Color(hex: "C49A6C")            // caramel — CTA, ícones ativos
    static let accentHi   = Color(hex: "D4AD80")            // ponto mais quente
    static let accentGlow = Color(hex: "C49A6C").opacity(0.28)
    static let accentSoft = Color(hex: "E8D5C0")            // fundo tonal claro
    static let sage       = Color(hex: "85A394")            // verde suave — sucesso / concluído
    static let steel      = Color(hex: "8B9DAD")            // azul-cinza — info / provider
    static let sand       = Color(hex: "D4C5B0")            // tom quente neutro

    // Legacy aliases kept for compatibility with future view migrations.
    static let orange     = accent
    static let orangeHi   = accentHi
    static let orangeGlow = accentGlow
    static let sea        = sage                             // antigo teal → sage
    static let blue       = steel
    static let lavender   = Color(hex: "9990B8")
    static let rose       = Color(hex: "BF8080")
    // Legacy names
    static let purple     = lavender
    static let red        = rose

    // Text hierarchy reserved for dark-only surfaces.
    static let textPrimary   = Color.white.opacity(0.92)   // títulos
    static let textSecondary = Color.white.opacity(0.62)   // labels e descrições
    static let textMuted     = Color.white.opacity(0.34)   // placeholders e metadados

    // Borders reserved for dark-only surfaces.
    static let border       = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.16)

    // Provider colours reserved for future session surfaces.
    static let colorLocal  = sage
    static let colorClaude = Color(hex: "D97757")          // terracotta
    static let colorCodex  = Color(hex: "6E7B8B")          // slate gray-blue
    static let colorGemini = Color(hex: "4A9B7E")          // green

    // Legacy alias
    static let colorGPT    = colorCodex

    // Study-specific tokens.
    /// Semana em andamento (progresso parcial)
    static let progressActive   = accent
    /// Semana 100% concluída
    static let progressComplete = sage
    /// Semanas sem progresso / futuras
    static let progressLocked   = Color.white.opacity(0.20)
    /// Badge de conclusão
    static let progressGreen    = sage

    // Gradients.
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentHi],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var userBubbleGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "C49A6C"), Color(hex: "A07D55")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var bgGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "17171A"), Color(hex: "1C1C20"), Color(hex: "211F1D")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension Theme {
    static func progressPhase(for ratio: Double) -> ProgressPhase {
        guard ratio.isFinite else {
            return .locked
        }

        if ratio >= 1.0 {
            return .complete
        }

        if ratio > 0.0 {
            return .active
        }

        return .locked
    }

    static func progressTint(for ratio: Double) -> Color {
        switch progressPhase(for: ratio) {
        case .locked:
            return progressLocked
        case .active:
            return progressActive
        case .complete:
            return progressComplete
        }
    }
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var n: UInt64 = 0
        Scanner(string: h).scanHexInt64(&n)
        let a, r, g, b: UInt64
        switch h.count {
        case 3:  (a, r, g, b) = (255, (n >> 8) * 17, (n >> 4 & 0xF) * 17, (n & 0xF) * 17)
        case 6:  (a, r, g, b) = (255,  n >> 16,        n >> 8 & 0xFF,       n & 0xFF)
        case 8:  (a, r, g, b) = (n >> 24, n >> 16 & 0xFF, n >> 8 & 0xFF,    n & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
