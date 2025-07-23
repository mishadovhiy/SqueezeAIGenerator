//
//  BackgroundView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import SwiftUI

struct HomeBackgroundView: View {
    @Binding var type: `Type`
    enum `Type`:String {
        case big, loading, regular, topRegular, topBig
        static let `default`: Self = .regular
        
        var isTop: Bool {
            rawValue.lowercased().contains("top")
        }
    }
    var duration: TimeInterval {
        if type == .loading {
            return 1
        }
        return 5
    }
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
                VStack {
                    Spacer()
                        .frame(maxHeight: (type.isTop ? (type == .topRegular ? .zero : .infinity) : .infinity))
                        .animation(.bouncy, value: type)
                    Spacer()
                        .frame(maxHeight: type.isTop ? 0 : .infinity)
                        .animation(.bouncy, value: type)
                    circles
                    Spacer()
                        .frame(maxHeight: .infinity)
                    Spacer()
                        .frame(maxHeight: .infinity)
                }
            }
            
    }
    
    let gradient: AngularGradient = .init(gradient: .init(colors: [.pink, .purple, .red, .yellow, .orange, .blue]), center: .center)
    @State var animate: Bool = false
    var circleScale: CGFloat {
        if type == .loading {
            return animate ? 0.6 : 0.25
        }
        return animate ? 1.5 : 0.75
    }
    var opacity: CGFloat {
        animate ? (type == .loading ? 0.4 : (type.isTop ? 0 : 0.1)) : 1
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
        .frame(width: type == .big ? 550 : 150)
        .animation(.bouncy, value: type)
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            animate.toggle()
        }
        .onChange(of: type) { newValue in
            if type != holder {
                holder = type
                animate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                    animate = true
                })
            }
            
        }
    }
    @State var holder: Type?
    func axis(_ i: Int) -> (x: CGFloat, y: CGFloat, z: CGFloat) {
        switch i {
        case 0: (x: 1, y: 0, z: 0)
        case 1: (x: 0, y: 1, z: 1)
        case 2: (x: 1, y: 0, z: 1)
        default: (x: 1, y: 0, z: 0)
        }
    }

}
