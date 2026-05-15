import SwiftUI

struct SessionIntentView: View {
    let duration: TimeInterval
    let onStart: (SessionIntent?) -> Void
    let onCancel: () -> Void

    @AppStorage("hapticsEnabled") private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @State private var selectedIntent: SessionIntent?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
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

            Spacer(minLength: 24)

            VStack(alignment: .leading, spacing: 12) {
                Text(TimeFormatting.duration(duration))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(ResettaTheme.accent)

                Text("What are you doing this for?")
                    .font(.largeTitle.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(columns: columns, spacing: 12) {
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

            Spacer(minLength: 24)

            Button {
                onStart(selectedIntent)
            } label: {
                Text("Start")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.borderedProminent)
            .tint(ResettaTheme.accent)
            .controlSize(.large)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .onAppear {
            OrientationService.shared.lockPortrait()
        }
    }
}

private struct IntentOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    isSelected ? AnyShapeStyle(ResettaTheme.accent) : AnyShapeStyle(ResettaTheme.quietFill),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
