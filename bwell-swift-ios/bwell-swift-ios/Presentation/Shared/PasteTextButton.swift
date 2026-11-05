//
//  PasteTextButton.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 04-11-2026.
//

import SwiftUI
import UIKit

/// Style the system paste control as a plain text button.
struct PasteTextButton: UIViewRepresentable {
    var onPaste: (String) -> Void

    func makeUIView(context: Context) -> PasteContainer {
        PasteContainer(onPaste: onPaste)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.onPaste = onPaste
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: PasteContainer, context: Context) -> CGSize? {
        let fitted = uiView.control.sizeThatFits(CGSize(width: 200, height: 44))
        return CGSize(width: max(fitted.width, 72), height: max(fitted.height, 36))   // never smaller than a readable pill
    }
}

/**
 * UIPasteControl needs a 'target' object thaat recieves the pasted text.
 * This view hosts the control and acts as that target.
 */
final class PasteContainer: UIView {
    var onPaste: (String) -> Void
    let control: UIPasteControl

    init(onPaste: @escaping (String) -> Void) {
        self.onPaste = onPaste

        let configuration = UIPasteControl.Configuration()
        configuration.displayMode = .labelOnly
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = UIColor(red: 0xE8 / 255, green: 0xEE / 255, blue: 0xFF / 255, alpha: 1)  // Sky
        configuration.baseForegroundColor = UIColor(red: 0x2F / 255, green: 0x5B / 255, blue: 0xEA / 255, alpha: 1)  // Action

        control = UIPasteControl(configuration: configuration)

        super.init(frame: .zero)

        pasteConfiguration = UIPasteConfiguration(forAccepting: NSString.self)

        control.target = self
        control.translatesAutoresizingMaskIntoConstraints = false

        addSubview(control)

        NSLayoutConstraint.activate([
            control.leadingAnchor.constraint(equalTo: leadingAnchor),
            control.trailingAnchor.constraint(equalTo: trailingAnchor),
            control.topAnchor.constraint(equalTo: topAnchor),
            control.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    /// The function that gets called when the user taps the control.
    override func paste(itemProviders: [NSItemProvider]) {
        guard let provider = itemProviders.first(where: {
            $0.canLoadObject(ofClass: NSString.self)
        }) else { return }

        _ = provider.loadObject(ofClass: NSString.self) { [weak self] object, _ in
            guard let text = object as? String else {
                return
            }

            DispatchQueue.main.async {
                self?.onPaste(text)
            }
        }
    }
}
