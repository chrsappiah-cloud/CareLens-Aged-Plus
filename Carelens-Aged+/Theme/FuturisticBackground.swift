import SwiftUI

struct FuturisticBackground: View {
    var body: some View {
        ZStack {
            CareLensTheme.Gradients.background
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    CareLensTheme.Colors.goldPrimary.opacity(0.25),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 350
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [
                    CareLensTheme.Colors.emeraldGreen.opacity(0.35),
                    .clear
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 320
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [
                    CareLensTheme.Colors.goldDeep.opacity(0.15),
                    .clear
                ],
                center: .center,
                startRadius: 5,
                endRadius: 250
            )
            .blendMode(.screen)

            DiamondFieldLayer()
        }
    }
}

struct DiamondFieldLayer: View {
    private let diamonds: [(size: CGFloat, opacity: Double, offsetX: CGFloat, offsetY: CGFloat)] = {
        (0..<12).map { _ in
            (
                CGFloat.random(in: 80...160),
                Double.random(in: 0.08...0.18),
                CGFloat.random(in: -220...220),
                CGFloat.random(in: -450...450)
            )
        }
    }()

    var body: some View {
        ZStack {
            ForEach(0..<diamonds.count, id: \.self) { i in
                let d = diamonds[i]
                DiamondShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                CareLensTheme.Colors.goldLight.opacity(0.35),
                                CareLensTheme.Colors.emeraldGreen.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                    .frame(width: d.size, height: d.size)
                    .opacity(d.opacity)
                    .blur(radius: 2)
                    .offset(x: d.offsetX, y: d.offsetY)
            }
        }
        .ignoresSafeArea()
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let mx = rect.midX
        let my = rect.midY
        p.move(to: CGPoint(x: mx, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: my))
        p.addLine(to: CGPoint(x: mx, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: my))
        p.closeSubpath()
        return p
    }
}
