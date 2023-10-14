//
//  Tips.swift
//  Abyssal
//
//  Created by KrLite on 2023/10/13.
//

import Foundation
import AppKit

class Tip {
    
    private enum PopoverAttribute {
        
        case onlyData
        
        case onlyTip
        
        case both
        
        static func getAttribute(
            data: Bool,
            tip: Bool
        ) -> PopoverAttribute? {
            if data && tip {
                return .both
            }
            
            if data {
                return .onlyData
            }
            
            if tip {
                return .onlyTip
            }
            
            return nil
        }
        
    }
    
    var popover: NSPopover?
    
    var dataString: () -> String?
    
    var tipString: () -> String?
    
    var rect: () -> NSRect = { NSRect.zero }
    
    var isShown: Bool {
        popover?.isShown ?? false
    }
    
    var has: (data: Bool, tip: Bool, tipRuntime: Bool) {
        (data: dataString() != nil, tip: tipString() != nil, tipRuntime: Data.tips && tipString() != nil)
    }
    
    private var lastPopoverAttribute: PopoverAttribute?
    
    private var willShow: DispatchWorkItem?
    
    private var views = (data: NSTextField(), tip: NSTextField())
    
    init?(
        dataString: (() -> String?)? = nil,
        tipString: (() -> String?)? = nil,
        rect: (() -> NSRect)? = nil
    ) {
        self.dataString = dataString ?? { nil }
        self.tipString = tipString ?? { nil }
        if (rect != nil) {
            self.rect = rect!
        }
        
        // Data
        
        views.data = Tips.createTextField()
        
        // Tip
        
        views.tip = Tips.createTextField()
        views.tip.alphaValue = 0.65
    }
    
    func update() -> Bool {
        guard has.data || has.tipRuntime else { return false }
        
        if isShown {
            NSAnimationContext.runAnimationGroup() { context in
                context.allowsImplicitAnimation = true
                
                popover?.positioningRect = rect()
            }
        }
        
        if has.data {
            views.data.attributedStringValue = Tips.formatData(dataString()!)
        }
        
        if has.tipRuntime {
            views.tip.attributedStringValue = Tips.formatTip(tipString()!)
        }
        
        popover?.contentViewController?.updateViewConstraints()
        
        if lastPopoverAttribute == PopoverAttribute.getAttribute(data: has.data, tip: has.tipRuntime) {
            print(1)
            return false
        }
        
        if has.data && has.tipRuntime {
            close()
            popover = switchToBoth()
        } else if has.data {
            close()
            popover = switchToOnlyData()
        } else if has.tipRuntime {
            close()
            popover = switchToOnlyTip()
        } else {
            return false
        }
        
        return true
    }
    
    private func switchToOnlyData() -> NSPopover {
        let popover = Tips.createPopover()
        let controller = Tips.createViewController()
        
        popover.contentViewController = controller
        controller.view.addSubview(views.data)
        
        Tips.addHorizontalMargins(
            parent: controller.view,
            child: views.data,
            relatedBy: .equal
        )
        Tips.addVerticalMargins(
            parent: controller.view,
            child: views.data,
            relatedBy: .equal
        )
        
        return popover
    }
    
    private func switchToOnlyTip() -> NSPopover {
        let popover = Tips.createPopover()
        let controller = Tips.createViewController()
        
        popover.contentViewController = controller
        controller.view.addSubview(views.tip)
        
        Tips.addHorizontalMargins(
            parent: controller.view,
            child: views.tip,
            relatedBy: .equal
        )
        Tips.addVerticalMargins(
            parent: controller.view,
            child: views.tip,
            relatedBy: .equal
        )
        
        return popover
    }
    
    private func switchToBoth() -> NSPopover {
        let popover = Tips.createPopover()
        let controller = Tips.createViewController()
        
        popover.contentViewController = controller
        controller.view.addSubview(views.data)
        controller.view.addSubview(views.tip)
        
        Tips.addHorizontalMargins(
            parent: controller.view,
            child: views.data,
            relatedBy: .equal
        )
        Tips.addHorizontalMargins(
            parent: controller.view,
            child: views.tip,
            relatedBy: .equal
        )
        
        controller.view.addConstraint(NSLayoutConstraint(
            item: controller.view,
            attribute: .top,
            relatedBy: .equal,
            toItem: views.data,
            attribute: .top,
            multiplier: 1,
            constant: -Tips.MARGIN.height
        ))
        controller.view.addConstraint(NSLayoutConstraint(
            item: views.data,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: views.tip,
            attribute: .top,
            multiplier: 1,
            constant: -Tips.MARGIN.height
        ))
        controller.view.addConstraint(NSLayoutConstraint(
            item: controller.view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: views.tip,
            attribute: .bottom,
            multiplier: 1,
            constant: Tips.MARGIN.height
        ))
        
        controller.updateViewConstraints()
        
        return popover
    }
    
    func show(
        _ sender: NSView
    ) {
        lastPopoverAttribute = PopoverAttribute.getAttribute(data: has.data, tip: has.tipRuntime)
        guard isShown || (!isShown && update()) else { return }
        
        willShow = DispatchWorkItem {
            self.popover?.show(
                relativeTo:     self.rect(),
                of:             sender,
                preferredEdge:  NSRectEdge.maxY
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: willShow!)
    }
    
    func close() {
        willShow?.cancel()
        popover?.performClose(self)
    }
    
    func offset(
        _ dx: CGFloat,
        _ dy: CGFloat
    ) {
        rect = { self.rect().offsetBy(dx: dx, dy: dy) }
    }
    
}

class Tips {
    
    static let test = Tip(
        dataString: { "Lorem Ipsum" },
        tipString: { "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
    )
    
    static let testData = Tip(
        dataString: test?.dataString
    )
    
    static let testTip = Tip(
        tipString: test?.tipString
    )
    
    
    
    private var map: [NSTrackingArea: (tip: Tip, sender: NSView)] = [:]
    
    func mouseEntered(with event: NSEvent) {
        if let area = event.trackingArea {
            map
                .filter { $0.key == area }
                .forEach { $0.value.tip.show($0.value.sender) }
        }
    }
    
    func mouseExited(with event: NSEvent) {
        if let area = event.trackingArea {
            map
                .filter { $0.key == area }
                .forEach { $0.value.tip.close() }
        }
    }
    
    func bind(
        _ sender: NSView,
        trackingArea: NSTrackingArea,
        tip: Tip
    ) {
        map[trackingArea] = (tip, sender)
    }
    
    func unbind(
        trackingArea: NSTrackingArea
    ) -> (tip: Tip, sender: NSView)? {
        map.removeValue(forKey: trackingArea)
    }
    
}

extension Tips {
    
    public static let DATA_SIZE: CGFloat = 14.5
    
    public static let TIP_SIZE: CGFloat = 10
    
    public static let MARGIN: (width: CGFloat, height: CGFloat) = (width: 16, height: 12)
    
    public static let MAX_WIDTH: CGFloat = 300
    
}

extension Tips {
    
    static func formatData(
        _ text: String
    ) -> NSAttributedString {
        let result = try! NSAttributedString.init(
            markdown: text.data(using: .utf8)!,
            options: .init(allowsExtendedAttributes: true)
        ) as! NSMutableAttributedString
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        result.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: result.length)
        )
        
        result.addAttribute(
            .font,
            value: NSFont.boldSystemFont(ofSize: DATA_SIZE),
            range: NSRange(location: 0, length: result.length)
        )
        
        return result
    }
    
    static func formatTip(
        _ text: String
    ) -> NSAttributedString {
        let result = try! NSAttributedString.init(
            markdown: text.data(using: .utf8)!,
            options: .init(allowsExtendedAttributes: true)
        ) as! NSMutableAttributedString
        
        result.addAttribute(
            .font,
            value: NSFont.systemFont(ofSize: TIP_SIZE),
            range: NSRange(location: 0, length: result.length)
        )
        
        return result
    }
    
}

extension Tips {
    
    static func createPopover() -> NSPopover {
        let popover = NSPopover()
        
        popover.behavior = .applicationDefined
        popover.animates = true
        
        return popover
    }
    
    static func createViewController() -> NSViewController {
        let controller = NSViewController()
        controller.view = NSView()
        
        return controller
    }
    
    static func createTextField() -> NSTextField {
        let textField = NSTextField(frame: NSRect.zero)
        textField.cell?.truncatesLastVisibleLine = false
        
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBezeled = false
        textField.drawsBackground = false
    
        textField.lineBreakMode = .byWordWrapping
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        textField.widthAnchor.constraint(lessThanOrEqualToConstant: MAX_WIDTH).isActive = true
        
        return textField
    }
    
}

extension Tips {
    
    static func addHorizontalMargins(
        parent: NSView,
        child: NSView?,
        relatedBy: NSLayoutConstraint.Relation
    ) {
        parent.addConstraint(NSLayoutConstraint(
            item: parent,
            attribute: .leading,
            relatedBy: relatedBy,
            toItem: child,
            attribute: .leading,
            multiplier: 1,
            constant: -MARGIN.width
        ))
        parent.addConstraint(NSLayoutConstraint(
            item: parent,
            attribute: .trailing,
            relatedBy: relatedBy,
            toItem: child,
            attribute: .trailing,
            multiplier: 1,
            constant: MARGIN.width
        ))
    }
    
    static func addVerticalMargins(
        parent: NSView,
        child: NSView?,
        relatedBy: NSLayoutConstraint.Relation
    ) {
        parent.addConstraint(NSLayoutConstraint(
            item: parent,
            attribute: .top,
            relatedBy: relatedBy,
            toItem: child,
            attribute: .top,
            multiplier: 1,
            constant: -MARGIN.height
        ))
        parent.addConstraint(NSLayoutConstraint(
            item: parent,
            attribute: .bottom,
            relatedBy: relatedBy,
            toItem: child,
            attribute: .bottom,
            multiplier: 1,
            constant: MARGIN.height
        ))
    }
    
}
