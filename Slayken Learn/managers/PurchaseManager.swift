import Foundation
import StoreKit
internal import Combine

@MainActor
final class PurchaseManager: ObservableObject {
    // MARK: - Published States
    @Published private(set) var purchasedIDs: Set<String> = []
    
    /// 🔁 Signalisiert UI-Views (z. B. Code-Shop), dass ein Reset oder Restore stattgefunden hat.
    @Published var purchaseStateDidChange = false

    // MARK: - Private Properties
    private let defaultsKey = "PurchasedProducts"
    private var updatesTask: Task<Void, Never>?

    // MARK: - Init
    init() {
        loadPurchased()
        observeTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Kaufstatus prüfen
    func isPurchased(_ id: String) -> Bool {
        purchasedIDs.contains(id)
    }

    // MARK: - Lokales Speichern
    private func savePurchased() {
        UserDefaults.standard.set(Array(purchasedIDs), forKey: defaultsKey)
    }

    private func loadPurchased() {
        if let saved = UserDefaults.standard.array(forKey: defaultsKey) as? [String] {
            purchasedIDs = Set(saved)
        } else {
            purchasedIDs = []
        }
    }

    func markPurchased(_ id: String) {
        purchasedIDs.insert(id)
        savePurchased()
        purchaseStateDidChange.toggle() // 🔁 UI informieren
        print("✅ Produkt gekauft: \(id)")
    }

    // MARK: - 🧨 Alles zurücksetzen (Debug/Test)
    func resetPurchases() async {
        await MainActor.run {
            print("🧨 Alle Käufe werden zurückgesetzt …")

            // ✅ 1. Lokalen Speicher leeren
            purchasedIDs.removeAll()
            UserDefaults.standard.removeObject(forKey: defaultsKey)

            // ✅ 2. Änderung signalisieren
            purchaseStateDidChange.toggle()

            print("✅ Alle Käufe erfolgreich gelöscht.")
        }
    }


    // MARK: - Käufe wiederherstellen
    func restorePurchases() async {
        var restored: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                restored.insert(transaction.productID)
            }
        }

        purchasedIDs = restored
        savePurchased()

        // 🔁 UI benachrichtigen
        purchaseStateDidChange.toggle()
        print("🔄 Käufe wiederhergestellt: \(purchasedIDs)")
    }

    // MARK: - Live-Überwachung neuer Käufe
    private func observeTransactions() {
        updatesTask = Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = result {
                    await MainActor.run {
                        self.purchasedIDs.insert(transaction.productID)
                        self.savePurchased()
                        self.purchaseStateDidChange.toggle()
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
