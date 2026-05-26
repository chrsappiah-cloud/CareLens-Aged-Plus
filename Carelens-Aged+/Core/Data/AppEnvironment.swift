import Foundation

/// Runtime configuration for backends (Supabase primary, Cloudflare backup).
enum AppEnvironment {
    static var supabaseURL: String {
        ProcessInfo.processInfo.environment["SUPABASE_URL"]
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
            ?? SupabaseConfig.defaultProjectURL
    }

    static var supabaseAnonKey: String {
        ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
            ?? ""
    }

    static var cloudflareWorkerURL: String {
        ProcessInfo.processInfo.environment["CLOUDFLARE_WORKER_URL"]
            ?? Bundle.main.object(forInfoDictionaryKey: "CLOUDFLARE_WORKER_URL") as? String
            ?? ""
    }

    static var cloudflareBackupToken: String {
        ProcessInfo.processInfo.environment["CLOUDFLARE_BACKUP_TOKEN"]
            ?? Bundle.main.object(forInfoDictionaryKey: "CLOUDFLARE_BACKUP_TOKEN") as? String
            ?? ""
    }

    static var cloudKitContainerID: String {
        "iCloud.wcs.Carelens-Aged"
    }

    /// Use in-memory / mock transports when credentials are not configured.
    static var usesMockBackends: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITesting")
            || supabaseURL.contains("your-project")
            || supabaseAnonKey.isEmpty
    }

    static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    /// CloudKit crashes in XCTest / unsigned simulator hosts unless explicitly enabled.
    static var shouldUseCloudKit: Bool {
        if isRunningTests { return false }
        if usesMockBackends { return false }
        if ProcessInfo.processInfo.environment["ENABLE_CLOUDKIT"] == "1" { return true }
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }
}
