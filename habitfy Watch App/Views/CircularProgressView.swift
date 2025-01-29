//
//  CircularProgressView.swift
//  habitfy Watch App
//
//  Created by Mark Dennis on 22/01/2025.
//

import Foundation
import SwiftUI
struct CircularProgressView: View {
    let progress: Double         // Fraction (0.0 to 1.0)
    let lineWidth: CGFloat       // Thickness of the progress circle
    let progressColor: Color     // Color of the progress ring
    let backgroundColor: Color   // Color of the background ring
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(backgroundColor)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: -90)) // Start at the top
        }
    }
}
