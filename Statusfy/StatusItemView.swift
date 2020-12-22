//
//  StatusItemView.swift
//  Statusfy
//
//  Created by carlos.fonseca on 05/04/2020.
//  Copyright © 2020 Paul Young. All rights reserved.
//

import Cocoa

@objc public enum PlayerState: Int {
    case Playing, Paused, Other, Hidden
}

@objcMembers public class StatusItemView: NSView {
    var statusItem: NSStatusItem!

    lazy var paragraph: NSParagraphStyle = {
        var p = NSMutableParagraphStyle()
        p.alignment = .center
        return p
    }()

    lazy var attrs: [NSAttributedString.Key: Any] = {
        if #available(OSX 10.10, *) {
            return [
                .font: NSFont.systemFont(ofSize: 10),
                .foregroundColor: NSColor.labelColor,
                .paragraphStyle: self.paragraph,
            ]
        } else {
            return [
                .font: NSFont.systemFont(ofSize: 10),
                .paragraphStyle: self.paragraph
            ]
        }
    }()

    lazy var highlightedAttrs: [NSAttributedString.Key: Any] = {
        [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.white,
            .paragraphStyle: self.paragraph
        ]
    }()

    var line1: String = "" {
        willSet(newValue) {
            if line1 != newValue {
                line1attr = NSAttributedString(string: newValue, attributes: attrs)
            }
        }
    }

    var line2: String = "" {
        willSet(newValue) {
            if line2 != newValue {
                line2attr = NSAttributedString(string: newValue, attributes: attrs)
            }
        }
    }

    var line1attr = NSAttributedString(string: "")

    var line2attr = NSAttributedString(string: "")

    var image: NSImage?

    var state: PlayerState = .Other {
        willSet(newState) {
            if state != newState {
                switch newState {
                case .Playing:
                    image = NSImage(named: "Play")
                case .Paused:
                    image = NSImage(named: "Pause")
                default:
                    image = nil
                }
            }
        }
    }

    var isHighlighted: Bool = false {
        didSet {
            setNeedsDisplay(bounds)
        }
    }

    func update(line1: String, line2: String, state: PlayerState) {
        var changed = false
        if !line1.isEmpty, self.line1 != line1 {
            self.line1 = line1
            changed = true
        }
        if !line2.isEmpty, self.line2 != line2 {
            self.line2 = line2
            changed = true
        }
        if self.state != state {
            self.state = state
            changed = true
        }
        if changed {
            update()
        }
    }

    class func new(statusItem: NSStatusItem) -> StatusItemView {
        return StatusItemView(statusItem: statusItem)
    }

    init(statusItem: NSStatusItem) {
        let rect = CGRect(x: 0, y: 0, width: statusItem.length, height: NSStatusBar.system.thickness)
        super.init(frame: rect)
        self.statusItem = statusItem
        statusItem.view = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        let r1 = line1attr.boundingRect(with: NSSize(width: 1000, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)
        let r2 = line2attr.boundingRect(with: NSSize(width: 1000, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)

        let w = max(ceil(r1.width), ceil(r2.width))

        statusItem.length = max(w + (image?.size.width ?? 0.0), 15)
        setNeedsDisplay(bounds)
    }

    public override func draw(_ dirtyRect: NSRect) {
        statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: isHighlighted)

        if image == nil, line1.isEmpty, line2.isEmpty {
            let placeholder = NSImage(named: "StatusIcon")!
            placeholder.isTemplate = true
            let imgSize: CGFloat = 15

            let vMargin = (dirtyRect.height - 15) / 2

            placeholder.draw(in: NSRect(x: 0, y: vMargin, width: imgSize, height: imgSize))
            return
        }

        if image != nil, isHighlighted, UserDefaults.standard.string(forKey: "AppleInterfaceStyle") != "Dark" {
            let image = NSImage(named: "\(self.image!.name()!)-Highlighted")!
            image.draw(in: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        } else {
            image?.draw(in: NSRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
        }

        let imgWidth = image?.size.width ?? 0.0

        let line1Rect = CGRect(x: imgWidth,
                               y: dirtyRect.height / 2,
                               width: dirtyRect.width - imgWidth,
                               height: dirtyRect.height / 2 + 1)

        let line2Rect = CGRect(x: imgWidth,
                               y: 0,
                               width: line1Rect.width,
                               height: dirtyRect.height / 2 + 1)

        if isHighlighted {
            NSAttributedString(string: line1, attributes: highlightedAttrs).draw(in: line1Rect)
            NSAttributedString(string: line2, attributes: highlightedAttrs).draw(in: line2Rect)
        } else {
            line1attr.draw(with: line1Rect, options: NSString.DrawingOptions.usesLineFragmentOrigin)
            line2attr.draw(with: line2Rect, options: NSString.DrawingOptions.usesLineFragmentOrigin)
        }
    }

    public override func mouseDown(with event: NSEvent) {
        isHighlighted = true
        statusItem.popUpMenu(statusItem.menu!)
        isHighlighted = false
    }
}
