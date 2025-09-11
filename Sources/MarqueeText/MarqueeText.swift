import SwiftUI

public struct MarqueeText: View {
    public var text: String
    public var font: UIFont
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var pointsPerSecond: Double = 30
    public var startDelay: Double
    
    @State private var startTime: Date = Date()
    @State private var now: Date = Date()
    private let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
    
    public var body: some View {
        let stringWidth = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)
        
        GeometryReader { geo in
            let needsScrolling = stringWidth > geo.size.width
            let travelDistance = stringWidth
            let duration = travelDistance / pointsPerSecond
            
            ZStack {
                if needsScrolling {
                    HStack(spacing: 20) {
                        Text(text)
                            .font(.init(font))
                            .lineLimit(1)
                            .fixedSize()
                        
                        Text(text)
                            .font(.init(font))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .offset(x: -offset(for: now, travelDistance: travelDistance, duration: duration))
                    .frame(width: geo.size.width, alignment: .leading)
                    .mask(
                        fadeMask(leftFade: leftFade, rightFade: rightFade)
                            .frame(width: geo.size.width)
                    )
                    .onReceive(timer) { newTime in
                        now = newTime
                    }
                } else {
                    Text(text)
                        .font(.init(font))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .onAppear {
                startTime = Date().addingTimeInterval(startDelay)
                now = Date()
            }
        }
        .frame(height: stringHeight)
    }
    
    private func offset(for time: Date, travelDistance: CGFloat, duration: Double) -> CGFloat {
        let elapsed = max(0, time.timeIntervalSince(startTime))
        guard duration > 0 else { return 0 }
        let progress = elapsed.truncatingRemainder(dividingBy: duration)
        return CGFloat(progress / duration) * travelDistance
    }
    
    private func fadeMask(leftFade: CGFloat, rightFade: CGFloat) -> some View {
        HStack(spacing: 0) {
            if leftFade > 0 {
                LinearGradient(
                    gradient: Gradient(colors: [.black.opacity(0), .black]),
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: leftFade)
            }
            
            Color.black
            
            if rightFade > 0 {
                LinearGradient(
                    gradient: Gradient(colors: [.black, .black.opacity(0)]),
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: rightFade)
            }
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
