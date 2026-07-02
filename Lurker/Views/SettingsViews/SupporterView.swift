//
//  SupporterView.swift
//  SwiftDdit
//
//  Created by Zabir Raihan on 01/07/2026.
//

import SwiftUI
import StoreKit

/// Pure-patronage sheet: an optional monthly Supporter subscription and a
/// repeatable tip. Nothing here unlocks app features — it's support only.
/// StoreKit's `ProductView` owns pricing and the purchase flow; the layout and
/// the subscription disclosure are ours.
struct SupporterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreManager.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    header
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }

                Section("Monthly Support") {
                    ProductView(id: StoreManager.supporterMonthlyID) {
                        productIcon("heart.fill", tint: .pink)
                    }
                    .productViewStyle(ProminentPriceProductStyle())
                }

                Section("Leave a Tip") {
                    ProductView(id: StoreManager.generousTipProductID) {
                        productIcon("cup.and.saucer.fill", tint: .orange)
                    }
                    .productViewStyle(ProminentPriceProductStyle())
                }

                Section {
                    Button("Restore Purchases") {
                        Task { await store.restore() }
                    }
                }
            }
            .contentMargins(.top, 10)
            .onInAppPurchaseCompletion { _, result in
                // Flip the header immediately after a purchase; the StoreManager
                // updates listener also fires.
                if case .success = result {
                    await store.refreshEntitlements()
                }
            }
            .navigationTitle("Support")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(.pink.opacity(0.15))
                    .frame(width: 84, height: 84)
                Image(systemName: store.isSupporter ? "heart.fill" : "heart")
                    .font(.system(size: 38))
                    .foregroundStyle(.pink)
                    .symbolEffect(.bounce, value: store.isSupporter)
            }

            Text(store.isSupporter ? "You're a Supporter" : "Support Lurker")
                .font(.title2.bold())

            Text(store.isSupporter
                 ? "Thank you! Your support keeps Lurker independent and ad-free."
                 : "Lurker is built by one person, with no ads or tracking. Support is entirely optional. Everything in the app is free.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func productIcon(_ name: String, tint: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 22))
            .foregroundStyle(tint)
            .frame(width: 44, height: 44)
            .background(tint.opacity(0.15), in: .rect(cornerRadius: 10))
    }
}

/// A compact product row that keeps StoreKit's purchase handling but shows the
/// price as a filled, prominent button instead of the default plain text.
private struct ProminentPriceProductStyle: ProductViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.icon

            if let product = configuration.product {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                if configuration.hasCurrentEntitlement {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                } else {
                    Button {
                        Task { try? await configuration.purchase() }
                    } label: {
                        Text(product.displayPrice)
                            .font(.callout.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
            } else {
                // Product still loading (or unavailable).
                Text("Loading…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 8)
                ProgressView()
            }
        }
    }
}

#Preview {
    SupporterView()
}
