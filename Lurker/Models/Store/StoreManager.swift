//
//  StoreManager.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 01/07/2026.
//

import StoreKit
import SwiftUI

/// Pure-patronage store. Nothing in the app is gated — this only tracks whether
/// the user currently holds the Supporter subscription so we can show a badge.
///
/// - "Lurker Supporter" (auto-renewable monthly): supporter status + badge.
/// - "Generous Tip" (consumable): repeatable thank-you that grants nothing.
@MainActor
@Observable
final class StoreManager {
    @ObservationIgnored static let shared = StoreManager()

    static let supporterMonthlyID = "com.SilverMarcs.SwiftDdit.supporter.monthly"
    static let generousTipProductID = "com.SilverMarcs.SwiftDdit.generoustip"

    /// Cached so the badge is correct at launch before the async StoreKit check
    /// completes (avoids a one-frame flash for returning supporters).
    @ObservationIgnored private let cachedSupporterKey = "cached_is_supporter"

    /// Source of truth is `Transaction.currentEntitlements`; mirrored here for UI.
    private(set) var isSupporter: Bool {
        didSet { UserDefaults.standard.set(isSupporter, forKey: cachedSupporterKey) }
    }

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    private init() {
        isSupporter = UserDefaults.standard.bool(forKey: cachedSupporterKey)
        // Catches transactions that arrive outside a purchase: renewals,
        // Ask-to-Buy approvals, and entitlements synced from another device.
        updatesTask = Task { [weak self] in
            for await update in StoreKit.Transaction.updates {
                await self?.handle(transactionResult: update)
            }
        }
    }

    deinit { updatesTask?.cancel() }

    func start() async {
        await refreshEntitlements()
    }

    /// `currentEntitlements` only yields active, unexpired entitlements, so an
    /// expired/canceled subscription drops `isSupporter` back to false on its own.
    func refreshEntitlements() async {
        var entitled = false
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.supporterMonthlyID,
               transaction.revocationDate == nil {
                entitled = true
            }
        }
        isSupporter = entitled
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func handle(transactionResult: VerificationResult<StoreKit.Transaction>) async {
        guard case .verified(let transaction) = transactionResult else { return }
        if transaction.productID == Self.supporterMonthlyID {
            await refreshEntitlements()
        }
        // Consumable tip grants nothing — finishing it is all that's needed.
        await transaction.finish()
    }
}
