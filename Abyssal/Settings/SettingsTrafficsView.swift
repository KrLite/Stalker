//
//  SettingsTrafficsView.swift
//  Abyssal
//
//  Created by KrLite on 2024/6/22.
//

import SwiftUI
import Defaults

struct SettingsTrafficsView: View {
    @Default(.tipsEnabled) var tipsEnabled
    
    var body: some View {
        HStack {
            // Quit
            Box(isOn: false) {
            } content: {
                HStack {
                    Image(systemSymbol: .xmark)
                        .bold()
                    
                    Text("Quit \(Bundle.main.appName)")
                        .fixedSize()
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 12)
                .frame(maxHeight: .infinity)
            }
            .tint(.red)
            .foregroundStyle(.red)
            
            Spacer(minLength: 32)
            
            // Tips
            Box(isOn: $tipsEnabled, behavior: .toggle) {
                HStack {
                    Image(systemSymbol: tipsEnabled ? .tagFill : .tagSlashFill)
                        .bold()
                        .contentTransition(.symbolEffect(.replace))
                    
                    Text("Tips")
                        .fixedSize()
                }
                .padding(.horizontal, 12)
                .frame(maxHeight: .infinity)
            }
            
            // Source
            Box(isOn: false) {
                
            } content: {
                Image(systemSymbol: .barcode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 32)
            
            // Minimize
            Box(isOn: false) {
                
            } content: {
                Image(systemSymbol: .arrowDownRightAndArrowUpLeft)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 32)
            .tint(.green)
            .foregroundStyle(.green)
        }
        .frame(height: 32)
    }
}

#Preview {
    SettingsTrafficsView()
        .padding()
}
