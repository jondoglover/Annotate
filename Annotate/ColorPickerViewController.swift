import Cocoa
import SwiftUI

class ColorSwatchButton: NSButton {
    var swatchColor: NSColor = .clear {
        didSet { needsDisplay = true }
    }

    var colorIndex: Int = 0

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        swatchColor.setFill()
        NSBezierPath(rect: bounds).fill()
    }
}

class ColorPickerViewController: NSViewController {
    private var keyMonitor: Any?
    private var buttons: [ColorSwatchButton] = []
    private var colorNameField: NSComboBox!

    override func loadView() {
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 190, height: 180))

        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 5

        let columnsPerRow = 3
        var buttonIndex = 0

        for chunk in colorPalette.chunked(into: columnsPerRow) {
            let rowStack = NSStackView()
            rowStack.orientation = .horizontal
            rowStack.alignment = .centerY
            rowStack.distribution = .fillEqually
            rowStack.spacing = 5

            for color in chunk {
                let button = ColorSwatchButton(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
                button.swatchColor = color
                button.target = self
                button.action = #selector(colorSwatchClicked(_:))

                buttonIndex += 1
                button.colorIndex = buttonIndex

                buttons.append(button)

                rowStack.addArrangedSubview(button)
            }
            stackView.addArrangedSubview(rowStack)
            rowStack.heightAnchor.constraint(equalToConstant: 42).isActive = true
            rowStack.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        }

        colorNameField = NSComboBox()
        colorNameField.placeholderString = "CSS color name"
        colorNameField.addItems(withObjectValues: CSSColorCatalog.names)
        colorNameField.completes = true
        colorNameField.numberOfVisibleItems = 8
        colorNameField.target = self
        colorNameField.action = #selector(cssColorSubmitted(_:))
        stackView.addArrangedSubview(colorNameField)
        colorNameField.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])

        self.view = containerView
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        setupKeyboardMonitoring()
        updateButtonLabels()
        view.window?.makeFirstResponder(colorNameField)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        removeKeyboardMonitoring()
    }

    private func setupKeyboardMonitoring() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let strongSelf = self, strongSelf.handleKeyEvent(event) {
                return nil
            }
            return event
        }
    }

    private func removeKeyboardMonitoring() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        guard let characters = event.characters, characters.count == 1 else {
            return false
        }

        if let digit = Int(characters), digit >= 1 && digit <= min(9, colorPalette.count) {
            if digit <= buttons.count {
                let button = buttons[digit - 1]
                colorSwatchClicked(button)
                return true
            }
        }

        return false
    }

    private func updateButtonLabels() {
        for button in buttons {
            button.subviews.forEach { if $0 is NSTextField { $0.removeFromSuperview() } }

            let label = NSTextField()
            label.stringValue = "\(button.colorIndex)"
            label.isBezeled = false
            label.drawsBackground = false
            label.isEditable = false
            label.isSelectable = false
            label.textColor = button.swatchColor.contrastingColor()

            label.font = NSFont.boldSystemFont(ofSize: 12)
            label.alignment = .center

            button.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            ])
        }
    }

    @objc func colorSwatchClicked(_ sender: ColorSwatchButton) {
        selectColor(sender.swatchColor)
    }

    @objc private func cssColorSubmitted(_ sender: NSComboBox) {
        guard selectCSSColor(named: sender.stringValue) else {
            NSSound.beep()
            return
        }
    }

    @discardableResult
    func selectCSSColor(named name: String) -> Bool {
        guard let color = CSSColorCatalog.color(named: name) else { return false }
        selectColor(color)
        return true
    }

    private func selectColor(_ color: NSColor) {
        guard let appDelegate = AppDelegate.shared else { return }
        appDelegate.applySelectedColor(color)

        if let popover = appDelegate.colorPopover {
            popover.performClose(nil)
        } else {
            view.window?.close()
        }
    }

}
