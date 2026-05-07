import SwiftUI

struct SocialMediaLink: Identifiable {
    let id = UUID()
    let platform: String
    let icon: String
    let url: String
    let username: String
    let color: Color
}

struct SocialMediaLinksView: View {
    private let links: [SocialMediaLink] = [
        SocialMediaLink(
            platform: "Website",
            icon: "globe",
            url: "https://wcs-full.vercel.app",
            username: "wcs-full.vercel.app",
            color: CareLensTheme.Colors.accentMint
        ),
        SocialMediaLink(
            platform: "Helpline Email",
            icon: "envelope.fill",
            url: "mailto:christopher.appiahthompson@myworldclass.org",
            username: "christopher.appiahthompson@myworldclass.org",
            color: CareLensTheme.Colors.goldPrimary
        ),
        SocialMediaLink(
            platform: "X (Twitter)",
            icon: "bubble.left.and.text.bubble.right",
            url: "https://x.com/chaborachris",
            username: "@chaborachris",
            color: Color(red: 0.4, green: 0.7, blue: 0.95)
        ),
        SocialMediaLink(
            platform: "LinkedIn",
            icon: "link.circle.fill",
            url: "https://linkedin.com/in/christopher-appiah-thompson",
            username: "Christopher Appiah-Thompson",
            color: Color(red: 0.0, green: 0.47, blue: 0.71)
        ),
        SocialMediaLink(
            platform: "Instagram",
            icon: "camera.circle.fill",
            url: "https://instagram.com/chaborachris",
            username: "@chaborachris",
            color: Color(red: 0.83, green: 0.18, blue: 0.55)
        ),
        SocialMediaLink(
            platform: "YouTube",
            icon: "play.rectangle.fill",
            url: "https://youtube.com/@chaborachris",
            username: "@chaborachris",
            color: Color(red: 0.9, green: 0.15, blue: 0.15)
        ),
        SocialMediaLink(
            platform: "Facebook",
            icon: "person.2.circle.fill",
            url: "https://facebook.com/chaborachris",
            username: "Christopher Appiah-Thompson",
            color: Color(red: 0.23, green: 0.35, blue: 0.60)
        ),
        SocialMediaLink(
            platform: "TikTok",
            icon: "music.note.list",
            url: "https://tiktok.com/@chaborachris",
            username: "@chaborachris",
            color: Color(red: 0.0, green: 0.0, blue: 0.0)
        ),
    ]

    var body: some View {
        VStack(spacing: 16) {
            headerSection
            linksGrid
            communityCard
        }
        .padding()
        .navigationTitle("Connect With Us")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            DiamondShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.70, blue: 0.20),
                            CareLensTheme.Colors.safeGreen
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(color: Color(red: 0.85, green: 0.70, blue: 0.20).opacity(0.5), radius: 10)

            Text("Stay Connected")
                .font(.title3.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.75, blue: 0.30),
                            CareLensTheme.Colors.safeGreen
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Text("Follow us for updates, clinical tips, and community support")
                .font(.caption)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var linksGrid: some View {
        VStack(spacing: 10) {
            ForEach(links) { link in
                SocialLinkRow(link: link)
            }
        }
    }

    private var communityCard: some View {
        DiamondGlassCard(
            title: "Join Our Community",
            subtitle: "Connect with aged care professionals worldwide",
            icon: "person.3.fill"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    StatBubble(value: "2.4K", label: "Members")
                    StatBubble(value: "150+", label: "Resources")
                    StatBubble(value: "24/7", label: "Support")
                }
                Button(action: {}) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Join Community")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(DiamondButtonStyle())
            }
        }
    }
}

struct SocialLinkRow: View {
    let link: SocialMediaLink

    var body: some View {
        Button(action: { openURL(link.url) }) {
            HStack(spacing: 14) {
                Image(systemName: link.icon)
                    .font(.title3)
                    .foregroundStyle(link.color)
                    .frame(width: 36, height: 36)
                    .background(link.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(link.platform)
                        .font(.subheadline.bold())
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    Text(link.username)
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.03))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct StatBubble: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.75, blue: 0.30), CareLensTheme.Colors.safeGreen],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            Text(label)
                .font(.caption2)
                .foregroundStyle(CareLensTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .cornerRadius(10)
    }
}
