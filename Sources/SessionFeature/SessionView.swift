import Actuate
import Model
import SessionRepository
import SwiftUI

package struct SessionView<Content: View>: View {
    @Environment(TraqCatalog.self) private var catalog
    @State private var id: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn = false

    private var checkSession = EnvironmentAsyncAction(\.sessionRepository) {
        (repository: any SessionRepository, _: EmptyInput) in
        try await repository.checkSession()
    }

    private var login = EnvironmentAsyncAction(\.sessionRepository) { repository, input in
        try await repository.login(input)
    }

    private var loadCatalog = EnvironmentAsyncAction(\.sessionRepository) {
        (repository: any SessionRepository, _: EmptyInput) in
        try await repository.fetchCatalog()
    }

    private var fetchMe = EnvironmentAsyncAction(\.sessionRepository) {
        (repository: any SessionRepository, _: EmptyInput) in
        try await repository.fetchMe()
    }

    private let contentView: () -> Content

    package init(contentView: @escaping () -> Content) {
        self.contentView = contentView
    }

    package var body: some View {
        VStack(alignment: .center, spacing: 16) {
            if isLoggedIn {
                contentView()
            } else {
                loginForm
            }
        }
        .task {
            await restoreSession()
        }
    }

    private var loginForm: some View {
        Group {
            TextField("ID", text: $id)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .overlay { borderStyle }
            SecureField("Password", text: $password)
                .keyboardType(.asciiCapable)
                .padding()
                .overlay { borderStyle }
            Button("ログイン") {
                Task {
                    await performLogin()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(login.phase.isLoading)

            if case .failure(let error, _) = login.phase {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.callout)
            }
        }
    }

    private var borderStyle: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(.primary, lineWidth: 1)
    }

    private func restoreSession() async {
        await checkSession.run(input: EmptyInput())
        guard case .success(let loggedIn) = checkSession.phase, loggedIn else {
            return
        }
        await bootstrapCatalog()
    }

    private func performLogin() async {
        let input = LoginInput(name: id, password: password)
        await login.run(input: input)
        guard case .success = login.phase else {
            return
        }
        await bootstrapCatalog()
    }

    private func bootstrapCatalog() async {
        await loadCatalog.run(input: EmptyInput())
        await fetchMe.run(input: EmptyInput())
        guard case .success(let catalogData) = loadCatalog.phase,
            case .success(let currentUser) = fetchMe.phase
        else {
            return
        }
        catalog.users = catalogData.users
        catalog.stamps = catalogData.stamps
        catalog.currentUser = currentUser
        isLoggedIn = true
    }
}

#Preview {
    SessionView {
        Text("Login succeeded!")
    }
    .environment(\.sessionRepository, PreviewSessionRepository(isLoggedIn: true))
    .environment(TraqCatalog())
}
