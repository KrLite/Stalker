//
//  StatusBarController.swift
//  Abyssal
//
//  Created by KrLite on 2023/6/13.
//

import AppKit
import Defaults
import KeyboardShortcuts

class StatusBarController {
    // MARK: - States
    
    lazy var mouseOnStatusBar: WithIntermediateState<Bool> = .init {
        guard
            let headOrigin = self.head.button?.window?.frame.origin,
            let headSize = self.head.button?.window?.frame.size
        else { return false }
        let mouseLocation = NSEvent.mouseLocation
        return mouseLocation.x >= ScreenManager.menuBarLeftEdge && mouseLocation.y >= headOrigin.y && mouseLocation.y <= headOrigin.y + headSize.height
    }
    
    lazy var mouseInHideArea: Bool {
        guard
            let bodyOrigin = body.button?.window?.frame.origin,
            let tailOrigin = tail.button?.window?.frame.origin,
            let tailSize = tail.button?.window?.frame.size
        else { return false }
        return mouseOnStatusBar && NSEvent.mouseLocation.x >= tailOrigin.x + tailSize.width && NSEvent.mouseLocation.x <= bodyOrigin.x
    }
    
    var mouseInAlwaysHideArea: Bool {
        guard let origin = tail.button?.window?.frame.origin else { return false }
        return mouseOnStatusBar && NSEvent.mouseLocation.x <= origin.x
    }
    
    var mouseSpare: Bool {
        !ignoring && mouseOnStatusBar && NSEvent.mouseLocation.x <= edge
    }
    
    var mouseOverHead: Bool {
        guard
            let origin = head.button?.window?.frame.origin,
            let width = head.button?.window?.frame.width
        else { return false }
        return mouseOnStatusBar && NSEvent.mouseLocation.x >= origin.x && NSEvent.mouseLocation.x <= origin.x + width
    }
    
    var mouseOverBody: Bool {
        guard
            let origin = body.button?.window?.frame.origin,
            let width = body.button?.window?.frame.width
        else { return false }
        return mouseOnStatusBar && NSEvent.mouseLocation.x >= origin.x && NSEvent.mouseLocation.x <= origin.x + width
    }
    
    var mouseOverTail: Bool {
        guard
            let origin = tail.button?.window?.frame.origin,
            let width = tail.button?.window?.frame.width
        else { return false }
        return mouseOnStatusBar && NSEvent.mouseLocation.x >= origin.x && NSEvent.mouseLocation.x <= origin.x + width
    }
    
    var mouseDragging: Bool {
        MouseManager.dragging && mouseOnStatusBar
    }
    
    var mouseInExternalMenu: Bool {
        lastExternalMenus.contains(where: \.containsMouse)
    }
    
    var shouldPresentFeedback: Bool {
        !timeout && MouseManager.none
    }
    
    var maxLength: CGFloat {
        ScreenManager.maxWidth
    }
    
    var popoverShown: Bool {
        AppDelegate.shared?.popover.isShown ?? false
    }
    
    
    
    var edge = CGFloat.zero
    
    var shouldEdgeUpdate = (now: false, will: false)
    
    var idling = (hide: false, alwaysHide: false)
    
    var noAnimation = false
    
    var ignoring = false
    
    var timeout = false
    
    var lastFocusedApp: NSRunningApplication?
    
    var lastExternalMenus: [WindowInfo] = []
    
    
    
    var feedbackCount = Int.zero
    
    var shouldTimersStop = (flag: false, count: Int.zero)

    var mouseWasSpareOrUnidled = false
    
    var draggedToDeactivate = (dragging: false, shouldActivate: false, count: Int.zero)
    
    var was: IntermediateStates = (mouseOnStatusBar: false, mouseSpare: false, triggers: false, mouseInExternalMenu: false)
    
    
    
    // MARK: - Timers & Event Monitors

    var animationTimer: Timer?

    var actionTimer: Timer?

    var feedbackTimer: Timer?

    var triggerTimer: Timer?

    var timeoutTimer: Timer?
    
    var ignoringTimer: Timer?



    var mouseEventMonitor: EventMonitor?
    
    
    
    // MARK: - Dispatches
    
    var updateExternalMenusDispatch: DispatchWorkItem?
    
    
    
    // MARK: - Icons
    
    // Status items
    
    private static let _item0 = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    
    private static let _item1 = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    
    private static let _item2 = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    
    private static var _items = [_item0, _item1, _item2]
    
    // Separators
    
    var head = Separator(order: 2) { StatusBarController._items }
    
    var body = Separator(order: 1) { StatusBarController._items }
    
    var tail = Separator(order: 0) { StatusBarController._items }
    
    // MARK: - Inits
    
    init() {
        // Init separators
        
        // By default, _item0 is the most left while _item2 is the most right.
        // However this will change to conserve the relative position of the separators.
        sort()
        
        if let button = StatusBarController._item0.button {
            button.action = #selector(AppDelegate.toggle(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        if let button = StatusBarController._item1.button {
            button.action = #selector(AppDelegate.toggle(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        if let button = StatusBarController._item2.button {
            button.action = #selector(AppDelegate.toggle(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Start services
        
        startAnimationTimer()
        startActionTimer()
        
        startTriggerTimer()
        
        draggedToDeactivate.shouldActivate = isActive
        
        KeyboardShortcuts.onKeyDown(for: .toggleActive) {
            self.startFunctionalTimers()
            self.toggle()
        }
    }
    
    deinit {
        // Stop services
        
        stopTimer(&animationTimer)
        stopTimer(&actionTimer)
        
        stopTimer(&triggerTimer)
        
        stopTimer(&timeoutTimer)
        stopTimer(&ignoringTimer)
        
        stopMonitor(&mouseEventMonitor)
    }
}

extension StatusBarController {
    func sort() {
        // Make sure the rightmost separator is positioned further back in the array
        StatusBarController._items.sort { (first, second) in
            if !first.isVisible {
                // The first one is invisible -> the first one is more lefty
                return true
            } else if !second.isVisible {
                // The first one is visible while the second one is invisible -> the second one is more lefty
                return false
            } else if let x1 = first.origin?.x, let x2 = second.origin?.x {
                // Both have reasonable x positions -> the leftmost one is more lefty
                return x1 <= x2
            } else { return true }
        }
    }
    
    func updateEdge() {
        edge = (body.origin?.x ?? 0) + body.length
    }
}
