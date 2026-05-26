import SwiftUI

/// Eyebrow + title + helper line shown at the top of main screens.
struct ScreenIntroHeader: View {
    var eyebrow: String? = nil
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(CareLensTheme.Colors.goldLight)
            }
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
            Text(subtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Section heading used inside scroll content.
struct CareLensSectionTitle: View {
    let title: String
    var footnote: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
            if let footnote {
                Text(footnote)
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
