import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: LifeStore
    @Environment(\.dismiss) private var dismiss
    @State private var ageText = "37"
    @State private var targetText = "60"
    @State private var useBirthday = false
    @State private var birthday = Date()
    @State private var error: String?
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Your age")
                        Spacer()
                        TextField("37", text: $ageText).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 90).disabled(useBirthday)
                    }
                    HStack {
                        Text("Your milestone")
                        Spacer()
                        TextField("60", text: $targetText).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 90)
                    }
                    HStack {
                        ForEach([60,70,80,90], id: \.self) { target in
                            Button("\(target)") { targetText = String(target) }
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(targetText == String(target) ? MomentStyle.accent : MomentStyle.line.opacity(0.4), in: RoundedRectangle(cornerRadius: 9))
                                .buttonStyle(.plain)
                        }
                    }
                }
                Section {
                    Toggle("Use my birthday", isOn: $useBirthday)
                    if useBirthday {
                        DatePicker("Date of birth", selection: $birthday, in: ...Date(), displayedComponents: .date)
                            .onChange(of: birthday) { _, date in
                                var settings = store.settings
                                settings.bornAt = date
                                ageText = String(settings.age())
                            }
                    }
                } footer: {
                    Text("With age only, we start as if your birthday is today. Add your birthday for an exact calendar countdown.")
                }
                if let error { Section { Text(error).foregroundStyle(.red).font(.subheadline) } }
                Section {
                    Button("Save my timeline") { save() }.fontWeight(.semibold).frame(maxWidth: .infinity).listRowBackground(MomentStyle.accent)
                } footer: {
                    Text("Saved on this device. Your paired Apple Watch syncs when available. A personal milestone, not a lifespan prediction.")
                }
            }.scrollContentBackground(.hidden).background(MomentStyle.background).tint(MomentStyle.green)
                .navigationTitle("Make it yours.")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
                .onAppear {
                    ageText = String(store.settings.age())
                    targetText = String(store.settings.targetAge)
                    birthday = store.settings.bornAt
                    useBirthday = store.settings.exactBirthday
                }
        }
    }
    private func save() {
        guard let age = Int(ageText), let target = Int(targetText) else { error = "Enter your age and milestone as whole numbers."; return }
        do {
            try store.save(age: age, target: target, birthday: useBirthday ? birthday : nil, clearBirthday: !useBirthday)
            dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
