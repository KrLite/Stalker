//
//  ActivationPolicyManager.swift
//  Abyssal
//
//  Created by KrLite on 2024/6/23.
//

import Foundation
import AppKit

struct ActivationPolicyManager {
    private static var dispatch: DispatchWorkItem?
    private static var fallback: NSApplication.ActivationPolicy = .accessory
    
    static func set(
        _ activationPolicy: NSApplication.ActivationPolicy,
        asFallback: Bool = false,
        deadline: DispatchTime,
        andRun: @escaping () -> Void = {}
    ) {
        dispatch = .init() {
            set(activationPolicy, asFallback: asFallback)
        }
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            dispatch?.perform()
            andRun()
        }
    }
    
    static func set(
        _ activationPolicy: NSApplication.ActivationPolicy,
        asFallback: Bool = false
    ) {
        cancel()
        NSApp.setActivationPolicy(activationPolicy)
        
        if asFallback {
            fallback = activationPolicy
        }
    }
    
    static func setToFallback(
        deadline: DispatchTime,
        andRun: @escaping () -> Void = {}
    ) {
        set(fallback, deadline: deadline, andRun: andRun)
    }
    
    static func setToFallback() {
        set(fallback)
    }
    
    static func toggleBetweenFallback(
        _ activationPolicy: NSApplication.ActivationPolicy,
        deadline: DispatchTime,
        andRun: @escaping () -> Void = {}
    ) -> Bool {
        guard activationPolicy != fallback else {
            setToFallback(deadline: deadline, andRun: andRun)
            return false
        }
        
        if NSApp.activationPolicy() == fallback {
            set(activationPolicy, deadline: deadline, andRun: andRun)
            return true
        } else {
            setToFallback(deadline: deadline, andRun: andRun)
            return false
        }
    }
    
    static func toggleBetweenFallback(
        _ activationPolicy: NSApplication.ActivationPolicy
    ) -> Bool {
        guard activationPolicy != fallback else {
            setToFallback()
            return false
        }
        
        if NSApp.activationPolicy() == fallback {
            set(activationPolicy)
            return true
        } else {
            setToFallback()
            return false
        }
    }
    
    static func cancel() {
        dispatch?.cancel()
        dispatch = nil
    }
}
