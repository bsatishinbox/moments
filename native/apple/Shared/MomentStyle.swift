import SwiftUI

enum MomentStyle {
    static let background = Color(red: 247/255, green: 248/255, blue: 244/255)
    static let ink = Color(red: 25/255, green: 34/255, blue: 27/255)
    static let muted = Color(red: 98/255, green: 109/255, blue: 99/255)
    static let line = Color(red: 225/255, green: 230/255, blue: 220/255)
    static let accent = Color(red: 198/255, green: 229/255, blue: 157/255)
    static let green = Color(red: 72/255, green: 106/255, blue: 48/255)
}

struct CountdownRing: View {
    let settings: LifeSettings
    let now: Date
    var compact = false
    var body: some View {
        ZStack {
            Circle().stroke(compact ? Color.white.opacity(0.16) : MomentStyle.line, lineWidth: compact ? 4 : 5)
            Circle().trim(from: 0, to: settings.fraction(at: now))
                .stroke(compact ? MomentStyle.accent : MomentStyle.green, style: StrokeStyle(lineWidth: compact ? 4 : 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: compact ? 5 : 9) {
                if !compact { Text("YOURS TO LIVE").font(.caption2.weight(.semibold)).tracking(2).foregroundStyle(MomentStyle.muted) }
                Text(settings.total(settings.unit, at: now), format: .number)
                    .font(.system(size: compact ? 38 : 60, weight: .regular, design: .rounded))
                    .monospacedDigit().minimumScaleFactor(0.4).lineLimit(1)
                    .foregroundStyle(compact ? Color.white : MomentStyle.ink)
                Text("\(settings.unit.rawValue) ahead").font(compact ? .caption : .body)
                    .foregroundStyle(compact ? Color.gray : MomentStyle.muted)
                if !compact {
                    Rectangle().fill(MomentStyle.line).frame(width: 30, height: 1).padding(.vertical, 9)
                    Text("\(settings.fraction(at: now) * 100, specifier: "%.1f")% of your timeline")
                        .font(.caption).foregroundStyle(MomentStyle.muted)
                }
            }.padding(compact ? 13 : 29)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(settings.total(settings.unit, at: now)) \(settings.unit.rawValue) remaining to age \(settings.targetAge)")
    }
}
