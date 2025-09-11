import SwiftUI

public struct MarqueeText: View {
    public var text: String
    public var font: UIFont
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var startDelay: Double
    public var alignment: Alignment
    public var pointsPerSecond: Double
    
    @State private var animate = false
    var isCompact = false
    
    public var body: some View {
        let stringWidth  = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)
        
        GeometryReader { geo in
            let needsScrolling = (stringWidth > geo.size.width)
            
            ZStack {
                if needsScrolling {
                    // total distance the text needs to travel
                    let travelDistance = stringWidth + geo.size.width + 40
                    
                    let animation = Animation
                        .linear(duration: travelDistance / pointsPerSecond)
                        .delay(startDelay)
                        .repeatForever(autoreverses: false)
                    
                    let nullAnimation = Animation.linear(duration: 0)
                    
                    makeMarqueeTexts(
                        travelDistance: travelDistance,
                        animation: animation,
                        nullAnimation: nullAnimation
                    )
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .offset(x: leftFade)
                    .mask(
                        fadeMask(
                            leftFade: leftFade,
                            rightFade: rightFade
                        )
                    )
                    .frame(width: geo.size.width + leftFade)
                    .offset(x: -leftFade)
                } else {
                    // Non-scrolling case
                    Text(text)
                        .font(.init(font))
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: alignment
                        )
                }
            }
            .onAppear {
                self.animate = needsScrolling
            }
            .onValueChanged(of: text, initial: true) { _, newValue in
                let newStringWidth = newValue.widthOfString(usingFont: font)
                self.animate = newStringWidth > geo.size.width
            }
        }
        .frame(height: stringHeight)
        .frame(maxWidth: isCompact ? stringWidth : nil)
        .onDisappear {
            self.animate = false
        }
    }
    
    // MARK: - Marquee pair of texts
    @ViewBuilder
    private func makeMarqueeTexts(
        travelDistance: CGFloat,
        animation: Animation,
        nullAnimation: Animation
    ) -> some View {
        Group {
            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .offset(x: animate ? -travelDistance : 0)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)
            
            Text(text)
                .lineLimit(1)
                .font(.init(font))
                .offset(x: animate ? 0 : travelDistance)
                .animation(animate ? animation : nullAnimation, value: animate)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
    
    // MARK: - Fade mask
    @ViewBuilder
    private func fadeMask(leftFade: CGFloat, rightFade: CGFloat) -> some View {
        HStack(spacing: 0) {
            Rectangle().frame(width: 2).opacity(0)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: leftFade)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: rightFade)
            
            Rectangle().frame(width: 2).opacity(0)
        }
    }
    
    // MARK: - Initializer
    public init(
        text: String,
        font: UIFont,
        leftFade: CGFloat = 16,
        rightFade: CGFloat = 16,
        startDelay: Double = 1,
        alignment: Alignment? = nil,
        pointsPerSecond: Double = 30
    ) {
        self.text      = text
        self.font      = font
        self.leftFade  = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.alignment = alignment ?? .topLeading
        self.pointsPerSecond = pointsPerSecond
    }
}

extension MarqueeText {
    public func makeCompact(_ compact: Bool = true) -> Self {
        var view = self
        view.isCompact = compact
        return view
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}
