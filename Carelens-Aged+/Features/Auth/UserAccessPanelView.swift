import SwiftUI

struct UserAccessPanelView: View {
    @EnvironmentObject var authService: AuthenticationService

    private var currentTier: SubscriptionTier {
        authService.currentUser?.subscriptionTier ?? .free
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CareLensTheme.sectionSpacing) {
                    currentPlanCard
                    featuresGrid
                    upgradeSuggestion
                }
                .padding()
            }
            .background(Color.clear)
            .navigationTitle("My Access")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var currentPlanCard: some View {
        DiamondGlassCard(
            title: currentTier.rawValue,
            subtitle: "Current subscription plan",
            icon: "crown"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("$\(String(format: "%.2f", currentTier.monthlyPrice))/month")
                        .font(.title3.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    Spacer()
                    DiamondStatusChip(text: "Active", level: .safe)
                }
                Text("Max clients: \(currentTier.maxClients == Int.max ? "Unlimited" : "\(currentTier.maxClients)")")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                Text("\(currentTier.features.count) features included")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }
        }
    }

    private var featuresGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feature Access")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(AppFeature.allCases, id: \.self) { feature in
                    let hasAccess = currentTier.features.contains(feature)
                    FeatureAccessCard(feature: feature, hasAccess: hasAccess)
                }
            }
        }
    }

    private var upgradeSuggestion: some View {
        Group {
            if currentTier != .enterprise {
                let nextTier = nextAvailableTier
                DiamondGlassCard(
                    title: "Upgrade to \(nextTier.rawValue)",
                    subtitle: "Unlock \(nextTier.features.count - currentTier.features.count) more features",
                    icon: "arrow.up.circle"
                ) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Upgrade — $\(String(format: "%.2f", nextTier.monthlyPrice))/mo")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DiamondButtonStyle())
                }
            }
        }
    }

    private var nextAvailableTier: SubscriptionTier {
        switch currentTier {
        case .free: return .starter
        case .starter: return .professional
        case .professional: return .enterprise
        case .enterprise: return .enterprise
        }
    }
}

struct FeatureAccessCard: View {
    let feature: AppFeature
    let hasAccess: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: feature.icon)
                .font(.body)
                .foregroundStyle(hasAccess ? CareLensTheme.Colors.accentMint : CareLensTheme.Colors.textTertiary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.rawValue)
                    .font(.caption2.bold())
                    .foregroundStyle(hasAccess ? CareLensTheme.Colors.textPrimary : CareLensTheme.Colors.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: hasAccess ? "checkmark.circle.fill" : "lock.fill")
                .font(.caption)
                .foregroundStyle(hasAccess ? CareLensTheme.Colors.safeGreen : CareLensTheme.Colors.textTertiary)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .background(hasAccess ? Color.white.opacity(0.04) : Color.black.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    hasAccess ? CareLensTheme.Colors.accentMint.opacity(0.2) : Color.white.opacity(0.05),
                    lineWidth: 0.5
                )
        )
        .opacity(hasAccess ? 1 : 0.6)
    }
}
