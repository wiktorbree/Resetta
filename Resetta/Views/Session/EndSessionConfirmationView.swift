import SwiftUI

struct EndSessionConfirmationView: View {
    let onContinue: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("End this session?")
                    .font(.title3.weight(.semibold))

                Text("You can stop, but the discomfort may be the practice.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)

                Button(role: .destructive, action: onEnd) {
                    Text("End Session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(22)
        .frame(maxWidth: 340)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
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
