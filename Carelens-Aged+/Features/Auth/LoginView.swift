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

            Text("CareLens Age+")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.4, green: 0.85, blue: 0.9),
                            Color(red: 0.3, green: 0.65, blue: 0.95)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Text("Aged Care Assessment Platform")
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
        }
    }

    private var loginForm: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption.bold())
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                TextField("", text: $email)
                    .textFieldStyle(.plain)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption.bold())
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                HStack {
                    if showPassword {
                        TextField("", text: $password)
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    } else {
                        SecureField("", text: $password)
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
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
                        Text("Sign In")
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
            Text("Demo Credentials")
                .font(.caption.bold())
                .foregroundStyle(CareLensTheme.Colors.textTertiary)

            Button(action: { email = "admin@carelens.health"; password = "CareLens2026!" }) {
                HStack {
                    DiamondShape().fill(CareLensTheme.Colors.accentMagenta).frame(width: 8, height: 8)
                    Text("Admin: admin@carelens.health")
                        .font(.caption)
                }
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }

            Button(action: { email = "clinician@carelens.health"; password = "password123" }) {
                HStack {
                    DiamondShape().fill(CareLensTheme.Colors.accentMint).frame(width: 8, height: 8)
                    Text("Clinician: clinician@carelens.health")
                        .font(.caption)
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
