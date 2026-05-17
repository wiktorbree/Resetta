import SwiftUI

struct SessionIntentView: View {
    let duration: TimeInterval
    let onStart: (SessionIntent?) -> Void
    let onCancel: () -> Void

    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @State private var selectedIntent: SessionIntent?

    private let columns = [GridItem(.adaptive(minimum: 148), spacing: 12)]

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 34) {
                    HStack {
                        Spacer()

                        Button(action: onCancel) {
                            Image(systemName: "xmark")
                                .accessibilityHidden(true)
                        }
                        .buttonStyle(ValeIconButtonStyle())
                        .accessibilityLabel("Close")
                    }

                    Spacer(minLength: 32)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(TimeFormatting.duration(duration))
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(ValeTheme.accentText)

                        Text("What are you doing this for?")
                            .font(.largeTitle.weight(.semibold))
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(SessionIntent.allCases) { intent in
                            IntentOptionButton(
                                title: intent.rawValue,
                                isSelected: selectedIntent == intent
                            ) {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    selectedIntent = selectedIntent == intent ? nil : intent
                                }
                                HapticsService.selection(enabled: hapticsEnabled)
                            }
                        }
                    }

                    Spacer(minLength: 28)

                    Button {
                        onStart(selectedIntent)
                    } label: {
                        Text("Start")
                    }
                    .buttonStyle(ValePrimaryButtonStyle())
                }
                .padding(.horizontal, ValeTheme.horizontalPadding(for: proxy.size.width))
                .padding(.top, max(18, proxy.safeAreaInsets.top + 8))
                .padding(.bottom, max(32, proxy.safeAreaInsets.bottom + 24))
                .frame(maxWidth: ValeTheme.contentWidth(for: proxy.size.width), minHeight: proxy.size.height, alignment: .top)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(ValeTheme.screenBackground.ignoresSafeArea())
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
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)
        }
        .buttonStyle(ValeOptionButtonStyle(isSelected: isSelected))
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    SessionIntentView(duration: 15 * 60, onStart: { _ in }, onCancel: {})
}
