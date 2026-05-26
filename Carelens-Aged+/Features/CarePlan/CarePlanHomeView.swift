import SwiftUI
import SwiftData

struct CarePlanHomeView: View {
    @Query(sort: \ClientProfile.lastName) private var clients: [ClientProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                ScreenIntroHeader(
                    title: AppTab.carePlans.screenTitle,
                    subtitle: AppTab.carePlans.subtitle
                )
                .padding(.horizontal)
                .padding(.top, 8)

                if clients.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cross.case")
                            .font(.system(size: 48))
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                        Text("No Care Plans Yet")
                            .font(.title3.bold())
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                        Text("Complete an assessment first — plans appear here automatically")
                            .font(.subheadline)
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(clients, id: \.id) { client in
                            NavigationLink(destination: CarePlanDetailView(client: client)) {
                                DiamondGlassCard(
                                    title: client.fullName,
                                    subtitle: "\(client.carePlans.count) plan(s)",
                                    icon: "cross.case"
                                ) {
                                    HStack {
                                        DiamondStatusChip(
                                            text: client.carePlans.isEmpty ? "No Plan" : "Active",
                                            level: client.carePlans.isEmpty ? .warning : .safe
                                        )
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.4))
                                            .font(.caption)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .background(Color.clear)
            .navigationTitle(AppTab.carePlans.tabLabel)
            .navigationBarTitleDisplayMode(.inline)
            .careLensDarkChrome()
        }
    }
}

struct CarePlanDetailView: View {
    let client: ClientProfile
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CareLensTheme.sectionSpacing) {
                if client.carePlans.isEmpty {
                    Button(action: { createNewPlan() }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Care Plan")
                        }
                    }
                    .buttonStyle(DiamondButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    ForEach(client.carePlans, id: \.id) { plan in
                        carePlanCard(plan)
                    }
                }
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle("\(client.firstName)'s Care Plan")
        .careLensDarkChrome()
    }

    private func carePlanCard(_ plan: CarePlan) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if !plan.strengths.isEmpty {
                PlanSection(title: "Strengths", items: plan.strengths, icon: "star.fill", level: .safe)
            }
            if !plan.priorityProblems.isEmpty {
                PlanSection(title: "Priority Problems", items: plan.priorityProblems, icon: "exclamationmark.triangle.fill", level: .warning)
            }
            if !plan.goals.isEmpty {
                PlanSection(title: "Goals", items: plan.goals, icon: "target", level: .info)
            }
            if !plan.interventions.isEmpty {
                PlanSection(title: "Interventions", items: plan.interventions, icon: "arrow.triangle.branch", level: .info)
            }
            if let reviewDate = plan.nextReviewDate {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                    Text("Next Review: \(reviewDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
            }
        }
        .clCard()
    }

    private func createNewPlan() {
        let plan = CarePlan(
            clientID: client.id,
            strengths: ["Supportive family network", "Maintains sense of humour"],
            priorityProblems: ["Early cognitive changes", "Fall risk"],
            goals: ["Maintain independence in ADLs", "Reduce fall risk", "Support family carers"],
            interventions: ["Weekly cognitive stimulation", "Home safety assessment", "Carer support group referral"],
            nextReviewDate: Calendar.current.date(byAdding: .month, value: 1, to: .now)
        )
        modelContext.insert(plan)
        client.carePlans.append(plan)
    }
}

struct PlanSection: View {
    let title: String
    let items: [String]
    let icon: String
    let level: DiamondStatusChip.RiskLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(CareLensTheme.Gradients.iconGradient)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
            }
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    DiamondShape()
                        .fill(CareLensTheme.Colors.accentMint.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
            }
        }
    }
}
