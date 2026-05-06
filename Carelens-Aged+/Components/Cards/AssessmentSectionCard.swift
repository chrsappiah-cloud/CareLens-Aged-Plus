import SwiftUI

struct AssessmentSectionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let status: AssessmentStatus
    let progress: Double
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(CLTheme.accentTeal)
                    .frame(width: 48, height: 48)
                    .background(CLTheme.accentTeal.opacity(0.12))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.body.bold())
                        .foregroundStyle(CLTheme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(CLTheme.textSecondary)
                        .lineLimit(2)

                    if progress > 0 {
                        ProgressView(value: progress)
                            .tint(status.color)
                    }
                }

                Spacer()

                VStack(spacing: 4) {
                    StatusChip(title: status.rawValue, color: status.color)
                    if progress > 0 {
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .foregroundStyle(CLTheme.textSecondary)
                    }
                }
            }
            .padding()
            .frame(minHeight: CLTheme.minTouchTarget)
            .background(CLTheme.backgroundSecondary)
            .cornerRadius(CLTheme.cardCornerRadius)
            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }
}
