//
//  AuthenticationView.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 27/10/25.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel: AuthenticationViewModel

    @EnvironmentObject var router: NavigationRouter
    @State private var authWithToken: Bool = false
    @State private var showPassword: Bool = false

    init(viewModel: @autoclosure @escaping () -> AuthenticationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            Color.indigoBrand

            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Image("bwell-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 122)

                        Text(LocalizedStringResource.Authentication.authenticationParagraph)
                            .padding(.leading, 10)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.sky)
                    }

                    Spacer()
                }
                .padding(.top, 150)
                .padding(.bottom, 90)

                VStack {
                   if !viewModel.apiKeyValidated {
                        apikey
                    } else {
                        signInView
                            .transition(.asymmetric(insertion: .move(edge: .trailing),
                                                    removal: .move(edge: .leading)))
                    }
                    Spacer()
                }
                .padding(.top, 28)
                .padding(.horizontal, 24)
                .background(.canvas)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 28, topTrailing: 28)))
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.3), value: viewModel.apiKeyValidated)
    }

    // MARK:
    @ViewBuilder
    var signInView: some View {
        Group {
            HStack {
                PillView(text: String(localized: LocalizedStringResource.Authentication.stepTwo),
                         textColor: .indigoBrand, pillColor: .sky)
                Spacer()
                PillView(icon: "checkmark",
                         text: String(localized: LocalizedStringResource.Authentication.apiKeyVerified),
                         textColor: .success, pillColor: .successOn)
            }

            Text(LocalizedStringResource.Authentication.signIn)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 16)
                .padding(.bottom, 6)

            if authWithToken {
                Text(LocalizedStringResource.Authentication.pasteOauthToken)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 15))
                    .foregroundStyle(.muted)
                    .padding(.bottom, 16)
            }

            Group {
                if authWithToken {
                    emailAndPassword

                    if let emailError = viewModel.emailErrorMessage, let passwordError = viewModel.passwordErrorMessage {
                        ErrorMessageView("\(emailError) \(passwordError)")
                    }
                } else {
                    oauthToken

                    if let errorMessage = viewModel.errorMessage {
                        ErrorMessageView(errorMessage)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            BWellButton(title: String(localized: LocalizedStringResource.Authentication.signIn),
                        textColor: .white, buttonColor: .action, isLoading: viewModel.isLoading) {
                authWithToken ? viewModel.loginWithOAuthToken() : viewModel.loginWithEmailAndPassword()
            }
                        .padding(.top, 10)
                        .opacity(signInButtonBehaviour() ? 0.5 : 1.0)
                        .disabled(signInButtonBehaviour())

            Button {
                authWithToken.toggle()
            } label: {
                Group {
                    if authWithToken {
                        Text(String(localized: LocalizedStringResource.Authentication.useEmailAndPassword))
                    } else {
                        Text(String(localized: LocalizedStringResource.Authentication.useOauthToken))
                    }
                }
                .foregroundStyle(.action)
                .font(.system(size: 17))
                .padding(.top, 8)
            }
        }
    }

    // MARK: Email and Password subview
    @ViewBuilder
    var emailAndPassword: some View {
        Group {
            Grid(alignment: .leading) {
                GridRow {
                    Text(String(localized: LocalizedStringResource.Authentication.email))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.ink)

                    TextField("",
                              text: $viewModel.email,
                              prompt: Text("name@example.com"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Divider()
                    .padding(.leading, 90)

                GridRow {
                    Text(String(localized: LocalizedStringResource.Authentication.password))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.ink)

                    if showPassword && !viewModel.password.isEmpty {
                        TextField("", text: $viewModel.password)
                    } else {
                        SecureField("",
                                    text: $viewModel.password,
                                    prompt: Text("Required"))
                    }

                    if !viewModel.password.isEmpty {
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .tint(.indigoDeep)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .overlay {
                if let _ = viewModel.emailErrorMessage, let _ = viewModel.passwordErrorMessage {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.alert, lineWidth: 2)
                }
            }
        }
    }

    // MARK: OAuth Token subview
    @ViewBuilder
    var oauthToken: some View {
        VStack(spacing: .zero) {
            HStack {
                Text(LocalizedStringResource.Authentication.oauthToken)
                    .font(.system(size: 13))
                    .foregroundStyle(.muted)
                Spacer()

                if viewModel.oauthToken.isEmpty {
                    PasteTextButton { text in
                        viewModel.pasteOAuthToken([text])
                    }
                } else {
                    Button("Clear") { viewModel.oauthToken = "" }
                        .font(.subheadline.weight(.semibold))
                }
            }

            TextField("",
                      text: $viewModel.oauthToken,
                      prompt: Text("Paste token"))
            .frame(height: 60)
            .lineLimit(2)
        }
        .padding(.bottom, 12)
        .padding(.horizontal, 16)
        .overlay {
            if let _ = viewModel.errorMessage {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.alert, lineWidth: 2)
            }
        }
    }

    // MARK: API Key subview
    @ViewBuilder
    var apikey: some View {
        Group {
            PillView(text: String(localized: LocalizedStringResource.Authentication.stepOne),
                     textColor: .indigoBrand, pillColor: .sky)
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(LocalizedStringResource.Authentication.connect)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 16)
                .padding(.bottom, 6)

            Text(LocalizedStringResource.Authentication.authSubtext)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 15))
                .foregroundStyle(.muted)
                .padding(.bottom, 16)

            Grid(alignment: .leading) {
                GridRow {
                    Text(String(localized: LocalizedStringResource.Authentication.apiKey))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.ink)

                    SecureField("",
                                text: $viewModel.apiKey,
                                prompt: Text("Required").font(.system(size: 17))
                    )

                    // TODO: Fix paste action for API Key
                    Button(viewModel.oauthToken.isEmpty ? "Paste" : "Clear") {
                        print("Paste button tapped")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.action)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .padding(.vertical, 10)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                if let _ = viewModel.errorMessage {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.alert, lineWidth: 1.5)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                ErrorMessageView(errorMessage)
            }

            BWellButton(title: String(localized: LocalizedStringResource.Authentication.authenticate),
                        textColor: .white,
                        buttonColor: .action,
                        isLoading: viewModel.isLoading) {
                viewModel.initializeSDK()
            }.padding(.top, 10)
        }
    }
}

private struct ErrorMessageView: View {
    var errorMessage: String

    init(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.alert)

            Text(errorMessage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.alert)

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

private struct PillView: View {
    var icon: String = ""
    var text: String
    var textColor: Color
    var pillColor: Color

    var body: some View {
        HStack(spacing: 4) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.success)
                    .opacity(1)
            }

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(textColor)
                .opacity(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(pillColor)
        .clipShape(.capsule)
    }
}

extension AuthenticationView {
    private func signInButtonBehaviour() -> Bool {
        if authWithToken {
            return viewModel.oauthToken.isEmpty
        } else {
            return viewModel.email.isEmpty || viewModel.password.isEmpty
        }
    }
}

#Preview {
    AuthenticationView(viewModel: AppContainer.preview.makeAuthenticationViewModel())
        .environmentObject(NavigationRouter())
        .environmentObject(AppContainer.preview.makeAuthenticationViewModel())
}
