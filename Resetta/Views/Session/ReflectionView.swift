import SwiftUI

struct ReflectionView: View {
    let session: DetoxSession
    let onSave: (SessionFeeling?, String) -> Void

    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @State private var note = ""
    @State private var selectedFeeling: SessionFeeling?

    private let columns = [GridItem(.adaptive(minimum: 148), spacing: 12)]

    init(session: DetoxSession, onSave: @escaping (SessionFeeling?, String) -> Void) {
        self.session = session
        self.onSave = onSave
        _note = State(initialValue: session.note ?? "")
        _selectedFeeling = State(initialValue: session.feeling)
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    Text("How did it feel?")
                        .font(.largeTitle.weight(.semibold))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(SessionFeeling.allCases) { feeling in
                            FeelingOptionButton(
                                title: feeling.rawValue,
                                isSelected: selectedFeeling == feeling
                            ) {
                                withAnimation(.easeInOut(duration: 0.18)) {
                                    selectedFeeling = selectedFeeling == feeling ? nil : feeling
                                }
                                HapticsService.selection(enabled: hapticsEnabled)
                            }
                        }
                    }

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $note)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .frame(minHeight: 172)
                            .accessibilityLabel("Reflection note")

                        if note.isEmpty {
                            Text("Add a note...")
                                .font(.body)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }
                    .background(ResettaTheme.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(ResettaTheme.subtleLine, lineWidth: 1)
                    }

                    Spacer()

                    Button {
                        onSave(selectedFeeling, note)
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(ResettaPrimaryButtonStyle())
                }
                .padding(.horizontal, ResettaTheme.horizontalPadding(for: proxy.size.width))
                .padding(.top, max(52, proxy.safeAreaInsets.top + 32))
                .padding(.bottom, max(34, proxy.safeAreaInsets.bottom + 24))
                .frame(maxWidth: ResettaTheme.contentWidth(for: proxy.size.width), minHeight: proxy.size.height, alignment: .top)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .background(ResettaTheme.screenBackground.ignoresSafeArea())
        .portraitOnlyOrientationScope()
    }
}

private struct FeelingOptionButton: View {
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
        .buttonStyle(ResettaOptionButtonStyle(isSelected: isSelected))
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ReflectionView(
        session: DetoxSession(
            startDate: Date(),
            endDate: Date().addingTimeInterval(5 * 60),
            plannedDuration: 5 * 60,
            actualDuration: 5 * 60,
            completed: true
        ),
        onSave: { _, _ in }
    )
}
