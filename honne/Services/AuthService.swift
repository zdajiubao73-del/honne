import Foundation

/// Supabase REST API で匿名認証を管理するサービス
/// SDK不使用 → URLSession で直接 Supabase Auth API を呼ぶ
@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var userId: UUID?
    @Published private(set) var accessToken: String?

    private let baseURL = Constants.supabaseURL
    private let anonKey = Constants.supabaseAnonKey
    private let userIdKey  = "honne.supabase.userId"
    private let tokenKey   = "honne.supabase.accessToken"
    private let expiryKey  = "honne.supabase.tokenExpiry"

    private init() {
        // 保存済みの認証情報を復元
        if let savedId = UserDefaults.standard.string(forKey: userIdKey),
           let uuid = UUID(uuidString: savedId) {
            userId = uuid
            accessToken = UserDefaults.standard.string(forKey: tokenKey)
        }
    }

    /// アプリ起動時に呼ぶ。保存済みトークンが有効なら再利用、なければ匿名サインイン
    func signInAnonymously() async {
        // 保存済みトークンがまだ有効なら再利用
        if userId != nil, let expiry = UserDefaults.standard.object(forKey: expiryKey) as? Date,
           expiry > Date() {
            return
        }

        // 匿名サインイン
        do {
            let (uid, token, expiry) = try await anonymousSignIn()
            userId = uid
            accessToken = token
            persist(userId: uid, token: token, expiry: expiry)
        } catch {
            // オフライン等のフォールバック: ローカルUUIDを使用
            userId = localFallbackUUID()
            print("[AuthService] 匿名認証失敗: \(error.localizedDescription)")
        }
    }

    // MARK: - Private

    private func anonymousSignIn() async throws -> (UUID, String, Date) {
        guard let url = URL(string: "\(baseURL)/auth/v1/signup") else {
            throw AuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = "{}".data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw AuthError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
        guard let uid = UUID(uuidString: decoded.user.id) else {
            throw AuthError.invalidUserId
        }

        let expiry = Date().addingTimeInterval(TimeInterval(decoded.expiresIn ?? 3600))
        return (uid, decoded.accessToken, expiry)
    }

    private func persist(userId: UUID, token: String, expiry: Date) {
        UserDefaults.standard.set(userId.uuidString, forKey: userIdKey)
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(expiry, forKey: expiryKey)
    }

    private func localFallbackUUID() -> UUID {
        if let saved = UserDefaults.standard.string(forKey: userIdKey),
           let uuid = UUID(uuidString: saved) {
            return uuid
        }
        let new = UUID()
        UserDefaults.standard.set(new.uuidString, forKey: userIdKey)
        return new
    }
}

// MARK: - Response Models

private struct AuthResponse: Decodable {
    let accessToken: String
    let expiresIn: Int?
    let user: UserInfo

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn   = "expires_in"
        case user
    }

    struct UserInfo: Decodable {
        let id: String
    }
}

enum AuthError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidUserId

    var errorDescription: String? {
        switch self {
        case .invalidURL:      return "URLが不正です"
        case .invalidResponse: return "認証レスポンスエラー"
        case .invalidUserId:   return "ユーザーIDの取得失敗"
        }
    }
}
