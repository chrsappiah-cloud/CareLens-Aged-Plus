import SwiftUI

// MARK: - Theme Colors & Gradients

struct CareLensTheme {
    struct Colors {
        // Deep canvas — near-black violet / charcoal
        static let backgroundTop    = Color(red: 0.02, green: 0.01, blue: 0.06)
        static let backgroundBottom = Color(red: 0.01, green: 0.04, blue: 0.07)
        static let surfaceDeep      = Color(red: 0.03, green: 0.02, blue: 0.08)
        static let surfaceElevated  = Color(red: 0.09, green: 0.07, blue: 0.15)
        static let surfaceCard      = Color(red: 0.11, green: 0.09, blue: 0.18)
        static let tabBarBackground = Color(red: 0.02, green: 0.02, blue: 0.05)

        static let accentMint       = Color(red: 0.45, green: 1.00, blue: 0.78)
        static let accentMagenta    = Color(red: 0.88, green: 0.48, blue: 1.00)
        static let accentAmber      = Color(red: 1.00, green: 0.82, blue: 0.38)

        // Diamond gold palette — vivid on dark backgrounds
        static let goldPrimary      = Color(red: 0.92, green: 0.76, blue: 0.22)
        static let goldLight        = Color(red: 1.00, green: 0.93, blue: 0.48)
        static let goldDeep         = Color(red: 0.62, green: 0.48, blue: 0.08)
        static let tabSelected      = goldLight
        static let tabUnselected    = Color(red: 0.68, green: 0.66, blue: 0.76)

        // Emerald green palette
        static let emeraldGreen     = Color(red: 0.22, green: 0.88, blue: 0.52)
        static let deepForest       = Color(red: 0.04, green: 0.38, blue: 0.22)

        static let cardFill         = surfaceCard.opacity(0.95)
        static let cardBorder       = Color.white.opacity(0.22)
        static let buttonLabelOnAccent = Color(red: 0.04, green: 0.03, blue: 0.08)

        // High-contrast text on deep backgrounds
        static let textPrimary      = Color(red: 0.99, green: 0.98, blue: 1.00)
        static let textSecondary    = Color(red: 0.84, green: 0.82, blue: 0.90)
        static let textTertiary     = Color(red: 0.64, green: 0.60, blue: 0.72)
        // Rich accent text colors
        static let textDeepBlue     = Color(red: 0.50, green: 0.58, blue: 0.98)  // Vivid royal blue
        static let textPurple       = Color(red: 0.75, green: 0.50, blue: 0.95)  // Bright purple
        static let textChocolate    = Color(red: 0.82, green: 0.62, blue: 0.38)  // Bold warm gold

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
            colors: [Colors.goldDeep, Colors.goldPrimary, Colors.emeraldGreen.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let tabBarTopEdge = LinearGradient(
            colors: [Colors.goldPrimary.opacity(0.45), Colors.emeraldGreen.opacity(0.2), .clear],
            startPoint: .leading,
            endPoint: .trailing
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

        static let headingText = LinearGradient(
            colors: [Colors.textDeepBlue, Colors.textPurple],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let bodyText = LinearGradient(
            colors: [Colors.textPurple, Colors.textChocolate],
            startPoint: .leading,
            endPoint: .trailing
        )

        static let richText = LinearGradient(
            colors: [
                Color(red: 0.35, green: 0.40, blue: 0.85),
                Color(red: 0.60, green: 0.35, blue: 0.78),
                Color(red: 0.70, green: 0.48, blue: 0.30)
            ],
            startPoint: .leading,
            endPoint: .trailing
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
            .background(
                RoundedRectangle(cornerRadius: CareLensTheme.cardCornerRadius, style: .continuous)
                    .fill(CareLensTheme.Colors.cardFill)
            )
            .cornerRadius(CareLensTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CareLensTheme.cardCornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                CareLensTheme.Colors.goldPrimary.opacity(0.3),
                                CareLensTheme.Colors.emeraldGreen.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 8)
    }
}

extension View {
    func clCard() -> some View {
        modifier(CLCardStyle())
    }

    /// Deep-dark navigation chrome with high-contrast titles.
    func careLensDarkChrome() -> some View {
        self
            .preferredColorScheme(.dark)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(CareLensTheme.Colors.surfaceDeep.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(CareLensTheme.Colors.goldLight)
    }

    /// Forms and lists on the futuristic background.
    func careLensDarkForm() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .foregroundStyle(CareLensTheme.Colors.textPrimary)
            .tint(CareLensTheme.Colors.goldLight)
    }

    func careLensDarkListRow() -> some View {
        listRowBackground(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(CareLensTheme.Colors.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(CareLensTheme.Colors.cardBorder.opacity(0.5), lineWidth: 0.5)
                )
        )
        .listRowSeparatorTint(CareLensTheme.Colors.cardBorder.opacity(0.35))
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
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.10)))
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
