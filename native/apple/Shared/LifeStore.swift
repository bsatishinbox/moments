import Foundation
import Combine
import WatchConnectivity
import OSLog

final class LifeStore: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var settings: LifeSettings
    private let key = "moment.settings.v1"
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Moment", category: "WatchSync")

    override init() {
        if let data = UserDefaults.standard.data(forKey: "moment.settings.v1"),
           let stored = try? JSONDecoder().decode(LifeSettings.self, from: data), stored.valid() {
            settings = stored
        } else { settings = .initial() }
        super.init()
        persist()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    func save(age: Int, target: Int, birthday: Date? = nil, clearBirthday: Bool = false) throws {
        settings = try settings.updated(age: age, target: target, birthday: birthday, clearBirthday: clearBirthday)
        persist()
        send()
    }
    func select(_ unit: TimeUnit) {
        settings.unit = unit
        settings.updatedAt = Date()
        settings.changeID = UUID().uuidString
        persist()
        send()
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(data, forKey: key) }
    }
    func synchronize() {
        guard WCSession.isSupported() else { return }
        receive(WCSession.default.receivedApplicationContext)
        send()
    }
    private func send() {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated,
              let data = try? JSONEncoder().encode(settings) else { return }
        #if os(iOS)
        guard WCSession.default.isPaired, WCSession.default.isWatchAppInstalled else { return }
        #endif
        do { try WCSession.default.updateApplicationContext(["settings": data]) }
        catch { log.info("Companion update deferred: \(error.localizedDescription, privacy: .public)") }
    }
    private func receive(_ context: [String: Any]) {
        guard let data = context["settings"] as? Data,
              let remote = try? JSONDecoder().decode(LifeSettings.self, from: data),
              remote.valid(), remote.newer(than: settings) else { return }
        settings = remote
        persist()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { self.synchronize() }
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.receive(applicationContext) }
    }
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    func sessionWatchStateDidChange(_ session: WCSession) { DispatchQueue.main.async { self.synchronize() } }
    #endif
}
