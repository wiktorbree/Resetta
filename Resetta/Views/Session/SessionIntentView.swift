import SwiftUI

struct SessionIntentView: View {
    let duration: TimeInterval
    let onStart: (SessionIntent?) -> Void
    let onCancel: () -> Void

    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @State private var selectedIntent: SessionIntent?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            HStack {
                Spacer()

                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Close")
            }

            Spacer(minLength: 28)

            VStack(alignment: .leading, spacing: 10) {
                Text(TimeFormatting.duration(duration))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ResettaTheme.accent)

                Text("What are you doing this for?")
                    .font(.title.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(SessionIntent.allCases) { intent in
                    IntentOptionButton(
                        title: intent.rawValue,
                        isSelected: selectedIntent == intent
                    ) {
                        selectedIntent = selectedIntent == intent ? nil : intent
                        HapticsService.selection(enabled: hapticsEnabled)
                    }
                }
            }

            Spacer(minLength: 28)

            Button {
                onStart(selectedIntent)
            } label: {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(ResettaTheme.accent)
            .controlSize(.large)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .portraitOnlyOrientationScope()
    }
}

private struct IntentOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    isSelected ? AnyShapeStyle(ResettaTheme.accent) : AnyShapeStyle(ResettaTheme.quietFill),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? ResettaTheme.accent : ResettaTheme.subtleLine, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    SessionIntentView(duration: 15 * 60, onStart: { _ in }, onCancel: {})
}
