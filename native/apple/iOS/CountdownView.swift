import SwiftUI

struct CountdownView: View {
    @EnvironmentObject private var store: LifeStore
    @State private var showSettings = false
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Label("moment.", systemImage: "hourglass").font(.system(size: 26, weight: .semibold))
                    Spacer()
                    Button { showSettings = true } label: {
                        Image(systemName: "slider.horizontal.3").font(.title3).frame(width: 46, height: 46)
                            .overlay(Circle().stroke(MomentStyle.line))
                    }.accessibilityLabel("Open settings")
                }.padding(.bottom, 35)
                Text("A LITTLE PERSPECTIVE").font(.caption2.weight(.semibold)).tracking(2).foregroundStyle(MomentStyle.muted)
                Text("Time ahead.").font(.system(size: 39, weight: .regular)).padding(.top, 10).padding(.bottom, 18)
                Button { showSettings = true } label: {
                    HStack(spacing: 12) {
                        Text("Age \(store.settings.age())")
                        Text("—").foregroundStyle(MomentStyle.muted)
                        Text("Milestone \(store.settings.targetAge)")
                        Image(systemName: "chevron.right").font(.caption2)
                    }.font(.subheadline).padding(.horizontal, 17).frame(minHeight: 44)
                        .background(MomentStyle.line.opacity(0.5), in: Capsule())
                }
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    VStack(spacing: 23) {
                        CountdownRing(settings: store.settings, now: context.date).frame(maxWidth: 324).padding(.top, 27)
                        HStack(spacing: 8) {
                            ForEach(TimeUnit.allCases) { unit in
                                Button { store.select(unit) } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(unit.title).font(.subheadline).foregroundStyle(MomentStyle.muted)
                                        Text(store.settings.total(unit, at: context.date), format: .number)
                                            .font(.system(size: 19, weight: .medium)).monospacedDigit().minimumScaleFactor(0.55).lineLimit(1)
                                        Capsule().fill(store.settings.unit == unit ? MomentStyle.green : .clear).frame(width: 14, height: 2)
                                    }.frame(maxWidth: .infinity, alignment: .leading).padding(13)
                                        .background(store.settings.unit == unit ? MomentStyle.accent : .clear, in: RoundedRectangle(cornerRadius: 15))
                                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(store.settings.unit == unit ? MomentStyle.accent : MomentStyle.line))
                                }.buttonStyle(.plain)
                                    .accessibilityLabel("\(store.settings.total(unit, at: context.date)) total \(unit.rawValue)")
                                    .accessibilityAddTraits(store.settings.unit == unit ? .isSelected : [])
                            }
                        }
                        if store.settings.remaining(at: context.date) == 0 {
                            Text("You’ve reached this milestone. Choose your next one in settings.").font(.subheadline).multilineTextAlignment(.center)
                        }
                    }
                }
                HStack {
                    Label("Time ahead", systemImage: "circle.fill").labelStyle(.titleAndIcon)
                    Spacer()
                    Text((store.settings.exactBirthday ? "Until " : "Approx. ") + store.settings.targetAt.formatted(date: .abbreviated, time: .omitted))
                }.font(.caption2).foregroundStyle(MomentStyle.muted).padding(.top, 17)
                Text("A milestone you choose. Not a prediction.").font(.footnote).foregroundStyle(MomentStyle.muted).padding(.top, 32)
                Text("MAKE TODAY COUNT").font(.system(size: 10, weight: .medium)).tracking(2).foregroundStyle(MomentStyle.muted).padding(.top, 40)
            }.frame(maxWidth: 500).padding(24).frame(maxWidth: .infinity)
        }.background(MomentStyle.background).foregroundStyle(MomentStyle.ink)
            .sheet(isPresented: $showSettings) { SettingsView().environmentObject(store) }
    }
}
