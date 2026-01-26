import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false

    func logIn() {
        isLoggedIn = true
    }

    func logOut() {
        isLoggedIn = false
    }
}
