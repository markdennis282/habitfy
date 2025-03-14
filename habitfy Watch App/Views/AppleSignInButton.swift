
import Foundation
import SwiftUI

struct AppleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "applelogo")
                    .font(.headline)
                Text("Sign in")
                    .fontWeight(.semibold)
                    .font(.headline)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.white)
            .cornerRadius(8)
        }.buttonStyle(.plain)

    }
}
