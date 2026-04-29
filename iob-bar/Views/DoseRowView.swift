import SwiftUI

struct DoseRowView: View {
    let dose: Dose
    let model: InsulinModel
    let now: Date
    let onDelete: () -> Void

    @State private var isHovering = false

    private var elapsed: TimeInterval { now.timeIntervalSince(dose.timestamp) }
    private var contributing: Double { dose.amount * model.fractionRemaining(at: elapsed) }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(dose.amount.formatted())u")
                .font(.system(size: 12, weight: .medium))
                .monospacedDigit()
                .frame(width: 38, alignment: .leading)
            Text(elapsedText)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Spacer()
            Text("→ \(contributing, specifier: "%.2f")u")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .monospacedDigit()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .help("Remove this dose from the IOB calculation")
            .opacity(isHovering ? 1 : 0)
            .frame(width: 14)
        }
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }

    private var elapsedText: String {
        let totalMinutes = Int(elapsed / 60)
        if totalMinutes < 60 {
            return "\(totalMinutes)m ago"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return String(format: "%dh%02dm ago", hours, minutes)
        }
    }
}
