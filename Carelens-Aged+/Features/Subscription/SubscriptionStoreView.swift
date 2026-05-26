import SwiftUI

struct SubscriptionStoreView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var store = ApplePaySubscriptionService.shared
    @State private var selectedBilling: BillingPeriod = .monthly
    @State private var selectedProduct: SubscriptionProduct?
    @State private var showingConfirmation = false

    enum BillingPeriod: String, CaseIterable {
        case monthly = "Monthly"
        case annual = "Annual"
    }

    private var currentTier: SubscriptionTier {
        authService.currentUser?.subscriptionTier ?? .free
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    billingToggle
                    planCards
                    applePaySection
                    restoreSection
                    termsSection
                }
                .padding()
            }
            .background(Color.clear)
            .navigationTitle("Subscription Plans")
            .navigationBarTitleDisplayMode(.inline)
            .careLensDarkChrome()
            .alert("Confirm Purchase", isPresented: $showingConfirmation) {
                Button("Purchase with Apple Pay") {
                    if let product = selectedProduct {
                        Task { await store.purchase(product) }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let product = selectedProduct {
                    Text("Subscribe to \(product.displayName) for \(product.price)?")
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                DiamondShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.85, green: 0.70, blue: 0.20),
                                Color(red: 0.95, green: 0.85, blue: 0.35),
                                Color(red: 0.75, green: 0.55, blue: 0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(red: 0.85, green: 0.70, blue: 0.20).opacity(0.6), radius: 16)
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            Text("Unlock Full Potential")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.75, blue: 0.30),
                            Color(red: 0.95, green: 0.88, blue: 0.45)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Text("Choose the plan that fits your practice")
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
        }
    }

    private var billingToggle: some View {
        HStack(spacing: 4) {
            ForEach(BillingPeriod.allCases, id: \.self) { period in
                Button(action: { withAnimation { selectedBilling = period } }) {
                    HStack(spacing: 6) {
                        Text(period.rawValue)
                            .font(.subheadline.bold())
                        if period == .annual {
                            Text("Save 17%")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Color(red: 0.85, green: 0.70, blue: 0.20).opacity(0.3))
                                )
                                .foregroundStyle(Color(red: 0.95, green: 0.85, blue: 0.35))
                        }
                    }
                    .foregroundStyle(selectedBilling == period ? .white : CareLensTheme.Colors.textTertiary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        Capsule().fill(selectedBilling == period
                                       ? Color(red: 0.85, green: 0.70, blue: 0.20).opacity(0.25)
                                       : Color.white.opacity(0.04))
                    )
                    .overlay(
                        Capsule().strokeBorder(
                            selectedBilling == period
                                ? Color(red: 0.85, green: 0.70, blue: 0.20).opacity(0.5)
                                : .clear,
                            lineWidth: 1
                        )
                    )
                }
            }
        }
        .padding(4)
        .background(Capsule().fill(Color.white.opacity(0.04)))
    }

    private var planCards: some View {
        VStack(spacing: 16) {
            SubscriptionPlanCard(
                tier: .starter,
                product: selectedBilling == .monthly ? .starterMonthly : .starterAnnual,
                isCurrentPlan: currentTier == .starter,
                isSelected: selectedProduct?.tier == .starter,
                onSelect: { selectProduct($0) }
            )

            SubscriptionPlanCard(
                tier: .professional,
                product: selectedBilling == .monthly ? .professionalMonthly : .professionalAnnual,
                isCurrentPlan: currentTier == .professional,
                isSelected: selectedProduct?.tier == .professional,
                isRecommended: true,
                onSelect: { selectProduct($0) }
            )

            SubscriptionPlanCard(
                tier: .enterprise,
                product: selectedBilling == .monthly ? .enterpriseMonthly : .enterpriseAnnual,
                isCurrentPlan: currentTier == .enterprise,
                isSelected: selectedProduct?.tier == .enterprise,
                onSelect: { selectProduct($0) }
            )
        }
    }

    private var applePaySection: some View {
        VStack(spacing: 12) {
            if let product = selectedProduct {
                Button(action: { showingConfirmation = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Pay \(product.price)")
                            .font(.headline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.black)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundStyle(.white)
                }
                .disabled(store.isPurchasing)

                if store.isPurchasing {
                    HStack(spacing: 8) {
                        ProgressView().tint(CareLensTheme.Colors.accentMint)
                        Text("Processing payment...")
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    }
                }

                if case .success = store.transactionStatus {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(CareLensTheme.Colors.safeGreen)
                        Text("Subscription activated!")
                            .font(.subheadline.bold())
                            .foregroundStyle(CareLensTheme.Colors.safeGreen)
                    }
                }
            } else {
                Text("Select a plan above to continue")
                    .font(.subheadline)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }
        }
    }

    private var restoreSection: some View {
        Button(action: { Task { await store.restorePurchases() } }) {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.accentMint)
        }
    }

    private var termsSection: some View {
        VStack(spacing: 6) {
            Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(CareLensTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                Button("Terms of Use") {}
                    .font(.caption2)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                Button("Privacy Policy") {}
                    .font(.caption2)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }
        }
        .padding(.top, 8)
    }

    private func selectProduct(_ product: SubscriptionProduct) {
        withAnimation { selectedProduct = product }
    }
}

struct SubscriptionPlanCard: View {
    let tier: SubscriptionTier
    let product: SubscriptionProduct
    let isCurrentPlan: Bool
    let isSelected: Bool
    var isRecommended: Bool = false
    let onSelect: (SubscriptionProduct) -> Void

    private var goldColor: Color { Color(red: 0.85, green: 0.70, blue: 0.20) }
    private var goldLight: Color { Color(red: 0.95, green: 0.85, blue: 0.35) }

    var body: some View {
        Button(action: { onSelect(product) }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(tier.rawValue)
                                .font(.headline.bold())
                                .foregroundStyle(isSelected ? goldLight : CareLensTheme.Colors.textPrimary)
                            if isRecommended {
                                Text("RECOMMENDED")
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(goldColor.opacity(0.3)))
                                    .foregroundStyle(goldLight)
                            }
                            if isCurrentPlan {
                                Text("CURRENT")
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(CareLensTheme.Colors.safeGreen.opacity(0.3)))
                                    .foregroundStyle(CareLensTheme.Colors.safeGreen)
                            }
                        }
                        Text(product.price)
                            .font(.title3.bold())
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [goldColor, goldLight],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                    }
                    Spacer()
                    DiamondShape()
                        .fill(
                            LinearGradient(
                                colors: [goldColor, CareLensTheme.Colors.safeGreen.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                        .opacity(isSelected ? 1 : 0.4)
                }

                HStack(spacing: 16) {
                    Label("\(tier.maxClients == Int.max ? "∞" : "\(tier.maxClients)") clients", systemImage: "person.2")
                    Label("\(tier.features.count) features", systemImage: "sparkles")
                }
                .font(.caption)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)

                if let savings = product.savings {
                    HStack(spacing: 4) {
                        DiamondShape()
                            .fill(goldColor)
                            .frame(width: 8, height: 8)
                        Text(savings)
                            .font(.caption.bold())
                            .foregroundStyle(goldLight)
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .background(isSelected ? goldColor.opacity(0.06) : Color.white.opacity(0.03))
            .cornerRadius(CareLensTheme.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CareLensTheme.cardCornerRadius, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? LinearGradient(colors: [goldColor, CareLensTheme.Colors.safeGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isSelected ? 1.5 : 0.8
                    )
            )
            .shadow(color: isSelected ? goldColor.opacity(0.3) : .clear, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }
}
