import SwiftUI

public struct MarqueeText: View {
    public var text: String
    public var font: UIFont
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var pointsPerSecond: Double
    public var startDelay: Double
    
    @State private var animate = false
    
    public var body: some View {
        let stringWidth = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)
        
        GeometryReader { geo in
            let needsScrolling = stringWidth > geo.size.width
            let travelDistance = stringWidth + geo.size.width
            
            ZStack {
                if needsScrolling {
                    HStack(spacing: 0) {
                        Text(text)
                            .font(.init(font))
                            .lineLimit(1)
                            .fixedSize()
                        
                        Text(text)
                            .font(.init(font))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .offset(x: animate ? -stringWidth - 40 : 0) // move by text width
                    .animation(
                        animate ?
                            Animation.linear(duration: (stringWidth + 40) / pointsPerSecond)
                                .delay(startDelay)
                                .repeatForever(autoreverses: false)
                            : .default,
                        value: animate
                    )
                    .frame(width: geo.size.width, alignment: .leading) // clip to row width
                    .mask(
                        fadeMask(leftFade: leftFade, rightFade: rightFade)
                            .frame(width: geo.size.width)
                    )
                } else {
                    Text(text)
                        .font(.init(font))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .onAppear { animate = needsScrolling }
            .onDisappear { animate = false }
        }
        .frame(height: stringHeight)
    }
    
    private func fadeMask(leftFade: CGFloat, rightFade: CGFloat) -> some View {
        HStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0), .black]),
                startPoint: .leading, endPoint: .trailing
            )
            .frame(width: leftFade)
            
            Color.black
            
            LinearGradient(
                gradient: Gradient(colors: [.black, .black.opacity(0)]),
                startPoint: .leading, endPoint: .trailing
            )
            .frame(width: rightFade)
        }
    }
    
    public init(
        text: String,
        font: UIFont,
        leftFade: CGFloat = 16,
        rightFade: CGFloat = 16,
        pointsPerSecond: Double = 30,
        startDelay: Double = 1
    ) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.pointsPerSecond = pointsPerSecond
        self.startDelay = startDelay
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes).width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes).height
    }
}
