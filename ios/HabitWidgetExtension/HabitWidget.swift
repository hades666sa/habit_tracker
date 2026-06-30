import WidgetKit
import SwiftUI

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habitName: String
    let streak: String
    let description: String
    let icon: String
    let color: Color
    let completedDays: [Bool]
    let dayLabels: [String]
}

struct HabitWidgetProvider: TimelineProvider {
    let appGroupId = "group.com.loop.habittracker.habit_tracker_flutter"
    
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(
            date: Date(),
            habitName: "Habit",
            streak: "🔥 0 Day Streak",
            description: "Daily",
            icon: "🎯",
            color: .blue,
            completedDays: Array(repeating: false, count: 7),
            dayLabels: ["M", "T", "W", "T", "F", "S", "S"]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadEntry() -> HabitWidgetEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        
        let habitName = defaults?.string(forKey: "habit_name") ?? "Habit"
        let streak = defaults?.string(forKey: "habit_streak") ?? "🔥 0 Day Streak"
        let description = defaults?.string(forKey: "habit_description") ?? "Daily"
        let icon = defaults?.string(forKey: "habit_icon") ?? "🎯"
        let colorHex = defaults?.string(forKey: "habit_color") ?? "#0000FF"
        
        var completedDays: [Bool] = []
        var dayLabels: [String] = []
        
        for i in 0..<7 {
            let completed = defaults?.bool(forKey: "habit_completed_\(i)") ?? false
            let dayLabel = defaults?.string(forKey: "habit_day_\(i)") ?? ""
            completedDays.append(completed)
            dayLabels.append(dayLabel)
        }
        
        let color = Color(hex: colorHex) ?? .blue
        
        return HabitWidgetEntry(
            date: Date(),
            habitName: habitName,
            streak: streak,
            description: description,
            icon: icon,
            color: color,
            completedDays: completedDays,
            dayLabels: dayLabels
        )
    }
}

struct HabitWidgetEntryView: View {
    var entry: HabitWidgetProvider.Entry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(entry.icon)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.habitName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Text(entry.streak)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            HStack(spacing: 4) {
                ForEach(0..<7) { index in
                    VStack(spacing: 2) {
                        Text(entry.dayLabels.indices.contains(index) ? entry.dayLabels[index] : "")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                        Circle()
                            .fill(entry.completedDays.indices.contains(index) && entry.completedDays[index] ? entry.color : Color.gray.opacity(0.2))
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct HabitWidgetSmall: Widget {
    let kind: String = "HabitWidgetSmall"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker - Small")
        .description("Track your habit streak and weekly progress")
        .supportedFamilies([.systemSmall])
    }
}

struct HabitWidgetMedium: Widget {
    let kind: String = "HabitWidgetMedium"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitWidgetProvider()) { entry in
            HabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker - Medium")
        .description("Track your habit streak and weekly progress")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct HabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitWidgetSmall()
        HabitWidgetMedium()
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}