//
//  PlatformInfoTextField.swift
//  Marker Data
//
//  Created by Milán Várady on 06/02/2024.
//

import SwiftUI
import PasswordField

struct PlatformInfoTextField: View {
    let title: String
    let prompt: LocalizedStringKey
    @Binding var text: String
    let isRequired: Bool
    let secureField: Bool
    
    var body: some View {
        HStack {
            Group {
                Text(title) +
                Text(" (\(isRequired ? "Required" : "Optional"))").fontWeight(.thin) +
                Text(":")
            }
            .padding(.trailing, -12)
            
            if secureField {
                PasswordField("", text: $text) { isInputVisible in
                    // Visibility toggle button
                    Button {
                        isInputVisible.wrappedValue = isInputVisible.wrappedValue.toggled()
                    } label: {
                        Image(systemName: isInputVisible.wrappedValue ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                }
                .visibilityControlPosition(.inlineOutside)
                .textFieldStyle(.roundedBorder)
            } else {
                TextField(prompt, text: $text)
                    .padding(.leading, 8)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                text = ""
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
    }
    }
