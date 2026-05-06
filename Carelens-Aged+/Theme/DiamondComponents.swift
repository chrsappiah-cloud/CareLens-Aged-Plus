import SwiftUI

// MARK: - Diamond Glass Card

struct DiamondGlassCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String
    @ViewBuilder var content: Content

    init(title: String, subtitle: String? = nil, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    CareLensTheme.Colors.goldPrimary.opacity(0.5),
                                    CareLensTheme.Colors.emeraldGreen.opacity(0.4),
                                    CareLensTheme.Colors.goldLight.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                        .shadow(color: CareLensTheme.Colors.goldPrimary.opacity(0.15), radius: 16, x: 0, y: 12)
                )
                .overlay(
                    DiamondShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    CareLensTheme.Colors.goldLight.opacity(0.30),
                                    CareLensTheme.Colors.emeraldGreen.opacity(0.08),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(0.6)
                        .rotationEffect(.degrees(18))
                        .offset(x: 40, y: -40)
                        .blur(radius: 4)
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.18),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.screen)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    CareLensTheme.Colors.goldLight,
                                    CareLensTheme.Colors.emeraldGreen
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 40, height: 40)
                        .background(
                            DiamondShape()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            CareLensTheme.Colors.goldPrimary.opacity(0.20),
                                            CareLensTheme.Colors.emeraldGreen.opacity(0.12)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        CareLensTheme.Colors.goldLight,
                                        CareLensTheme.Colors.emeraldGreen
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineLimit(2)
                        if let subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(CareLensTheme.Colors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                }

                content
                    .padding(.top, 6)
            }
            .padding(16)
        }
    }
}

// MARK: - Diamond Status Chip

struct DiamondStatusChip: View {
    let text: String
    let gradient: LinearGradient

    enum RiskLevel {
        case safe, warning, risk, info

        var gradient: LinearGradient {
            switch self {
            case .safe: return CareLensTheme.Gradients.statusSafe
            case .warning: return CareLensTheme.Gradients.statusWarning
            case .risk: return CareLensTheme.Gradients.statusRisk
            case .info: return LinearGradient(
                colors: [CareLensTheme.Colors.accentMint, .white.opacity(0.6)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            }
        }
    }

    init(text: String, level: RiskLevel) {
        self.text = text
        self.gradient = level.gradient
    }

    init(text: String, color: Color) {
        self.text = text
        self.gradient = LinearGradient(
            colors: [color.opacity(0.9), .white.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        HStack(spacing: 6) {
            DiamondShape()
                .fill(gradient)
                .frame(width: 12, height: 12)
                .shadow(color: .white.opacity(0.4), radius: 4, x: 0, y: 2)
            Text(text)
                .foregroundColor(.white.opacity(0.85))
                .font(.caption.weight(.medium))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
        )
    }
}

// MARK: - Diamond Button Style

struct DiamondButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    CareLensTheme.Colors.goldPrimary,
                                    CareLensTheme.Colors.emeraldGreen
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    DiamondShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    CareLensTheme.Colors.goldLight.opacity(0.7),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(0.7)
                        .offset(x: -8, y: -10)
                        .blur(radius: 3)
                        .opacity(configuration.isPressed ? 0.15 : 0.45)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                CareLensTheme.Colors.goldLight.opacity(0.6),
                                CareLensTheme.Colors.emeraldGreen.opacity(0.3)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .blendMode(.screen)
            )
            .shadow(color: CareLensTheme.Colors.goldPrimary.opacity(0.5),
                    radius: 14, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct DiamondSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(CareLensTheme.Colors.accentMint)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CareLensTheme.Colors.accentMint.opacity(0.12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(CareLensTheme.Colors.accentMint.opacity(0.4), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.75), value: configuration.isPressed)
    }
}
