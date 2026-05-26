import SwiftUI

struct AIInsightView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var middleware = NetworkMiddleware.shared
    let client: ClientProfile
    let assessmentType: String
    let scores: [String: Double]

    @State private var insight: ClinicalInsight?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: CareLensTheme.sectionSpacing) {
                headerCard

                if isLoading {
                    loadingView
                } else if let insight = insight {
                    insightResultView(insight)
                } else if let error = errorMessage {
                    errorView(error)
                } else {
                    generatePrompt
                }
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle("AI Insights")
        .navigationBarTitleDisplayMode(.inline)
        .careLensDarkChrome()
    }

    private var headerCard: some View {
        DiamondGlassCard(
            title: "Clinical AI Analysis",
            subtitle: "Powered by OpenAI GPT-4o Health API",
            icon: "brain"
        ) {
            HStack {
                DiamondStatusChip(text: "Decision Support", level: .safe)
                Spacer()
                Text("Not diagnostic")
                    .font(.caption2)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(CareLensTheme.Colors.accentMint)
                .scaleEffect(1.5)
            Text("Analysing assessment data...")
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .clCard()
    }

    private func insightResultView(_ insight: ClinicalInsight) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(insight.category)
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                Spacer()
                Text("Confidence: \(Int(insight.confidence * 100))%")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }

            Text(insight.summary)
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textPrimary)

            if !insight.recommendations.isEmpty {
                Divider().overlay(Color.white.opacity(0.1))
                Text("Recommendations")
                    .font(.subheadline.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)

                ForEach(insight.recommendations, id: \.self) { rec in
                    HStack(alignment: .top, spacing: 8) {
                        DiamondShape()
                            .fill(CareLensTheme.Colors.accentMint)
                            .frame(width: 7, height: 7)
                            .padding(.top, 5)
                        Text(rec)
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    }
                }
            }

            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(CareLensTheme.Colors.accentAmber)
                Text("This is decision-support only. It does not replace clinical judgment.")
                    .font(.caption2)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }
            .padding(.top, 8)
        }
        .clCard()
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundStyle(CareLensTheme.Colors.accentAmber)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .clCard()
    }

    private var generatePrompt: some View {
        VStack(spacing: 16) {
            Text("Generate AI-powered clinical insights for this assessment")
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: { Task { await generateInsight() } }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate Insight")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DiamondButtonStyle())
        }
        .padding(.vertical, 20)
        .clCard()
    }

    private func generateInsight() async {
        guard authService.hasAccess(to: .aiInsights) else {
            errorMessage = "AI Insights requires a Professional or Enterprise subscription."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            insight = try await middleware.requestInsight(
                for: .assessmentInsight(
                    type: assessmentType,
                    scores: scores,
                    age: client.age,
                    concerns: client.presentingConcerns
                ),
                requiredFeature: .aiInsights,
                userTier: authService.currentUser?.subscriptionTier ?? .free
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
