//
//  MenuController.swift
//  Abyssal
//
//  Created by KrLite on 2023/6/13.
//

import Cocoa

class MenuController: NSViewController, NSMenuDelegate {
    
    let themesMenu = NSMenu()
    
    let tips = Tips()
    
    // MARK: - Outlets
    
    @IBOutlet var viewMain: NSView!
    
    
    
    @IBOutlet weak var viewModifiers: NSStackView!
    
    @IBOutlet weak var boxModifierShift: NSBox!
    
    @IBOutlet weak var buttonModifierShift: NSButton!
    
    @IBOutlet weak var boxModifierOption: NSBox!
    
    @IBOutlet weak var buttonModifierOption: NSButton!
    
    @IBOutlet weak var boxModifierCommand: NSBox!
    
    @IBOutlet weak var buttonModifierCommand: NSButton!
    
    @IBOutlet weak var labelTimeout: NSTextField!
    
    @IBOutlet weak var sliderTimeout: NSSlider!
    

    
    @IBOutlet weak var labelAppTitle: NSTextField!
    
    @IBOutlet weak var buttonAppVersion: NSButton!
    
    @IBOutlet weak var switchStartsWithMacOS: NSSwitch!
    
    
    
    @IBOutlet weak var boxQuitApp: FillOnHoverBox!
    
    @IBOutlet weak var buttonQuitApp: NSButton!
    
    @IBOutlet weak var boxLink: FillOnHoverBox!
    
    @IBOutlet weak var buttonLink: NSButton!
    
    @IBOutlet weak var boxMinimize: FillOnHoverBox!
    
    @IBOutlet weak var buttonMinimize: NSButton!
    
    @IBOutlet weak var boxTips: FillOnHoverBox!
    
    @IBOutlet weak var buttonTips: NSButton!
    
    
    
    @IBOutlet weak var switchAutoShows: NSSwitch!
    
    @IBOutlet weak var labelFeedbackIntensity: NSTextField!
    
    @IBOutlet weak var sliderFeedbackIntensity: NSSlider!
    
    
    
    @IBOutlet weak var popUpButtonThemes: NSPopUpButton!
    
    @IBOutlet weak var switchUseAlwaysHideArea: NSSwitch!
    
    @IBOutlet weak var switchReduceAnimation: NSSwitch!
    
    // MARK: - Tips
    
    var definedTips: [NSView: (tip: Tip, trackingArea: NSTrackingArea)] = [:]
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        initTips()
    }
    
    override func viewDidAppear() {
        Helper.CHECK_NEWER_VERSION_TASK.resume()
        Helper.delegate?.statusBarController.startFunctionalTimers()
    }
    
    override func viewWillDisappear() {
        Helper.delegate?.statusBarController.startFunctionalTimers()
    }
    
}

var menuAppearanceObservation: NSKeyValueObservation?

extension MenuController {
    
    // MARK: - Storyboard Instantiation
    
    static func freshController() -> MenuController {
        Helper.CHECK_NEWER_VERSION_TASK.resume()
        
        let storyboard = NSStoryboard(
            name: NSStoryboard.Name("Main"),
            bundle: nil
        )
        
        let identifier = NSStoryboard.SceneIdentifier("MenuController")
        
        guard let controller = storyboard.instantiateController(
            withIdentifier: identifier
        ) as? MenuController else {
            fatalError("Can not find MenuController")
        }
        
        // Observe appearance change
        menuAppearanceObservation = NSApp.observe(\.effectiveAppearance) { (app, _) in
            app.effectiveAppearance.performAsCurrentDrawingAppearance {
                let menuController = ((app.delegate as? AppDelegate)?.popover.contentViewController as? MenuController)
                
                if menuController?.isViewLoaded ?? false {
                    menuController?.updateColoredWidgets()
                }
            }
        }
        
        return controller
    }
    
}

extension MenuController {
    
    func initTips() {
        definedTips = [
            buttonAppVersion: (
                tip: Tip(
                    tipString: {
                        !Helper.versionComponent.needsUpdate ? nil : NSLocalizedString("Tip/ButtonAppVersion", value: """
An update is available.
""", comment: "if (update available) -> (button) app version")
                    }, preferredEdge: .minX
                )!, trackingArea: buttonAppVersion.visibleRect.getTrackingArea(self, viewToAdd: buttonAppVersion)
            ),
            
            viewModifiers: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/ViewModifier/1", value: """
Modifier keys to make the separators visible.
""", comment: "(view) modifier") + (!Data.autoShows ? "" : Data.SPACE + NSLocalizedString("Tip/ViewModifier/2", value: """
If the mouse is hovering over spare area, temporarily disables **Auto Shows.**
""", comment: "if (auto shows) -> (view) modifier"))
                    }
                )!, trackingArea: viewModifiers.visibleRect.getTrackingArea(self, viewToAdd: viewModifiers)
            ),
            sliderTimeout: (
                tip: Tip(
                    dataString: { Data.timeoutAttribute.label },
                    tipString: {
                        NSLocalizedString("Tip/SliderTimeout", value: """
Time to countdown before disabling **Auto Idling.**
""", comment: "(slider) timeout")
                    }, rect: { self.sliderTimeout.rectOfTickMark(at: self.sliderTimeout.integerValue).offsetBy(dx: 0, dy: 8) }
                )!, trackingArea: sliderTimeout.thumbRect.getTrackingArea(self, viewToAdd: sliderTimeout)
            ),
            switchStartsWithMacOS: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/SwitchStartsWithMacOS", value: """
Run **Abyssal** when macOS starts.
""", comment: "(switch) starts with macOS")
                    }
                )!, trackingArea: switchStartsWithMacOS.visibleRect.getTrackingArea(self, viewToAdd: switchStartsWithMacOS)
            ),
            
            buttonTips: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/ButtonTips", value: """
Click to hide tips.
""", comment: "(button) tips")
                    }
                )!, trackingArea: buttonTips.visibleRect.getTrackingArea(self, viewToAdd: buttonTips)
            ),
            buttonLink: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/ButtonLink", value: """
**Abyssal** is open sourced. Click to view the source code repository.
""", comment: "(button) link")
                    }
                )!, trackingArea: buttonLink.visibleRect.getTrackingArea(self, viewToAdd: buttonLink)
            ),
            buttonMinimize: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/ButtonMinimize", value: """
Minimize this window.
""", comment: "(button) minimize")
                    }
                )!, trackingArea: buttonMinimize.visibleRect.getTrackingArea(self, viewToAdd: buttonMinimize)
            ),
            
            popUpButtonThemes: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/PopUpButtonThemes", value: """
Choose a theme.
""", comment: "(pop up button) themes")
                    }, preferredEdge: .minX
                )!, trackingArea: popUpButtonThemes.visibleRect.getTrackingArea(self, viewToAdd: popUpButtonThemes)
            ),
            switchAutoShows: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/SwitchAutoShows", value: """
Whether to auto show the hidden status items when mouse hovering over spare area.
""", comment: "(switch) auto shows")
                    }
                )!, trackingArea: switchAutoShows.visibleRect.getTrackingArea(self, viewToAdd: switchAutoShows)
            ),
            sliderFeedbackIntensity: (
                tip: Tip(
                    dataString: {
                        Data.feedbackAttribute.label
                    },
                    tipString: {
                        NSLocalizedString("Tip/SliderFeedbackIntensity", value: """
Feedback intensity given while triggering **Auto Shows.**
""", comment: "(slider) feedback intensity")
                    }, rect: { self.sliderFeedbackIntensity.rectOfTickMark(at: self.sliderFeedbackIntensity.integerValue).offsetBy(dx: 0, dy: 8) }
                )!, trackingArea: sliderFeedbackIntensity.thumbRect.getTrackingArea(self, viewToAdd: sliderFeedbackIntensity)
            ),
            
            switchUseAlwaysHideArea: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/SwitchUseAlwaysHideArea", value: """
Hide certain status items permanently.
""", comment: "(switch) use always hide area")
                    }
                )!, trackingArea: switchUseAlwaysHideArea.visibleRect.getTrackingArea(self, viewToAdd: switchUseAlwaysHideArea)
            ),
            switchReduceAnimation: (
                tip: Tip(
                    tipString: {
                        NSLocalizedString("Tip/SwitchReduceAnimations", value: """
Reduce animations to gain a more performant experience.
""", comment: "(switch) reduce animations")
                    }
                )!, trackingArea: switchReduceAnimation.visibleRect.getTrackingArea(self, viewToAdd: switchReduceAnimation)
            )
        ]
        
        definedTips.forEach { tips.bind($0.key, trackingArea: $0.value.trackingArea, tip: $0.value.tip) }
    }
    
}

var themeIndexKey = UnsafeRawPointer(bitPattern: "themeIndexKey".hashValue)

extension MenuController {
    
    @objc func switchToTheme(
        _ sender: Any
    ) {
        if
            let button = sender as? NSMenuItem,
            let index = objc_getAssociatedObject(button, &themeIndexKey) as? Int
        {
            Helper.switchToTheme(index)
        }
    }
    
    func initData() {
        // Version info
        
        buttonAppVersion.title = Helper.versionComponent.version
        
        if Helper.versionComponent.needsUpdate {
            buttonAppVersion.isEnabled = true
            buttonAppVersion.image = NSImage(systemSymbolName: "shift.fill", accessibilityDescription: nil)
        } else {
            buttonAppVersion.isEnabled = false
            buttonAppVersion.image = nil
        }
        
        // Themes menu
        
        do {
            for (index, theme) in Themes.themes.enumerated() {
                let item: NSMenuItem = NSMenuItem(
                    title: Themes.themeNames[index],
                    action: #selector(self.switchToTheme(_:)),
                    keyEquivalent: ""
                )
                
                item.image = theme.icon
                objc_setAssociatedObject(item, &themeIndexKey, index, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                themesMenu.addItem(item)
            }
            
            popUpButtonThemes.removeAllItems()
            popUpButtonThemes.menu = themesMenu
            popUpButtonThemes.menu?.delegate = self
            
            if let index = Themes.themes.firstIndex(of: Data.theme) {
                popUpButtonThemes.selectItem(at: index)
            }
        }
        
        // Controls
        
        sliderTimeout.minValue = 0
        sliderTimeout.maxValue = Double(Data.timeoutTickMarks - 1)
        sliderTimeout.numberOfTickMarks = Data.timeoutTickMarks
        
        sliderFeedbackIntensity.minValue = 0
        sliderFeedbackIntensity.maxValue = Double(Data.feedbackIntensityTickMarks - 1)
        sliderFeedbackIntensity.numberOfTickMarks = Data.feedbackIntensityTickMarks
        
        
        
        buttonModifierShift.flag = Data.modifiers.shift
        buttonModifierOption.flag = Data.modifiers.option
        buttonModifierCommand.flag = Data.modifiers.command
        updateModifiers()
        
        sliderTimeout.objectValue = Data.timeout
        updateTimeoutEnabled()
        
        switchStartsWithMacOS.flag = Data.startsWithMacos
        
        switchAutoShows.flag = Data.autoShows
        sliderFeedbackIntensity.objectValue = Data.feedbackIntensity
        updateFeedbackIntensityEnabled()
        
        switchUseAlwaysHideArea.flag = Data.useAlwaysHideArea
        switchReduceAnimation.flag = Data.reduceAnimation
        
        updateColoredWidgets()
    }
    
    func updateColoredWidgets() {
        if Helper.versionComponent.needsUpdate {
            buttonAppVersion.contentTintColor = Colors.Opaque.accent
        } else {
            buttonAppVersion.contentTintColor = NSColor.tertiaryLabelColor
        }
        
        updateModifiers()
        updateButtons()
    }
    
    func updateModifiers() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            
            updateModifier(boxModifierShift, Data.modifiers.shift)
            updateModifier(boxModifierOption, Data.modifiers.option)
            updateModifier(boxModifierCommand, Data.modifiers.command)
        })
    }
    
    private func updateModifier(
        _ box: NSBox,
        _ flag: Bool
    ) {
        let colorOn = NSColor.quaternaryLabelColor.withAlphaComponent(0.07)
        let colorOff = NSColor.quaternaryLabelColor.withAlphaComponent(0)
        
        box.animator().fillColor = flag ? colorOn : colorOff
    }
    
    func updateButtons() {
        boxQuitApp.setOriginlalFillColor(Colors.Translucent.DANGER)
        boxQuitApp.animator().borderColor = Colors.Translucent.DANGER
        buttonQuitApp.animator().contentTintColor = Colors.Opaque.DANGER
        
        boxTips.setOriginlalFillColor(Colors.Translucent.accent)
        boxTips.overrideFillColor(Data.tips ? Colors.Opaque.accent : nil)
        boxTips.animator().borderColor = Colors.Translucent.accent
        buttonTips.animator().contentTintColor = Data.tips ? NSColor.white : Colors.Opaque.accent
        buttonTips.image = Data.tips
        ? NSImage(systemSymbolName: "tag.fill", accessibilityDescription: nil)
        : NSImage(systemSymbolName: "tag.slash", accessibilityDescription: nil)
        definedTips[buttonTips]?.tip.update()
        
        boxLink.setOriginlalFillColor(Colors.Translucent.accent)
        boxLink.animator().borderColor = Colors.Translucent.accent
        buttonLink.animator().contentTintColor = Colors.Opaque.accent
        
        boxMinimize.setOriginlalFillColor(Colors.Translucent.SAFE)
        boxMinimize.animator().borderColor = Colors.Translucent.SAFE
        buttonMinimize.animator().contentTintColor = Colors.Opaque.SAFE
    }
    
}

extension MenuController {
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        tips.mouseEntered(with: event)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        tips.mouseExited(with: event)
    }
    
}

extension MenuController {
    
    private func setSliderEnabled(
        _ slider: NSSlider,
        _ flag: Bool
    ) {
        slider.isEnabled = flag
    }
    
    private func setSliderLabelEnabled(
        _ label: NSTextField,
        _ flag: Bool
    ) {
        label.textColor = flag ? NSColor.labelColor : NSColor.disabledControlTextColor
    }
    
    func updateTimeoutEnabled() {
        setSliderLabelEnabled(labelTimeout, Data.timeoutAttribute.attr != nil)
        
        definedTips[sliderTimeout]?.tip.update()
    }
    
    func updateFeedbackIntensityEnabled() {
        setSliderEnabled(sliderFeedbackIntensity, Data.autoShows)
        setSliderLabelEnabled(labelFeedbackIntensity, Data.autoShows && Data.feedbackIntensity != 0)
        
        definedTips[sliderFeedbackIntensity]?.tip.update()
    }
    
}

extension MenuController {
    
    func openUrl(
        _ sender: Any?,
        _ url: URL
    ) {
        minimize(sender)
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Global Actions
    
    @IBAction func quit(
        _ sender: Any?
    ) {
        minimize(sender)
        
        if !(Helper.delegate?.popover.isShown ?? false) {
            NSApplication.shared.terminate(sender)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NSApplication.shared.terminate(sender)
            }
        }
    }
    
    @IBAction func goToRelease(
        _ sender: Any?
    ) {
        openUrl(sender, Helper.RELEASE_URL)
    }
    
    @IBAction func sourceCode(
        _ sender: Any?
    ) {
        openUrl(sender, Helper.SOURCE_CODE_URL)
    }
    
    @IBAction func minimize(
        _ sender: Any?
    ) {
        Helper.delegate?.closePopover(sender)
    }
    
    // MARK: - Data Actions
    @IBAction func toggleModifierShift(
        _ sender: NSButton
    ) {
        Data.modifiers.shift = sender.flag
        updateModifiers()
    }
    
    @IBAction func toggleModifierOption(
        _ sender: NSButton
    ) {
        Data.modifiers.option = sender.flag
        updateModifiers()
    }
    
    @IBAction func toggleModifierCommand(
        _ sender: NSButton
    ) {
        Data.modifiers.command = sender.flag
        updateModifiers()
    }
    
    @IBAction func toggleTimeout(
        _ sender: NSSlider
    ) {
        Data.timeout = sender.integerValue
        updateTimeoutEnabled()
    }
    
    @IBAction func toggleTips(
        _ sender: NSButton
    ) {
        Data.tips = sender.flag
        updateButtons()
        
        // It works!!!
        NSAnimationContext.runAnimationGroup() { context in
            context.allowsImplicitAnimation = true
            context.duration = 1
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 1.24, 0.86, -0.01)
            
            (NSApp.delegate as? AppDelegate)?.statusBarController.head.length = 200
        }
    }
    
    
    
    @IBAction func toggleAutoShows(
        _ sender: NSSwitch
    ) {
        Data.autoShows = sender.flag
        updateFeedbackIntensityEnabled()
    }
    
    @IBAction func toggleFeedbackIntensity(
        _ sender: NSSlider
    ) {
        Data.feedbackIntensity = sender.integerValue
        updateFeedbackIntensityEnabled()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            Helper.delegate?.statusBarController.triggerFeedback()
        }
    }
    
    
    
    @IBAction func toggleUseAlwaysHideArea(
        _ sender: NSSwitch
    ) {
        Data.useAlwaysHideArea = sender.flag
        Helper.delegate?.statusBarController.untilTailVisible(sender.flag)
    }
    
    @IBAction func toggleReduceAnimation(
        _ sender: NSSwitch
    ) {
        Data.reduceAnimation = sender.flag
    }
    
    
    
    @IBAction func toggleStartsWithMacos(
        _ sender: NSSwitch
    ) {
        Data.startsWithMacos = sender.flag
    }
    
}
