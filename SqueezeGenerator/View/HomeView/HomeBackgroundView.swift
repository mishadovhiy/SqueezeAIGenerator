//
//  BackgroundView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import SwiftUI

struct HomeBackgroundView: View {
    @Binding var type: `Type`
    @Binding var properties: BakcgroundProperties


    private var defaultBackgroundColors: NetworkResponse.CategoriesResponse.Categories.Color {
        .init(
            tint: nil,
            topLeft: .HexColor.darkPurpure.rawValue,
            top: .HexColor.darkPurpure.rawValue,
            left: .HexColor.red.rawValue,
            right: .HexColor.red.rawValue,
            bottom: .HexColor.red.rawValue,
            bottomRight: .HexColor.darkPurpure.rawValue
        )
    }
    
    var backgroundColors: NetworkResponse.CategoriesResponse.Categories.Color {
        properties.backgroundGradient ?? defaultBackgroundColors
    }
    enum `Type`:String {
        case big, loading, regular, topRegular, topBig
        static let `default`: Self = .regular
        
        var isTop: Bool {
            rawValue.lowercased().contains("top")
        }
        
        var isBig: Bool {
            rawValue.lowercased().contains("big")
        }
    }
    var duration: TimeInterval {
        if type == .loading {
            return 1
        }
        return 5
    }
    
    struct BakcgroundProperties {
        var blurAlpha: CGFloat? = nil
        var needOval: Bool = true

        var backgroundGradient: NetworkResponse.CategoriesResponse.Categories.Color? = nil
    }
    
    var blurAlpha: CGFloat {
        if let alpha = properties.blurAlpha {
            return alpha
        }
        let ignorBlur: [Type] = [.loading, .regular, .topBig, .topRegular]
        if ignorBlur.contains(type) {
            return 0
        }
        
        return type.isBig || type.isTop  ? 20 : 0
    }
    
    var body: some View {
        ZStack(content: {
            primaryGradient
                .blur(radius: 20)
            Color.black.opacity(0.4)
            curclesOverlayView
        })
        .blur(radius: blurAlpha)
        .ignoresSafeArea(.all)
            
    }
    
    var primaryGradient: some View {
        let def = defaultBackgroundColors
        return ZStack {

            ZStack {
                LinearGradient(colors: [
                    .init(uiColor: .init(hex: backgroundColors.top ?? def.top!)!),
                    .init(uiColor: .init(hex: backgroundColors.bottom)!)
                ], startPoint: .top, endPoint: .bottom)

                VStack {
                    HStack {
                        RadialGradient(colors: [
                            .init(uiColor: .init(hex: backgroundColors.topLeft ?? def.topLeft!)!),
                            .init(uiColor: .init(hex: backgroundColors.topLeft ?? def.topLeft!)!).opacity(0)
                        ], center: .center, startRadius: 1, endRadius: 200)
                        .blur(radius: 30)
                        .padding(.leading, -100)
                        .padding(.top, -120)
                        .opacity(0.9)
                        .frame(maxWidth: .infinity)
                        Spacer().frame(maxWidth: .infinity)
                    }
                    Spacer().frame(maxHeight: .infinity)
                    Spacer().frame(maxHeight: .infinity)
                }

                VStack {
                    Spacer()
                        .frame(maxHeight: .infinity)
                    LinearGradient(colors: [
                        .init(uiColor: .init(hex: backgroundColors.left ?? def.left!)!),
                        .init(uiColor: .init(hex: backgroundColors.left ?? def.left!)!).opacity(0),
                        .init(uiColor: .init(hex: backgroundColors.right ?? def.right!)!).opacity(0),
                        .init(uiColor: .init(hex: backgroundColors.right ?? def.right!)!)
                    ], startPoint: .leading, endPoint: .trailing)
                    .blur(radius: 40)
                    .padding(.leading, -50)
                    .padding(.leading, -20)
                    .rotationEffect(.degrees(10))
                    Spacer()
                        .frame(maxHeight: .infinity)
                }

                RadialGradient(colors: [
                    .init(uiColor: .init(hex: backgroundColors.top ?? def.top!)!),
                    .init(uiColor: .init(hex: backgroundColors.top ?? def.top!)!).opacity(0)
                ], center: .center, startRadius: 1, endRadius: 100)
                .blur(radius: 50)
                .offset(x: -10, y: -35)
                .opacity(0.9)

                RadialGradient(colors: [
                    .init(uiColor: .init(hexColor: .yellow)!),
                    .init(uiColor: .init(hexColor: .yellow)!).opacity(0)
                ], center: .center, startRadius: 1, endRadius: 100)
                .blur(radius: 50)
                .offset(x: -30, y: 55)
                .opacity(properties.needOval ? 0.9 : 0)
                .animation(.smooth, value: properties.needOval)

                VStack {
                    Spacer().frame(maxHeight: .infinity)
                    Spacer().frame(maxHeight: .infinity)
                    HStack {
                        Spacer().frame(maxWidth: .infinity)
                        RadialGradient(colors: [
                            .init(uiColor: .init(hex: backgroundColors.bottomRight ?? def.bottomRight!)!),
                            .init(uiColor: .init(hex: backgroundColors.bottomRight ?? def.bottomRight!)!).opacity(0)
                        ], center: .center, startRadius: 1, endRadius: 200)
                        .blur(radius: 30)
                        .padding(.trailing, -100)
                        .padding(.bottom, -100)
                        .opacity(0.9)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .animation(.smooth, value: backgroundColors.decode)
        }
        .opacity(type == .loading ? 0 : 1)
        .animation(.smooth, value: type)
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
        animate ? (type == .loading ? 0 : (type.isTop ? 0 : 0)) : 1
    }
    var angle: Angle {
        .degrees(animate ? 0 : 360)
    }
    @State var circleCount: Int = 4
    
    @ViewBuilder
    var curclesOverlayView: some View {
        VStack {
            Spacer()
                .frame(maxHeight: (type.isTop ? (type != .topRegular ? .zero : 150) : .infinity))
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
    
    var circles: some View {
        ZStack {
            ForEach(0..<circleCount, id: \.self) { i in
                Circle()
                    .stroke(gradient, lineWidth: 8)
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

#Preview {
    HomeBackgroundView(
        type: .constant(.regular),
        properties: .constant(.init(blurAlpha: 1))
    )
}
