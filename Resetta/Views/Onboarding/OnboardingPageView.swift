import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.largeTitle.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            Text(bodyText)
                .font(.title3)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingPageView(
        title: "This app does almost nothing.",
        bodyText: "No feeds. No badges. No rewards. Just time away from stimulation."
    )
    .padding(28)
}
