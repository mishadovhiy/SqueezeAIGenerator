//
//  BackgroundView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import SwiftUI

struct HomeBackgroundView: View {
    var duration: TimeInterval = 5
    var body: some View {
        LinearGradient(colors: [
            .blue, .black, .purple
        ], startPoint: .topLeading, endPoint: .bottomTrailing)
        .overlay(content: {
            Color.white.opacity(0.4)
        })
        .blur(radius: 10)
        .ignoresSafeArea(.all)
            .overlay {
                circles
            }
            
    }
    
    let gradient: AngularGradient = .init(gradient: .init(colors: [.pink, .purple, .red, .yellow, .orange, .blue]), center: .center)
    @State var animate: Bool = false
    var circleScale: CGFloat {
        animate ? 1.5 : 0.75
    }
    var opacity: CGFloat {
        animate ? 0 : 1
    }
    var angle: Angle {
        .degrees(animate ? 0 : 360)
    }
    @State var circleCount: Int = 4
    var circles: some View {
        ZStack {
            ForEach(0..<circleCount, id: \.self) { i in
                Circle()
                    .stroke(gradient, lineWidth: 4)
                    .scaleEffect(circleScale)
                    .opacity(opacity)
                    .rotation3DEffect(angle, axis: self.axis(i))
                    .shadow(color: .blue.opacity(0.8),
                            radius: 10)
                    .hueRotation(angle)
                    .animation(.easeInOut(duration: duration)
                        .repeatForever()
                        .delay(Double(i) * 0.4),
                               value: animate)
            }
        }
        .frame(width: 150)
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            animate.toggle()
        }
    }
    
    func axis(_ i: Int) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch i {
        case 0: (x: 1, y: 0, z: 0)
        case 1: (x: 0, y: 1, z: 1)
        case 2: (x: 1, y: 0, z: 1)
        default: (x: 1, y: 0, z: 0)
        }
    }

}

#Preview {
    HomeBackgroundView()
}
