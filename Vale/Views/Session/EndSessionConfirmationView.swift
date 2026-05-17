import SwiftUI

struct EndSessionConfirmationView: View {
    let onContinue: () -> Void
    let onEnd: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: 14) {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("End this session?")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("You can stop, but the discomfort may be the practice.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.64))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 10) {
                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                            .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.black.opacity(0.88))

                    Button(role: .destructive, action: onEnd) {
                        Text("End Session")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 50)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white.opacity(0.68))
                }
            }
            .padding(24)
            .frame(maxWidth: 330)
            .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .glassEffect(.regular.tint(.white.opacity(0.045)), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .colorScheme(.dark)
        .padding(24)
        .onTapGesture {}
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EndSessionConfirmationView(onContinue: {}, onEnd: {})
    }
}
