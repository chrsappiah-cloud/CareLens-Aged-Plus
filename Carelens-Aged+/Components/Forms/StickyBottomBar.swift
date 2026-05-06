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
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }

            if let onAddCollateral {
                Button(action: onAddCollateral) {
                    Label("Collateral", systemImage: "person.badge.plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }

            if let onFlagUrgent {
                Button(action: onFlagUrgent) {
                    Label("Urgent", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(CLTheme.alertRed)
            }

            Spacer()

            if showGenerateSummary, let onGenerateSummary {
                Button(action: onGenerateSummary) {
                    Label("Summary", systemImage: "doc.text")
                        .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(CLTheme.successGreen)
            }

            if showNext, let onNext {
                Button(action: onNext) {
                    Label("Next", systemImage: "arrow.right")
                        .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(CLTheme.accentTeal)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}
