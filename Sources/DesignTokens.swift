import SwiftUI

enum AppIdentity {
    static let displayName = "Sibelius重置"
}

enum AppColor {
    static let deepSpaceBlack = Color(nsColor: NSColor(hex: "#050A18") ?? .black)
    static let midnightNavy = Color(nsColor: NSColor(hex: "#08111F") ?? .black)
    static let panelBlueBlack = Color(nsColor: NSColor(hex: "#101A33") ?? .black)

    static let electricCyan = Color(nsColor: NSColor(hex: "#38E8FF") ?? .cyan)
    static let laserBlue = Color(nsColor: NSColor(hex: "#297BFF") ?? .blue)
    static let violetPurple = Color(nsColor: NSColor(hex: "#7B61FF") ?? .purple)
    static let neonMagenta = Color(nsColor: NSColor(hex: "#FF4DFF") ?? .magenta)
    static let softAqua = Color(nsColor: NSColor(hex: "#7DF9FF") ?? .cyan)

    static let primaryText = Color(nsColor: NSColor(hex: "#F4F7FF") ?? .white)
    static let secondaryText = Color(nsColor: NSColor(hex: "#A9B6D3") ?? .gray)
    static let mutedText = Color(nsColor: NSColor(hex: "#6F7EA3") ?? .gray)

    static let warningAmber = Color(nsColor: NSColor(hex: "#FFCC66") ?? .yellow)
    static let dangerPinkRed = Color(nsColor: NSColor(hex: "#FF5C8A") ?? .red)
}

enum AppMotion {
    static let entrance = Animation.spring(response: 0.72, dampingFraction: 0.86, blendDuration: 0.08)
    static let softSpring = Animation.spring(response: 0.46, dampingFraction: 0.82, blendDuration: 0.08)
    static let statusChange = Animation.easeInOut(duration: 0.34)
}

enum AppSize {
    static let windowWidth: CGFloat = 420
    static let windowHeight: CGFloat = 520

    static let windowRadius: CGFloat = 28
    static let infoPanelRadius: CGFloat = 18
    static let buttonRadius: CGFloat = 32

    static let countdownOuterSize: CGFloat = 248
    static let countdownRingSize: CGFloat = 210
    static let countdownInnerSize: CGFloat = 162

    static let primaryButtonWidth: CGFloat = 300
    static let primaryButtonHeight: CGFloat = 56

    static let infoPanelWidth: CGFloat = 340
    static let infoPanelHeight: CGFloat = 72
}

enum AppFont {
    static let title = Font.system(size: 22, weight: .bold, design: .default)
    static let status = Font.system(size: 14, weight: .medium, design: .default)

    static let circleLabel = Font.system(size: 16, weight: .semibold, design: .default)
    static let mainNumber = Font.system(size: 74, weight: .heavy, design: .rounded)
    static let dayUnit = Font.system(size: 28, weight: .semibold, design: .default)
    static let circleSubtext = Font.system(size: 15, weight: .medium, design: .default)

    static let button = Font.system(size: 21, weight: .bold, design: .default)
    static let info = Font.system(size: 13, weight: .medium, design: .default)
    static let footer = Font.system(size: 13, weight: .medium, design: .default)
}

extension NSColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        var hexColor = hex
        if hexColor.hasPrefix("#") {
            hexColor.remove(at: hexColor.startIndex)
        }
        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        }
        return nil
    }
}
