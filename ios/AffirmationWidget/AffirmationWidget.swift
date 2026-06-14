import SwiftUI
import WidgetKit

private let appGroupId = "group.com.rashsvr.mobilewidget"
private let affirmationKey = "affirmation_text"
private let defaultAffirmation = "📟 Your next thought is loading…"

struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: String
}

struct AffirmationProvider: TimelineProvider {
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(date: Date(), affirmation: defaultAffirmation)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (AffirmationEntry) -> Void
    ) {
        completion(currentEntry())
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<AffirmationEntry>) -> Void
    ) {
        let entry = currentEntry()
        let nextRefresh = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: Date()
        ) ?? Date().addingTimeInterval(30 * 60)

        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func currentEntry() -> AffirmationEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let affirmation = defaults?.string(forKey: affirmationKey) ?? defaultAffirmation
        return AffirmationEntry(date: Date(), affirmation: affirmation)
    }
}

struct AffirmationWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: AffirmationEntry

    var body: some View {
        VStack(spacing: family == .systemSmall ? 8 : 12) {
            label
            message
        }
        .padding(12)
        .widgetURL(URL(string: "mobilewidget://affirmation"))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.73, green: 0.78, blue: 0.65))
        )
    }

    private var label: some View {
            Text(currentTime)
            .font(.system(size: family == .systemSmall ? 11 : 12, weight: .bold, design: .monospaced))
            .foregroundColor(Color(red: 0.33, green: 0.38, blue: 0.29))
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var message: some View {
        Text("\(cleanedAffirmation) ☀")
            .font(.system(size: messageSize, weight: .bold, design: .monospaced))
            .foregroundColor(Color(red: 0.09, green: 0.13, blue: 0.07))
            .multilineTextAlignment(.center)
            .lineLimit(messageLines)
            .minimumScaleFactor(0.55)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var cleanedAffirmation: String {
        let trimmed = entry.affirmation.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "✨ Add your first affirmation" : trimmed
    }

    private var messageSize: CGFloat {
        switch family {
        case .systemSmall:
            return 21
        case .systemMedium:
            return 25
        case .systemLarge:
            return 31
        default:
            return 23
        }
    }

    private var messageLines: Int {
        switch family {
        case .systemSmall:
            return 3
        case .systemMedium:
            return 3
        case .systemLarge:
            return 6
        default:
            return 3
        }
    }

    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.date)
    }
}

@main
struct AffirmationWidget: Widget {
    let kind = "AffirmationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AffirmationProvider()) { entry in
            AffirmationWidgetView(entry: entry)
        }
        .configurationDisplayName("LCD Affirmation")
        .description("A minimal old-phone affirmation message.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct AffirmationWidgetPreviews: PreviewProvider {
    static var previews: some View {
        AffirmationWidgetView(
            entry: AffirmationEntry(date: Date(), affirmation: "tiny steps count")
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
