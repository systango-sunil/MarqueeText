import SwiftUI

public struct MarqueeText: View {
    public var text: String
    public var font: UIFont
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var startDelay: Double
    public var pointsPerSecond: Double
    
    @State private var animate = false
    
    public var body: some View {
        let stringWidth = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)
        
        GeometryReader { geo in
            let needsScrolling = stringWidth > geo.size.width
            let travelDistance = stringWidth + geo.size.width
            
            ZStack {
                if needsScrolling {
                    HStack(spacing: 40) { // small gap between repetitions
                        Text(text)
                            .font(.init(font))
                            .lineLimit(1)
                            .fixedSize()
                        
                        Text(text)
                            .font(.init(font))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .offset(x: animate ? -travelDistance : 0)
                    .animation(
                        animate ?
                            Animation.linear(duration: travelDistance / pointsPerSecond)
                                .delay(startDelay)
                                .repeatForever(autoreverses: false)
                            : .default,
                        value: animate
                    )
                    .mask(
                        fadeMask(leftFade: leftFade, rightFade: rightFade)
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
    
    // MARK: - Fade mask
    private func fadeMask(leftFade: CGFloat, rightFade: CGFloat) -> some View {
        HStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: leftFade)
            
            Color.black
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: rightFade)
        }
    }
    
    // MARK: - Initializer
    public init(
        text: String,
        font: UIFont,
        leftFade: CGFloat = 16,
        rightFade: CGFloat = 16,
        startDelay: Double = 1,
        pointsPerSecond: Double = 30
    ) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.pointsPerSecond = pointsPerSecond
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
