
import Foundation
import SwiftUI
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let progressColor: Color
    let backgroundColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(backgroundColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: -90)) 
        }
    }
}
