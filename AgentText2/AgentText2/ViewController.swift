//
//  ViewController.swift
//  AgentText2
//
//  Created by Max Xiao on 5/13/26.
//

import Cocoa
import Combine
import SwiftUI

final class ViewController: NSViewController {
    private var hostingController: NSHostingController<AgentTextRootView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let rootView = AgentTextRootView()
        let hostingController = NSHostingController(rootView: rootView)
        self.hostingController = hostingController

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "AgentText"
        view.window?.backgroundColor = .black
        view.window?.titlebarAppearsTransparent = true
        view.window?.isMovableByWindowBackground = true
    }
}

private struct AgentTextRootView: View {
    @State private var screen: Screen = canReadMessagesDatabase() ? .permissions : .createAccount
    @State private var email = ""

    enum Screen {
        case createAccount
        case signIn
        case permissions
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            switch screen {
            case .createAccount:
                CreateAccountView(
                    onContinue: { submittedEmail in
                        email = submittedEmail
                        screen = .permissions
                    },
                    onShowSignIn: { screen = .signIn }
                )
            case .signIn:
                SignInView(
                    onSignIn: { submittedEmail in
                        email = submittedEmail
                        screen = .permissions
                    },
                    onShowCreateAccount: { screen = .createAccount }
                )
            case .permissions:
                PermissionsView(
                    email: email.isEmpty ? getMacUsername() : email,
                    onBack: { screen = .signIn }
                )
            }
        }
        .frame(minWidth: 760, minHeight: 620)
    }
}

private struct CreateAccountView: View {
    let onContinue: (String) -> Void
    let onShowSignIn: () -> Void

    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var password = ""
    @State private var isHoveredButton = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email
        case firstName
        case lastName
        case password
    }

    private var isFormValid: Bool {
        isValidEmail(email) && !firstName.isEmpty && !lastName.isEmpty && !password.isEmpty
    }

    var body: some View {
        AuthCard {
            VStack(spacing: 0) {
                AuthHeader(
                    title: "Create your account",
                    subtitle: "Welcome! Please fill in the details to get started."
                )

                AccountPill(username: getMacUsername(), status: nil)
                    .padding(.horizontal, 36)
                    .padding(.bottom, 28)

                GlowingDivider()
                    .padding(.horizontal, 36)
                    .padding(.bottom, 28)

                VStack(spacing: 20) {
                    ModernTextField(
                        title: "EMAIL",
                        placeholder: "Enter your email",
                        text: $email,
                        isFocused: focusedField == .email
                    )
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .firstName }

                    HStack(spacing: 20) {
                        ModernTextField(
                            title: "FIRST NAME",
                            placeholder: "First name",
                            text: $firstName,
                            isFocused: focusedField == .firstName
                        )
                        .focused($focusedField, equals: .firstName)
                        .onSubmit { focusedField = .lastName }

                        ModernTextField(
                            title: "LAST NAME",
                            placeholder: "Last name",
                            text: $lastName,
                            isFocused: focusedField == .lastName
                        )
                        .focused($focusedField, equals: .lastName)
                        .onSubmit { focusedField = .password }
                    }

                    ModernTextField(
                        title: "PASSWORD",
                        placeholder: "Enter your password",
                        text: $password,
                        isSecure: true,
                        isFocused: focusedField == .password
                    )
                    .focused($focusedField, equals: .password)
                    .onSubmit { continueIfValid() }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 36)

                PrimaryActionButton(
                    title: "Continue",
                    isHovered: isHoveredButton,
                    isEnabled: isFormValid,
                    action: continueIfValid
                )
                .padding(.horizontal, 36)
                .padding(.bottom, 28)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHoveredButton = hovering
                    }
                }

                FooterPrompt(text: "Already have an account?", actionTitle: "Sign in", action: onShowSignIn)
                    .padding(.bottom, 48)
            }
        }
        .onAppear { focusedField = .email }
    }

    private func continueIfValid() {
        guard isFormValid else { return }
        onContinue(email)
    }
}

private struct SignInView: View {
    let onSignIn: (String) -> Void
    let onShowCreateAccount: () -> Void

    @State private var password = ""
    @State private var email = ""
    @State private var isHoveredButton = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email
        case password
    }

    private var isFormValid: Bool {
        !password.isEmpty && isValidEmail(email)
    }

    var body: some View {
        AuthCard {
            VStack(spacing: 0) {
                AuthHeader(
                    title: "Sign in to your account",
                    subtitle: "Welcome back! Please enter your details to continue."
                )

                AccountPill(username: getMacUsername(), status: nil)
                    .padding(.horizontal, 36)
                    .padding(.bottom, 28)

                GlowingDivider()
                    .padding(.horizontal, 36)
                    .padding(.bottom, 28)

                VStack(spacing: 20) {
                    ModernTextField(
                        title: "EMAIL",
                        placeholder: "Enter your email",
                        text: $email,
                        isFocused: focusedField == .email
                    )
                    .focused($focusedField, equals: .email)
                    .onSubmit { focusedField = .password }

                    ModernTextField(
                        title: "PASSWORD",
                        placeholder: "Enter your password",
                        text: $password,
                        isSecure: true,
                        isFocused: focusedField == .password
                    )
                    .focused($focusedField, equals: .password)
                    .onSubmit { signInIfValid() }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 36)

                PrimaryActionButton(
                    title: "Sign in",
                    isHovered: isHoveredButton,
                    isEnabled: isFormValid,
                    action: signInIfValid
                )
                .padding(.horizontal, 36)
                .padding(.bottom, 28)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHoveredButton = hovering
                    }
                }

                FooterPrompt(text: "Don't have an account?", actionTitle: "Create account", action: onShowCreateAccount)
                    .padding(.bottom, 48)
            }
        }
        .onAppear { focusedField = .email }
    }

    private func signInIfValid() {
        guard isFormValid else { return }
        onSignIn(email)
    }
}

private struct PermissionsView: View {
    let email: String
    let onBack: () -> Void

    @State private var permissionGranted = canReadMessagesDatabase()
    @State private var isCheckingHealth = false
    @State private var isEnabled = false
    @State private var isHoveredSiteButton = false
    private let permissionPoller = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        LuminescentCard {
            HStack(spacing: 26) {
                VStack(alignment: .leading, spacing: 22) {
                    LogoView(size: 64)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mac Permissions")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(white: 0.84)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        Text("Allow Full Disk Access for AgentText.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(white: 0.5))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    AccountPill(username: email, status: permissionGranted ? "Full Disk Access is enabled" : "Full Disk Access is required")

                    GlowingDivider()

                    WatchingPill(isWatching: isEnabled)

                    Spacer(minLength: 0)
                }
                .frame(width: 300, alignment: .leading)

                VerticalSeparator()
                    .padding(.vertical, 4)

                VStack(spacing: 18) {
                    HStack {
                        Spacer()
                        SmallHealthButton(
                            title: isCheckingHealth ? "Checking..." : "Health check",
                            action: runHealthCheck
                        )
                    }

                    SetupActionButton(
                        icon: permissionGranted ? "checkmark.circle.fill" : "lock.shield.fill",
                        title: permissionGranted ? "Mac permissions enabled" : "Enable Mac permissions",
                        detail: permissionGranted ? "AgentText can read the local Messages database." : "Open Privacy settings and turn on Full Disk Access for AgentText2.",
                        status: permissionGranted ? "Ready" : "Required",
                        isGood: permissionGranted,
                        action: {
                            if permissionGranted {
                                refreshPermissions()
                            } else {
                                openFullDiskAccess()
                            }
                        }
                    )

                    Spacer(minLength: 0)

                    HStack(spacing: 12) {
                        EnableToggleCard(
                            isEnabled: Binding(
                                get: { isEnabled },
                                set: { newValue in
                                    guard permissionGranted else {
                                        showAlert(title: "Mac permissions needed", message: "Enable Full Disk Access before turning on AgentText.")
                                        return
                                    }
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isEnabled = newValue
                                    }
                                }
                            )
                        )

                        SiteActionCard(
                            title: "Open site",
                            isHovered: isHoveredSiteButton,
                            action: openSite
                        )
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isHoveredSiteButton = hovering
                            }
                        }
                    }
                    .frame(height: 74)

                    FooterPrompt(text: "Need to use another account?", actionTitle: "Back", action: onBack)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(width: 330)
            }
            .padding(38)
            .frame(width: 760, height: 430)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.06))
            )
        }
        .onAppear {
            refreshPermissions()
        }
        .onReceive(permissionPoller) { _ in
            refreshPermissions()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshPermissions()
        }
    }

    private func refreshPermissions() {
        permissionGranted = canReadMessagesDatabase()
    }

    private func runHealthCheck() {
        isCheckingHealth = true

        guard let url = URL(string: "http://localhost:3000/health") else {
            isCheckingHealth = false
            return
        }

        URLSession.shared.dataTask(with: url) { _, response, _ in
            let isHealthy = (response as? HTTPURLResponse)?.statusCode == 200

            fetchRecentMessages { messagePreview in
                DispatchQueue.main.async {
                    isCheckingHealth = false
                    showAlert(
                        title: isHealthy ? "Health check passed" : "Health check failed",
                        message: [
                            isHealthy
                                ? "The local AgentText API responded successfully."
                                : "The local AgentText API is not responding at http://localhost:3000/health.",
                            "",
                            "Last 5 messages:",
                            messagePreview
                        ].joined(separator: "\n")
                    )
                }
            }
        }.resume()
    }

    private func fetchRecentMessages(completion: @escaping (String) -> Void) {
        guard var components = URLComponents(string: "http://localhost:3000/messages") else {
            completion("Could not build messages request.")
            return
        }

        components.queryItems = [
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "excludeOwnMessages", value: "false")
        ]

        guard let url = components.url else {
            completion("Could not build messages request.")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let data else {
                completion("Unable to load recent messages.")
                return
            }

            Task { @MainActor in
                do {
                    let result = try JSONDecoder().decode(RecentMessagesResponse.self, from: data)
                    let lines = result.messages.prefix(5).enumerated().map { index, message in
                        "\(index + 1). \(message.displaySender): \(message.previewText)"
                    }
                    completion(lines.isEmpty ? "No recent messages returned." : lines.joined(separator: "\n"))
                } catch {
                    completion("Recent messages returned, but could not be parsed.")
                }
            }
        }.resume()
    }

    private func openSite() {
        if let url = URL(string: "https://agenttext.ai") {
            NSWorkspace.shared.open(url)
        }
    }
}

private struct RecentMessagesResponse: Decodable {
    let messages: [RecentMessage]
}

private struct RecentMessage: Decodable {
    let text: String?
    let sender: String?
    let senderName: String?
    let isFromMe: Bool?

    var displaySender: String {
        if isFromMe == true {
            return "Me"
        }
        if let senderName, !senderName.isEmpty {
            return senderName
        }
        if let sender, !sender.isEmpty {
            return sender
        }
        return "Unknown"
    }

    var previewText: String {
        let value = text?.replacingOccurrences(of: "\n", with: " ") ?? "(no text)"
        if value.count <= 72 {
            return value
        }
        return "\(value.prefix(72))..."
    }
}

private struct AuthCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        LuminescentCard {
            content
                .frame(width: 500)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(white: 0.06))
                )
        }
    }
}

private struct AuthHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 20) {
            LogoView(size: 72)

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(white: 0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(white: 0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 48)
        .padding(.bottom, 36)
    }
}

private struct AccountPill: View {
    let username: String
    let status: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(white: 0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(username)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                if let status {
                    Text(status)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.5))
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: status == nil ? 52 : 62)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

private struct ModernTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var isFocused = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(3)
                .foregroundColor(Color(white: 0.5))

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(.plain)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isFocused ? Color.white.opacity(0.42) : Color.white.opacity(0.14),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.white.opacity(isFocused ? 0.1 : 0.02), radius: isFocused ? 16 : 6)
        }
    }
}

private struct PrimaryActionButton: View {
    let title: String
    let isHovered: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .offset(x: isHovered ? 4 : 0)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(isHovered ? 0.15 : 0.08))
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isHovered ? 0.4 : 0.2),
                                    Color.white.opacity(isHovered ? 0.15 : 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.white.opacity(isHovered ? 0.2 : 0.1), radius: isHovered ? 25 : 15)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

private struct SecondaryActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct SmallHealthButton: View {
    let title: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(
                Capsule()
                    .fill(Color.white.opacity(isHovered ? 0.1 : 0.055))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(isHovered ? 0.22 : 0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.18)) {
                isHovered = hovering
            }
        }
    }
}

private struct EnableToggleCard: View {
    @Binding var isEnabled: Bool

    var body: some View {
        Toggle(isOn: $isEnabled) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Enable")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(isEnabled ? "Watching locally." : "Start local access.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(white: 0.5))
                    .lineLimit(1)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .green))
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 74)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

private struct SiteActionCard: View {
    let title: String
    let isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Open workspace.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.5))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(white: 0.8))
                    .offset(x: isHovered ? 2 : 0, y: isHovered ? -2 : 0)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 74)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isHovered ? 0.08 : 0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(isHovered ? 0.22 : 0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.white.opacity(isHovered ? 0.12 : 0.03), radius: isHovered ? 18 : 8)
        }
        .buttonStyle(.plain)
    }
}

private struct VerticalSeparator: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.02),
                        Color.white.opacity(0.14),
                        Color.white.opacity(0.02)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 1)
    }
}

private struct SetupActionButton: View {
    let icon: String
    let title: String
    let detail: String
    let status: String
    let isGood: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(isGood ? 0.1 : 0.06))
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isGood ? .green : .white)
                }
                .frame(width: 40, height: 40)
                .shadow(color: (isGood ? Color.green : Color.white).opacity(isHovered ? 0.24 : 0.08), radius: 14)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        Text(status)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isGood ? .green : Color(white: 0.58))
                    }

                    Text(detail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.5))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isHovered ? 0.07 : 0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(isHovered ? 0.2 : 0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.white.opacity(isHovered ? 0.1 : 0.03), radius: isHovered ? 18 : 8)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.18)) {
                isHovered = hovering
            }
        }
    }
}

private struct WatchingPill: View {
    let isWatching: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(isWatching ? Color.green : Color(white: 0.35))
                .frame(width: 11, height: 11)
                .shadow(color: (isWatching ? Color.green : Color.clear).opacity(0.75), radius: 8)

            Text(isWatching ? "Watching" : "Paused")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isWatching ? Color(white: 0.78) : Color(white: 0.48))
        }
        .padding(.horizontal, 18)
        .frame(height: 44)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.055))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: (isWatching ? Color.green : Color.white).opacity(isWatching ? 0.16 : 0.04), radius: 18)
    }
}

private struct FooterPrompt: View {
    let text: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(white: 0.5))

            Button(actionTitle, action: action)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .buttonStyle(.plain)
        }
    }
}

private struct PermissionRow: View {
    let title: String
    let detail: String
    let status: String
    let isGood: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isGood ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(isGood ? .green : Color.white.opacity(0.38))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text(detail)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(white: 0.5))
                    .lineLimit(2)
            }

            Spacer()

            Text(status)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isGood ? .green : Color(white: 0.56))
        }
        .padding(.horizontal, 18)
        .frame(height: 68)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

private struct AnimatedBackground: View {
    var body: some View {
        ZStack {
            Color.black

            RadialGradient(
                colors: [
                    Color.white.opacity(0.12),
                    Color.white.opacity(0.04),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 520
            )
            .blur(radius: 12)
        }
        .ignoresSafeArea()
    }
}

private struct LuminescentCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.28),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.24)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.white.opacity(0.11), radius: 34)
    }
}

private struct LogoView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))
            Circle()
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
            Image(systemName: "envelope.fill")
                .font(.system(size: size * 0.36, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(white: 0.74)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(width: size, height: size)
        .shadow(color: Color.white.opacity(0.32), radius: 24)
    }
}

private struct GlowingDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.12),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}

private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

private func getMacUsername() -> String {
    let username = NSUserName()
    return username == "root" || username.isEmpty ? "maxxiao" : username
}

private func canReadMessagesDatabase() -> Bool {
    let messagesDatabaseURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Messages/chat.db")

    guard FileManager.default.fileExists(atPath: messagesDatabaseURL.path) else {
        return false
    }

    guard FileManager.default.isReadableFile(atPath: messagesDatabaseURL.path) else {
        return false
    }

    do {
        let handle = try FileHandle(forReadingFrom: messagesDatabaseURL)
        try handle.close()
        return true
    } catch {
        return false
    }
}

private func openFullDiskAccess() {
    let privacyURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
    NSWorkspace.shared.open(privacyURL)
}

private func showAlert(title: String, message: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = message
    alert.addButton(withTitle: "OK")
    alert.runModal()
}
