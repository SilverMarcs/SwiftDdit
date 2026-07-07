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
                    ProductView(id: StoreManager.smallTipProductID) {
                        productIcon("cup.and.saucer.fill", tint: .brown)
                    }
                    .productViewStyle(ProminentPriceProductStyle())

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

                // Required by App Store Guideline 3.1.2(c) for the auto-renewing
                // Supporter subscription: functional links to the privacy policy
                // and Terms of Use (EULA) must be present in the purchase flow.
                // We use Apple's standard EULA; the subscription's title, length,
                // and price are shown by ProductView above.
                Section {
                    Link("Privacy Policy",
                         destination: URL(string: "https://appstore-support.vercel.app/lurker/privacy")!)
                    Link("Terms of Use (EULA)",
                         destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                } footer: {
                    Text("Lurker Supporter is a \(Text("$3.99/month").fontWeight(.semibold)) auto-renewing subscription. Payment is charged to your Apple Account at confirmation. It renews automatically unless cancelled at least 24 hours before the end of the current period; manage or cancel in your Apple Account settings.")
                }
                // The app installs a global `openURL` interceptor (URLHandlingModifier)
                // that routes taps to an in-app browser; it silently swallows these
                // external links from inside this sheet. Force the system browser so
                // the required legal links are always functional (Guideline 3.1.2c).
                .environment(\.openURL, OpenURLAction { _ in .systemAction })
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
        if let product = configuration.product {
            HStack(spacing: 12) {
                configuration.icon

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
            }
        } else {
            // Still loading (or unavailable): a plain centered spinner instead of
            // StoreKit's redacted placeholder. Fixed height keeps the row from
            // jumping when the real product content swaps in.
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 44)
        }
    }
}

#Preview {
    SupporterView()
}
