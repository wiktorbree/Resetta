import SwiftUI

struct DurationPresetView: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(minutes)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(backgroundStyle, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(isSelected ? ResettaTheme.accent : ResettaTheme.subtleLine, lineWidth: 1)
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .accessibilityLabel("\(minutes) minutes")
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
