import SwiftUI

struct TopicSelectorView: View {
    @Binding var selectedTopic: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Spacer()

            Text("今日は何について\n話しますか？")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(Constants.textPrimary)
                .lineSpacing(8)

            VStack(spacing: 12) {
                ForEach(Constants.topicStarters, id: \.label) { item in
                    TopicButton(
                        icon: item.icon,
                        label: item.label,
                        isSelected: selectedTopic == item.prompt
                    ) {
                        selectedTopic = item.prompt
                    }
                }
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct TopicButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Constants.accent : Constants.textMuted)
                    .frame(width: 24)
                Text(label)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Constants.textPrimary : Constants.textMuted)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Constants.accent)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    LiquidGlassShape(cornerRadius: 14,
                                     tint: isSelected ? Constants.accent : .clear)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Constants.accent.opacity(0.45), lineWidth: 1.5)
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
