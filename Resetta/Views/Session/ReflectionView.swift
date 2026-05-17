import SwiftUI

struct ReflectionView: View {
    let session: DetoxSession
    let onSave: (SessionFeeling?, String) -> Void

    @AppStorage(UserSettings.StorageKey.hapticsEnabled) private var hapticsEnabled = UserSettings.defaults.hapticsEnabled
    @State private var note = ""
    @State private var selectedFeeling: SessionFeeling?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    init(session: DetoxSession, onSave: @escaping (SessionFeeling?, String) -> Void) {
        self.session = session
        self.onSave = onSave
        _note = State(initialValue: session.note ?? "")
        _selectedFeeling = State(initialValue: session.feeling)
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("How did it feel?")
                        .font(.largeTitle.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(SessionFeeling.allCases) { feeling in
                            FeelingOptionButton(
                                title: feeling.rawValue,
                                isSelected: selectedFeeling == feeling
                            ) {
                                selectedFeeling = selectedFeeling == feeling ? nil : feeling
                                HapticsService.selection(enabled: hapticsEnabled)
                            }
                        }
                    }

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $note)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .frame(minHeight: 150)
                            .accessibilityLabel("Reflection note")

                        if note.isEmpty {
                            Text("Add a note...")
                                .font(.body)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }
                    .background(ResettaTheme.quietFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    Spacer()

                    Button {
                        onSave(selectedFeeling, note)
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 56)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ResettaTheme.accent)
                }
                .padding(24)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
        .background(Color(.systemBackground))
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
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 58)
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
