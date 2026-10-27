import Cocoa
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleOverlay = Self("toggleOverlay")
    static let toggleAlwaysOnMode = Self("toggleAlwaysOnMode")
}

extension UserDefaults {
    static let clearDrawingsOnStartKey = "ClearDrawingsOnStart"
    static let hideDockIconKey = "HideDockIcon"
    static let fadeModeKey = "FadeMode"
    static let enableBoardKey = "EnableBoard"
    static let boardOpacityKey = "BoardOpacity"
    static let alwaysOnModeKey = "AlwaysOnMode"
    static let lineWidthKey = "LineWidth"
    static let hideToolFeedbackKey = "HideToolFeedback"
    static let clickRippleEnabledKey = "ClickRippleEnabled"
    static let clickRippleColorKey = "ClickRippleColor"
    static let clickRippleSizeKey = "ClickRippleSize"
    static let cursorHighlightEnabledKey = "CursorHighlightEnabled"
    static let spotlightSizeKey = "SpotlightSize"
    static let activeCursorStyleKey = "ActiveCursorStyle"
    static let activeCursorSizeKey = "ActiveCursorSize"
}

enum LineWidth {
    static let minimum: CGFloat = 0.5
    static let maximum: CGFloat = 100
    static let increment: CGFloat = 0.25

    static func normalized(_ value: CGFloat) -> CGFloat {
        let snapped = round(value / increment) * increment
        return min(maximum, max(minimum, snapped))
    }
}

let colorPalette: [NSColor] = [
    .systemRed, .systemOrange, .systemYellow,
    .systemGreen, .cyan, .systemIndigo,
    .magenta, .white, .black,
]
