import SwiftUI

struct DurationPresetView: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(minutes)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .background(backgroundStyle, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(isSelected ? ResettaTheme.accent.opacity(0.45) : ResettaTheme.subtleLine, lineWidth: 1)
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
        .accessibilityLabel("\(minutes) minutes")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var backgroundStyle: some ShapeStyle {
        isSelected ? AnyShapeStyle(ResettaTheme.accent) : AnyShapeStyle(ResettaTheme.quietFill)
    }
}

#Preview {
    HStack {
        DurationPresetView(minutes: 5, isSelected: true) {}
        DurationPresetView(minutes: 15, isSelected: false) {}
    }
    .padding()
}
