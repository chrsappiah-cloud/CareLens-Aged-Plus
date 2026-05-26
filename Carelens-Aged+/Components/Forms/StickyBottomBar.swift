import SwiftUI

struct StickyBottomBar: View {
    var onSaveDraft: (() -> Void)?
    var onAddCollateral: (() -> Void)?
    var onFlagUrgent: (() -> Void)?
    var onNext: (() -> Void)?
    var onGenerateSummary: (() -> Void)?

    var showNext: Bool = true
    var showGenerateSummary: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            if let onSaveDraft {
                Button(action: onSaveDraft) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(CareLensToolbarButtonStyle())
            }

            if let onAddCollateral {
                Button(action: onAddCollateral) {
                    Label("Collateral", systemImage: "person.badge.plus")
                }
                .buttonStyle(CareLensToolbarButtonStyle())
            }

            if let onFlagUrgent {
                Button(action: onFlagUrgent) {
                    Label("Urgent", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(CareLensTheme.Colors.riskRed)
                }
                .buttonStyle(CareLensToolbarButtonStyle())
            }

            Spacer()

            if showGenerateSummary, let onGenerateSummary {
                Button(action: onGenerateSummary) {
                    Label("Summary", systemImage: "doc.text")
                }
                .buttonStyle(CareLensProminentToolbarButtonStyle(accent: CareLensTheme.Colors.safeGreen))
            }

            if showNext, let onNext {
                Button(action: onNext) {
                    Label("Next", systemImage: "arrow.right")
                }
                .buttonStyle(CareLensProminentToolbarButtonStyle(accent: CareLensTheme.Colors.emeraldGreen))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            CareLensTheme.Colors.tabBarBackground
                .overlay(
                    Rectangle()
                        .fill(CareLensTheme.Gradients.tabBarTopEdge)
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }
}
