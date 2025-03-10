
import Foundation
import SwiftUI

struct StatBoxView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}
