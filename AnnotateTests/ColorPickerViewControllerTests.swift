import XCTest

@testable import Annotate

@MainActor
final class ColorPickerViewControllerTests: XCTestCase, Sendable {
    var colorPicker: ColorPickerViewController!
    var mockAppDelegate: MockAppDelegate!

    nonisolated override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            colorPicker = ColorPickerViewController()
            mockAppDelegate = MockAppDelegate()
            AppDelegate.shared = mockAppDelegate

            _ = colorPicker.view
        }
    }

    nonisolated override func tearDown() {
        MainActor.assumeIsolated {
            colorPicker = nil
            mockAppDelegate = nil
            AppDelegate.shared = nil
        }
        super.tearDown()
    }

    func testColorPaletteInitialization() {
        XCTAssertEqual(
            colorPalette,
            [.black, .systemRed, .systemIndigo, .white, .systemGreen,
             .systemOrange, .systemYellow, .cyan, .magenta]
        )
    }

    func testViewSetup() {
        // Verify container view setup
        XCTAssertEqual(colorPicker.view.frame.size, NSSize(width: 190, height: 180))

        // Find the main vertical stack view
        let mainStackView = colorPicker.view.subviews.first as? NSStackView
        XCTAssertNotNil(mainStackView)
        XCTAssertEqual(mainStackView?.orientation, .vertical)
        XCTAssertEqual(mainStackView?.alignment, .leading)
        XCTAssertEqual(mainStackView?.distribution, .fill)

        // Check row stack views
        let rowStackViews = mainStackView?.arrangedSubviews.compactMap { $0 as? NSStackView }
        XCTAssertEqual(rowStackViews?.count, 3)  // Should have 3 rows

        // Check color swatch buttons
        var totalButtons = 0
        rowStackViews?.forEach { stackView in
            let buttons = stackView.arrangedSubviews.compactMap { $0 as? ColorSwatchButton }
            totalButtons += buttons.count
        }
        XCTAssertEqual(totalButtons, colorPalette.count)
    }

    func testColorSelection() {
        // Find the main stack view
        guard let mainStackView = colorPicker.view.subviews.first as? NSStackView,
            let firstRowStack = mainStackView.arrangedSubviews.first as? NSStackView,
            let firstButton = firstRowStack.arrangedSubviews.first as? ColorSwatchButton
        else {
            XCTFail("Failed to find first color swatch button")
            return
        }

        // Verify button color
        XCTAssertEqual(firstButton.swatchColor, .black)

        // Simulate button click
        colorPicker.colorSwatchClicked(firstButton)

        // Verify color was updated in AppDelegate
        XCTAssertEqual(mockAppDelegate.currentColor, .black)
        XCTAssertTrue(mockAppDelegate.updateStatusBarIconCalled)
    }

    func testCSSColorCatalog() {
        XCTAssertEqual(CSSColorCatalog.names.count, 148)
        XCTAssertNotNil(CSSColorCatalog.color(named: "rebeccapurple"))
        XCTAssertNotNil(CSSColorCatalog.color(named: "Light Goldenrod Yellow"))
        XCTAssertNil(CSSColorCatalog.color(named: "not-a-color"))
    }

    func testCSSColorSelection() {
        XCTAssertTrue(colorPicker.selectCSSColor(named: "tomato"))

        let color = mockAppDelegate.currentColor.usingColorSpace(.sRGB)
        XCTAssertEqual(color?.redComponent ?? 0, 1, accuracy: 0.001)
        XCTAssertEqual(color?.greenComponent ?? 0, 99.0 / 255, accuracy: 0.001)
        XCTAssertEqual(color?.blueComponent ?? 0, 71.0 / 255, accuracy: 0.001)
    }
}

// Mock AppDelegate for testing
class MockAppDelegate: AppDelegate {
    var updateStatusBarIconCalled = false
    override var currentColor: NSColor {
        didSet {
            // Track color changes
        }
    }

    override func updateStatusBarIcon(with color: NSColor) {
        updateStatusBarIconCalled = true
        currentColor = color
    }
}
