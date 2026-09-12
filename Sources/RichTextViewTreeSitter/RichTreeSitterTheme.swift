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
        .github
    }

    public static var github: Self {
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

    public static var xcode: Self {
        builtIn(
            background: dynamic(light: 0xFFFFFF, dark: 0x1F1F24),
            text: dynamic(light: 0x000000, dark: 0xFFFFFF),
            keyword: dynamic(light: 0x9B2393, dark: 0xFC5FA3),
            type: dynamic(light: 0x0B4F79, dark: 0x5DD8FF),
            string: dynamic(light: 0xC41A16, dark: 0xFC6A5D),
            comment: dynamic(light: 0x267507, dark: 0x6C7986),
            number: dynamic(light: 0x1C00CF, dark: 0xD0BF69),
            function: dynamic(light: 0x326D74, dark: 0x67B7A4),
            property: dynamic(light: 0x326D74, dark: 0x67B7A4),
            accent: dynamic(light: 0x703DAA, dark: 0xA167E6)
        )
    }

    public static var monokai: Self {
        builtIn(
            background: color(0x272822),
            text: color(0xF8F8F2),
            keyword: color(0xF92672),
            type: color(0x66D9EF),
            string: color(0xE6DB74),
            comment: color(0x75715E),
            number: color(0xAE81FF),
            function: color(0xA6E22E),
            property: color(0x66D9EF),
            accent: color(0xFD971F)
        )
    }

    public static var dracula: Self {
        builtIn(
            background: color(0x282A36),
            text: color(0xF8F8F2),
            keyword: color(0xFF79C6),
            type: color(0x8BE9FD),
            string: color(0xF1FA8C),
            comment: color(0x6272A4),
            number: color(0xBD93F9),
            function: color(0x50FA7B),
            property: color(0x8BE9FD),
            accent: color(0xFFB86C)
        )
    }

    public static func preset(_ preset: RichTreeSitterThemePreset) -> Self {
        switch preset {
        case .github: .github
        case .xcode: .xcode
        case .monokai: .monokai
        case .dracula: .dracula
        }
    }

    private static func builtIn(
        background: UIColor,
        text: UIColor,
        keyword: UIColor,
        type: UIColor,
        string: UIColor,
        comment: UIColor,
        number: UIColor,
        function: UIColor,
        property: UIColor,
        accent: UIColor
    ) -> Self {
        let regular = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let bold = UIFont.monospacedSystemFont(ofSize: 14, weight: .semibold)
        return Self(
            font: regular,
            lineHeight: 22,
            textColor: text,
            backgroundColor: background,
            tokenStyles: [
                "attribute": RichTreeSitterTokenStyle(foregroundColor: accent),
                "boolean": RichTreeSitterTokenStyle(foregroundColor: number),
                "comment": RichTreeSitterTokenStyle(foregroundColor: comment),
                "constant": RichTreeSitterTokenStyle(foregroundColor: number),
                "constructor": RichTreeSitterTokenStyle(foregroundColor: type),
                "embedded": RichTreeSitterTokenStyle(foregroundColor: text),
                "function": RichTreeSitterTokenStyle(foregroundColor: function),
                "function.builtin": RichTreeSitterTokenStyle(foregroundColor: function),
                "function.call": RichTreeSitterTokenStyle(foregroundColor: function),
                "keyword": RichTreeSitterTokenStyle(foregroundColor: keyword, font: bold),
                "label": RichTreeSitterTokenStyle(foregroundColor: accent),
                "number": RichTreeSitterTokenStyle(foregroundColor: number),
                "operator": RichTreeSitterTokenStyle(foregroundColor: keyword),
                "property": RichTreeSitterTokenStyle(foregroundColor: property),
                "punctuation": RichTreeSitterTokenStyle(foregroundColor: text),
                "string": RichTreeSitterTokenStyle(foregroundColor: string),
                "string.escape": RichTreeSitterTokenStyle(foregroundColor: accent),
                "string.special": RichTreeSitterTokenStyle(foregroundColor: string),
                "tag": RichTreeSitterTokenStyle(foregroundColor: keyword),
                "type": RichTreeSitterTokenStyle(foregroundColor: type),
                "variable.builtin": RichTreeSitterTokenStyle(foregroundColor: accent),
                "variable.parameter": RichTreeSitterTokenStyle(foregroundColor: text)
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

public enum RichTreeSitterThemePreset: String, CaseIterable, Sendable {
    case github
    case xcode
    case monokai
    case dracula
}
