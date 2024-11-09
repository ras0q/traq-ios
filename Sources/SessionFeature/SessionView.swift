import ComposableArchitecture
import SwiftUI
import TraqAPI

extension Components.Schemas.User: Identifiable {}

package struct Session: Reducer {
    @ObservableState
    package struct State {
        var isLogined: Bool = false
        @Shared(.inMemory("users"))
        package var users: [Components.Schemas.User] = []

        package init(isLogined: Bool = false) {
            self.isLogined = isLogined
        }
    }

    package enum Action {
        case view(ViewAction)
        case `internal`(InternalAction)

        package enum ViewAction {
            case onAppear
            case loginButtonTapped(name: String, password: String)
        }

        package enum InternalAction {
            case getMeResponse(Operations.getMe.Output)
            case getUsersResponse(Operations.getUsers.Output)
            case loginResponse(Operations.login.Output)
        }
    }

    package init() {}

    package var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    return .merge(
                        .run { send in
                            let getMeResponse = try await traqAPIClient.getMe()
                            await send(.internal(.getMeResponse(getMeResponse)))
                        },
                        .run { send in
                            let getUsersResponse = try await traqAPIClient.getUsers(
                                .init(query: .init(include_hyphen_suspended: true))
                            )
                            await send(.internal(.getUsersResponse(getUsersResponse)))
                        }
                    )
                case let .loginButtonTapped(name: name, password: password):
                    return .run { send in
                        let response = try await traqAPIClient.login(
                            body: .some(.json(.init(name: name, password: password)))
                        )
                        await send(.internal(.loginResponse(response)))
                    }
                }
            case let .internal(internalAction):
                switch internalAction {
                case let .getMeResponse(response):
                    switch response {
                    case .ok:
                        state.isLogined = true
                    default:
                        state.isLogined = false
                        print(response)
                    }
                case let .getUsersResponse(response):
                    switch response {
                    case let .ok(okResponse):
                        do {
                            state.users = try okResponse.body.json
                        } catch {
                            print(error)
                        }
                    default:
                        print(response)
                    }
                case let .loginResponse(response):
                    switch response {
                    case .noContent:
                        state.isLogined = true
                    default:
                        state.isLogined = false
                        print(response)
                    }
                }
                return .none
            }
        }
    }
}

package struct SessionView<Content: View>: View {
    @State private var id: String = ""
    @State private var password: String = ""
    private let store: StoreOf<Session>
    private let contentView: () -> Content

    package init(store: StoreOf<Session>, contentView: @escaping () -> Content) {
        self.store = store
        self.contentView = contentView
    }

    package var body: some View {
        VStack(alignment: .center, spacing: 16) {
            if store.isLogined {
                contentView()
            } else {
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
                    store.send(.view(.loginButtonTapped(name: id, password: password)))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            store.send(.view(.onAppear))
        }
    }

    private var borderStyle: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(.primary, lineWidth: 1)
    }
}

#Preview {
    SessionView(
        store: .init(initialState: Session.State()) {
            Session()
                ._printChanges()
        }
    ) {
        Text("Login succeeded!")
    }
}
