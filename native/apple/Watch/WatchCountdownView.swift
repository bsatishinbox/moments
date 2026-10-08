import SwiftUI

struct WatchCountdownView: View {
    @EnvironmentObject private var store: LifeStore
    var body: some View {
        NavigationStack {
            ScrollView {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    CountdownRing(settings: store.settings, now: context.date, compact: true)
                        .padding(.horizontal, 9)
                        .onTapGesture { nextUnit() }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Double tap to switch between days, hours, and minutes")
                        .accessibilityAction { nextUnit() }
                }
                Picker("Unit", selection: Binding(get: {store.settings.unit}, set: {store.select($0)})) {
                    ForEach(TimeUnit.allCases) { Text($0.title).tag($0) }
                }.pickerStyle(.navigationLink).font(.caption)
                NavigationLink { WatchSettingsView() } label: {
                    Text("Milestone \(store.settings.targetAge)").font(.caption)
                }
            }.navigationTitle("moment.").tint(MomentStyle.accent)
        }
    }
    private func nextUnit() {
        let units = TimeUnit.allCases
        store.select(units[((units.firstIndex(of: store.settings.unit) ?? 0) + 1) % units.count])
    }
}

struct WatchSettingsView: View {
    @EnvironmentObject private var store: LifeStore
    @Environment(\.dismiss) private var dismiss
    @State private var age = 37
    @State private var target = 60
    @State private var error: String?
    var body: some View {
        Form {
            Picker("Your age", selection: $age) { ForEach(0..<120, id: \.self) { Text("\($0)").tag($0) } }
            Picker("Milestone", selection: $target) { ForEach(1...120, id: \.self) { Text("\($0)").tag($0) } }
            if let error { Text(error).font(.caption).foregroundStyle(.red) }
            Button("Save timeline") {
                do { try store.save(age: age, target: target); dismiss() }
                catch { self.error = error.localizedDescription }
            }.tint(MomentStyle.accent)
            Text("A milestone you choose. Not a prediction.").font(.caption2).foregroundStyle(.secondary)
        }.navigationTitle("Your timeline")
            .onAppear { age = store.settings.age(); target = store.settings.targetAge }
    }
}
