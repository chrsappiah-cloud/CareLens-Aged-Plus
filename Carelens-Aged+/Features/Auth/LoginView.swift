import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        ZStack {
            FuturisticBackground()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 60)

                    logoSection
                    loginForm
                    loginButton

                    if let error = authService.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.riskRed)
                            .padding(.horizontal)
                    }

                    demoCredentials
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                DiamondShape()
                    .fill(CareLensTheme.Gradients.primaryButton)
                    .frame(width: 80, height: 80)
                    .shadow(color: CareLensTheme.Colors.accentMint.opacity(0.5), radius: 20)
                Image(systemName: "eye")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("CareLens Aged+")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(CareLensTheme.Colors.goldLight)

            Text("Intelligent aged care for clinicians & care teams")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Text("Assessments · NeuroWatch · Care plans · AI insights")
                .font(.caption)
                .foregroundStyle(CareLensTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var loginForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption.bold())
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                TextField("name@facility.org", text: $email)
                    .textFieldStyle(.plain)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    .padding()
                    .background(CareLensTheme.Colors.surfaceElevated)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(CareLensTheme.Colors.goldPrimary.opacity(0.4), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption.bold())
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                HStack {
                    if showPassword {
                        TextField("Enter password", text: $password)
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    } else {
                        SecureField("Enter password", text: $password)
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    }
                }
                .padding()
                .background(CareLensTheme.Colors.surfaceElevated)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(CareLensTheme.Colors.goldPrimary.opacity(0.4), lineWidth: 1)
                )
            }
        }
    }

    private var loginButton: some View {
        Button(action: { Task { await login() } }) {
            Group {
                if authService.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Sign In to CareLens")
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(DiamondButtonStyle())
        .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
        .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
    }

    private var demoCredentials: some View {
        VStack(spacing: 8) {
            Text("Quick demo sign-in")
                .font(.caption.bold())
                .foregroundStyle(CareLensTheme.Colors.textTertiary)

            Text("Tap a role to fill credentials, then sign in")
                .font(.caption2)
                .foregroundStyle(CareLensTheme.Colors.textTertiary)

            Button(action: { email = "admin@carelens.health"; password = "CareLens2026!" }) {
                HStack {
                    DiamondShape().fill(CareLensTheme.Colors.accentMagenta).frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Administrator (full access)")
                            .font(.caption.weight(.semibold))
                        Text("admin@carelens.health")
                            .font(.caption2)
                    }
                }
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }

            Button(action: { email = "clinician@carelens.health"; password = "password123" }) {
                HStack {
                    DiamondShape().fill(CareLensTheme.Colors.accentMint).frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clinician (professional tier)")
                            .font(.caption.weight(.semibold))
                        Text("clinician@carelens.health")
                            .font(.caption2)
                    }
                }
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }
        }
        .padding(.top, 20)
    }

    private func login() async {
        _ = await authService.login(email: email, password: password)
    }
}
