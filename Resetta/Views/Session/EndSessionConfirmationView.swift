import SwiftUI

struct EndSessionConfirmationView: View {
    let onContinue: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("End this session?")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.black)

                Button(role: .destructive, action: onEnd) {
                    Text("End Session")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.72))
            }
        }
        .padding(22)
        .frame(maxWidth: 316)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
