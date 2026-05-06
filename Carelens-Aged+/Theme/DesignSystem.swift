import SwiftUI

// MARK: - Theme Colors & Gradients

struct CareLensTheme {
    struct Colors {
        static let backgroundTop    = Color(red: 0.07, green: 0.02, blue: 0.15)
        static let backgroundBottom = Color(red: 0.01, green: 0.16, blue: 0.12)
        static let accentMint       = Color(red: 0.39, green: 0.99, blue: 0.74)
        static let accentMagenta    = Color(red: 0.82, green: 0.39, blue: 1.00)
        static let accentAmber      = Color(red: 0.98, green: 0.76, blue: 0.30)

        // Diamond gold palette
        static let goldPrimary      = Color(red: 0.85, green: 0.70, blue: 0.20)
        static let goldLight        = Color(red: 0.95, green: 0.85, blue: 0.35)
        static let goldDeep         = Color(red: 0.75, green: 0.55, blue: 0.10)
        // Emerald green palette
        static let emeraldGreen     = Color(red: 0.18, green: 0.80, blue: 0.45)
        static let deepForest       = Color(red: 0.05, green: 0.45, blue: 0.25)

        static let cardFill         = Color.white.opacity(0.06)
        static let cardBorder       = Color.white.opacity(0.35)
        static let textPrimary      = Color(red: 0.85, green: 0.97, blue: 1.0)
        static let textSecondary    = Color(red: 0.55, green: 0.88, blue: 0.82)
        static let textTertiary     = Color(red: 0.40, green: 0.65, blue: 0.72)

        static let riskRed          = Color(red: 0.95, green: 0.28, blue: 0.28)
        static let safeGreen        = Color(red: 0.20, green: 0.88, blue: 0.55)
    }

    struct Gradients {
        static let background = LinearGradient(
            colors: [Colors.backgroundTop, Colors.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let primaryButton = LinearGradient(
            colors: [Colors.accentMint, Colors.accentMagenta],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let iconGradient = LinearGradient(
            colors: [Colors.accentMint, Colors.accentMagenta],
            startPoint: .top,
            endPoint: .bottom
        )

        static let statusSafe = LinearGradient(
            colors: [Color.green.opacity(0.9), Color.white.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let statusWarning = LinearGradient(
            colors: [Colors.accentAmber, Color.white.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let statusRisk = LinearGradient(
            colors: [Color.red.opacity(0.9), Color.white.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let cardBorder = LinearGradient(
            colors: [
                Colors.cardBorder,
                Color.purple.opacity(0.4),
                Color.green.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let diamondGold = LinearGradient(
            colors: [Colors.goldPrimary, Colors.goldLight, Colors.goldDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let goldGreen = LinearGradient(
            colors: [Colors.goldPrimary, Colors.emeraldGreen],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let emeraldShine = LinearGradient(
            colors: [Colors.emeraldGreen, Colors.accentMint],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static let cardCornerRadius: CGFloat = 22
    static let minTouchTarget: CGFloat = 44
    static let spacing: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
}

// MARK: - Legacy Aliases (backward compat with existing views)

enum CLTheme {
    static let primaryNavy = CareLensTheme.Colors.backgroundTop
    static let accentTeal = CareLensTheme.Colors.accentMint
    static let accentGold = CareLensTheme.Colors.accentAmber
    static let alertRed = CareLensTheme.Colors.riskRed
    static let warningOrange = CareLensTheme.Colors.accentAmber
    static let successGreen = CareLensTheme.Colors.safeGreen
    static let backgroundPrimary = CareLensTheme.Colors.backgroundTop
    static let backgroundSecondary = Color.white.opacity(0.06)
    static let textPrimary = CareLensTheme.Colors.textPrimary
    static let textSecondary = CareLensTheme.Colors.textSecondary
    static let textTertiary = CareLensTheme.Colors.textTertiary

    static let cardCornerRadius: CGFloat = 22
    static let minTouchTarget: CGFloat = 44
    static let spacing: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
}

// MARK: - Glass Card Modifier

struct CLCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(CareLensTheme.spacing)
            .background(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: CareLensTheme.cardCornerRadius, style: .continuous)
                    .fill(CareLensTheme.Colors.cardFill)
            )
            .cornerRadius(CareLensTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CareLensTheme.cardCornerRadius, style: .continuous)
                    .strokeBorder(CareLensTheme.Gradients.cardBorder, lineWidth: 0.8)
            )
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)
    }
}

extension View {
    func clCard() -> some View {
        modifier(CLCardStyle())
    }
}

// MARK: - Status Chips

struct StatusChip: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            DiamondShape()
                .fill(color)
                .frame(width: 9, height: 9)
                .shadow(color: color.opacity(0.7), radius: 3)
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.white.opacity(0.08)))
    }
}

// MARK: - Assessment Status

enum AssessmentStatus: String, CaseIterable {
    case draft = "Draft"
    case inProgress = "In Progress"
    case needsReview = "Needs Review"
    case completed = "Completed"
    case urgent = "Urgent"

    var color: Color {
        switch self {
        case .draft: return .gray
        case .inProgress: return CareLensTheme.Colors.accentMint
        case .needsReview: return CareLensTheme.Colors.accentAmber
        case .completed: return CareLensTheme.Colors.safeGreen
        case .urgent: return CareLensTheme.Colors.riskRed
        }
    }
}
