//
//  TriggerStandbyControl.swift
//  Abyssal
//
//  Created by KrLite on 2024/11/6.
//

import SwiftUI
import Luminare
import Defaults

struct TriggerStandbyControl: View {
    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    @Default(.modifier) private var modifier
    @Default(.modifierCompose) private var modifierCompose

    var body: some View {
        VStack {
            LuminareCompose("Trigger standby", reducesTrailingSpace: true) {
                HStack(spacing: 0) {
                    Text("by")
                    compose()
                }
                .foregroundStyle(.secondary)
            }

            HStack {
                Spacer()

                Group {
                    toggle(isOn: $modifier.control) {
                        expandableLabel(modifier.control) {
                            Text("Control")
                        } image: {
                            Image(systemSymbol: .control)
                        }
                    }

                    toggle(isOn: $modifier.option) {
                        expandableLabel(modifier.option) {
                            Text("Option")
                        } image: {
                            Image(systemSymbol: .option)
                        }
                    }

                    toggle(isOn: $modifier.command) {
                        expandableLabel(modifier.command) {
                            Text("Command")
                        } image: {
                            Image(systemSymbol: .command)
                        }
                    }
                }
                .animation(animation, value: modifier)
            }
            .toggleStyle(.button)
            .buttonStyle(LuminareCompactButtonStyle(extraCompact: true))
            .padding(4)
            .padding(.top, -4)
        }
    }

    @ViewBuilder private func toggle(isOn: Binding<Bool>, @ViewBuilder label: @escaping () -> some View) -> some View {
        Toggle(isOn: isOn) {
            label()
                .frame(height: 30)
                .padding(.horizontal, 8)
                .foregroundStyle(isOn.wrappedValue ? AnyShapeStyle(.background) : AnyShapeStyle(.primary))
                .background {
                    if isOn.wrappedValue {
                        Color.accentColor
                            .modifier(LuminareBordered())
                    } else {
                        Color.clear
                    }
                }
                .animation(animationFast, value: isOn.wrappedValue)
        }
    }

    @ViewBuilder private func expandableLabel(
        _ isExpanded: Bool,
        @ViewBuilder text: @escaping () -> some View,
        @ViewBuilder image: @escaping () -> some View
    ) -> some View {
        HStack {
            if isExpanded {
                text()
            }

            image()
        }
    }

    @ViewBuilder private func compose() -> some View {
        LuminareCompactPicker(selection: $modifierCompose, isBordered: false) {
            ForEach(Modifier.Compose.allCases, id: \.self) {compose in
                switch compose {
                case .any:
                    Text("any")
                case .all:
                    Text("all")
                }
            }
        }
    }
}

#Preview {
    LuminareSection {
        TriggerStandbyControl()
    }
    .padding()
}