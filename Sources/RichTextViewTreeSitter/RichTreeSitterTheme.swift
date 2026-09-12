import UIKit

public struct RichTreeSitterTokenStyle {
    public let foregroundColor: UIColor?
    public let backgroundColor: UIColor?
    public let font: UIFont?

    public init(
        foregroundColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        font: UIFont? = nil
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.font = font
    }
}

public struct RichTreeSitterTheme {
    public let font: UIFont
    public let lineHeight: CGFloat
    public let textColor: UIColor
    public let backgroundColor: UIColor
    public let codeBlockInsets: UIEdgeInsets
    public let codeBlockCornerRadius: CGFloat
    public let tokenStyles: [String: RichTreeSitterTokenStyle]

    public init(
        font: UIFont,
        lineHeight: CGFloat,
        textColor: UIColor,
        backgroundColor: UIColor,
        codeBlockInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16),
        codeBlockCornerRadius: CGFloat = 8,
        tokenStyles: [String: RichTreeSitterTokenStyle]
    ) {
        self.font = font
        self.lineHeight = lineHeight
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.codeBlockInsets = codeBlockInsets
        self.codeBlockCornerRadius = codeBlockCornerRadius
        self.tokenStyles = tokenStyles
    }

    public func style(for capture: String) -> RichTreeSitterTokenStyle? {
        var components = capture.split(separator: ".")
        while !components.isEmpty {
            if let style = tokenStyles[components.joined(separator: ".")] {
                return style
            }
            components.removeLast()
        }
        return nil
    }

    public static var `default`: Self {
        let regular = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let bold = UIFont.monospacedSystemFont(ofSize: 14, weight: .semibold)
        return Self(
            font: regular,
            lineHeight: 22,
            textColor: dynamic(light: 0x24292F, dark: 0xC9D1D9),
            backgroundColor: dynamic(light: 0xF6F8FA, dark: 0x161B22),
            tokenStyles: [
                "attribute": style(0x8250DF, 0xD2A8FF),
                "boolean": style(0x0550AE, 0x79C0FF),
                "comment": style(0x6E7781, 0x8B949E),
                "constant": style(0x0550AE, 0x79C0FF),
                "constructor": style(0x953800, 0xFFA657),
                "embedded": style(0x24292F, 0xC9D1D9),
                "function": style(0x8250DF, 0xD2A8FF),
                "function.builtin": style(0x8250DF, 0xD2A8FF),
                "function.call": style(0x8250DF, 0xD2A8FF),
                "keyword": style(0xCF222E, 0xFF7B72, font: bold),
                "label": style(0x953800, 0xFFA657),
                "number": style(0x0550AE, 0x79C0FF),
                "operator": style(0x24292F, 0xC9D1D9),
                "property": style(0x0550AE, 0x79C0FF),
                "punctuation": style(0x24292F, 0xC9D1D9),
                "string": style(0x0A3069, 0xA5D6FF),
                "string.escape": style(0x953800, 0xFFA657),
                "string.special": style(0x0A3069, 0xA5D6FF),
                "tag": style(0x116329, 0x7EE787),
                "type": style(0x953800, 0xFFA657),
                "variable.builtin": style(0x0550AE, 0x79C0FF),
                "variable.parameter": style(0x24292F, 0xC9D1D9)
            ]
        )
    }

    private static func style(_ light: UInt32, _ dark: UInt32, font: UIFont? = nil) -> RichTreeSitterTokenStyle {
        RichTreeSitterTokenStyle(foregroundColor: dynamic(light: light, dark: dark), font: font)
    }

    private static func dynamic(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            color(traits.userInterfaceStyle == .dark ? dark : light)
        }
    }

    private static func color(_ rgb: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((rgb >> 16) & 0xff) / 255,
            green: CGFloat((rgb >> 8) & 0xff) / 255,
            blue: CGFloat(rgb & 0xff) / 255,
            alpha: 1
        )
    }
}
