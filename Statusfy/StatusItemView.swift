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
                .paragraphStyle: self.paragraph
            ]
        } else {
            return [
                .font: NSFont.systemFont(ofSize: 10),
                .paragraphStyle: self.paragraph
            ]
        }
    }()
    
    var line1: String = "" {
        willSet(newValue) {
            if line1 != newValue {
                self.line1attr = NSAttributedString(string: newValue, attributes: attrs)
            }
        }
    }
    
    var line2: String = "" {
        willSet(newValue) {
            if line2 != newValue {
                self.line2attr = NSAttributedString(string: newValue, attributes: attrs)
            }
        }
    }
    
    var line1attr = NSAttributedString(string: "")
    
    var line2attr = NSAttributedString(string: "")
    
    var image: NSImage?
    
    var state: PlayerState = .Hidden {
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
    
    func update(line1: String, line2: String, state: PlayerState) {
        if self.line1 != line1 || self.line2 != line2 || self.state != state {
            self.line1 = line1
            self.line2 = line2
            self.state = state
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        let r1 = line1attr.boundingRect(with: NSSize(width: 1000, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)
        let r2 = line2attr.boundingRect(with: NSSize(width: 1000, height: 100), options: NSString.DrawingOptions.usesLineFragmentOrigin)
        
        let w = max(r1.width, r2.width)
        
        statusItem.length = w + (image?.size.width ?? 0.0)
        setNeedsDisplay(bounds)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        // print("draw \(line1) \(line2) \(state.rawValue)")
        
        image?.draw(in: NSRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
        
        let imgWidth = image?.size.width ?? 0.0
        
        let line1 = CGRect(x: imgWidth,
                           y: dirtyRect.height / 2,
                           width: dirtyRect.width - imgWidth,
                           height: dirtyRect.height / 2 + 1)
        let line2 = CGRect(x: imgWidth,
                           y: 0,
                           width: line1.width,
                           height: dirtyRect.height / 2 + 1)
        
        line1attr.draw(in: line1)
        line2attr.draw(in: line2)
    }
    
    public override func mouseDown(with event: NSEvent) {
        statusItem.popUpMenu(statusItem.menu!)
    }
}
