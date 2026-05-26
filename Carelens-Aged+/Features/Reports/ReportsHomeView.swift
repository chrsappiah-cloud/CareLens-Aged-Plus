import SwiftUI
import SwiftData

struct ReportsHomeView: View {
    @Query(sort: \ClientProfile.lastName) private var clients: [ClientProfile]
    @State private var selectedClient: ClientProfile?
    @State private var selectedReportType: ReportType = .clinical
    @State private var generatedReport: String?
    @State private var showingShareSheet = false
    @State private var pdfData: Data?

    private let reportService = ReportService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CareLensTheme.sectionSpacing) {
                    ScreenIntroHeader(
                        title: AppTab.reports.screenTitle,
                        subtitle: AppTab.reports.subtitle
                    )
                    clientSelector
                    reportTypeSelector

                    if let client = selectedClient {
                        generateButton(client: client)
                    }

                    if let report = generatedReport {
                        reportPreview(report)
                    }
                }
                .padding()
            }
            .background(Color.clear)
            .navigationTitle(AppTab.reports.tabLabel)
            .navigationBarTitleDisplayMode(.inline)
            .careLensDarkChrome()
            .sheet(isPresented: $showingShareSheet) {
                if let data = pdfData {
                    ShareSheet(items: [data])
                }
            }
        }
    }

    private var clientSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            CareLensSectionTitle(title: "Choose Client", footnote: "Reports are generated per client record")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            if clients.isEmpty {
                Text("No clients available")
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    .clCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(clients, id: \.id) { client in
                            Button(action: { selectedClient = client; generatedReport = nil }) {
                                HStack(spacing: 6) {
                                    DiamondShape()
                                        .fill(selectedClient?.id == client.id
                                              ? CareLensTheme.Colors.accentMint
                                              : Color.white.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                    Text(client.fullName)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(
                                        selectedClient?.id == client.id
                                        ? CareLensTheme.Colors.accentMint.opacity(0.2)
                                        : Color.white.opacity(0.06)
                                    )
                                )
                                .overlay(
                                    Capsule().strokeBorder(
                                        selectedClient?.id == client.id
                                        ? CareLensTheme.Colors.accentMint.opacity(0.6)
                                        : Color.clear,
                                        lineWidth: 1
                                    )
                                )
                                .foregroundStyle(
                                    selectedClient?.id == client.id
                                    ? CareLensTheme.Colors.accentMint
                                    : CareLensTheme.Colors.textSecondary
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private var reportTypeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Report Type")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(ReportType.allCases, id: \.self) { type in
                    Button(action: { selectedReportType = type; generatedReport = nil }) {
                        VStack(spacing: 8) {
                            Image(systemName: reportIcon(for: type))
                                .font(.title3)
                                .foregroundStyle(
                                    selectedReportType == type
                                    ? CareLensTheme.Gradients.iconGradient
                                    : LinearGradient(colors: [CareLensTheme.Colors.textSecondary], startPoint: .top, endPoint: .bottom)
                                )
                            Text(type.rawValue)
                                .font(.caption)
                                .foregroundStyle(
                                    selectedReportType == type
                                    ? CareLensTheme.Colors.textPrimary
                                    : CareLensTheme.Colors.textSecondary
                                )
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .background(
                            selectedReportType == type
                            ? CareLensTheme.Colors.accentMint.opacity(0.08)
                            : Color.white.opacity(0.03)
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    selectedReportType == type
                                    ? CareLensTheme.Colors.accentMint.opacity(0.5)
                                    : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func generateButton(client: ClientProfile) -> some View {
        Button(action: { generateReport(for: client) }) {
            HStack {
                Image(systemName: "sparkles")
                Text("Generate Report")
            }
        }
        .buttonStyle(DiamondButtonStyle())
        .frame(maxWidth: .infinity)
    }

    private func reportPreview(_ report: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Report Preview")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                Spacer()
                Button(action: exportPDF) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export PDF")
                    }
                    .font(.caption.bold())
                }
                .buttonStyle(DiamondSecondaryButtonStyle())
            }

            ScrollView {
                Text(report)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    .padding()
            }
            .frame(maxHeight: 400)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.03))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
            )
        }
    }

    private func generateReport(for client: ClientProfile) {
        let assessment = client.assessments.last
        let carePlan = client.carePlans.last
        generatedReport = reportService.generateReport(
            type: selectedReportType,
            client: client,
            assessment: assessment,
            carePlan: carePlan
        )
    }

    private func exportPDF() {
        guard let report = generatedReport else { return }
        pdfData = reportService.renderPDF(content: report)
        if pdfData != nil {
            showingShareSheet = true
        }
    }

    private func reportIcon(for type: ReportType) -> String {
        switch type {
        case .clinical: return "stethoscope"
        case .family: return "house.and.flag"
        case .facilityHandover: return "arrow.left.arrow.right"
        case .acpSpiritual: return "sparkles"
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
