import SwiftUI

struct EndSessionConfirmationView: View {
    let onContinue: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("End this session?")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

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
                .foregroundStyle(.white.opacity(0.72))
            }
        }
        .padding(20)
        .frame(maxWidth: 320)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
