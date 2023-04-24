//
//  UserAlert.swift
//  Marker Data
//
//  Created by Theo S on 21/04/2023.
//

import SwiftUI

struct UserAlertView: View {
    @EnvironmentObject var viewModel: ErrorViewModel
    
    let title: String
    let onDismiss: () -> Void

    var showAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showAlert },
            set: { newValue in
                if !newValue {
                    viewModel.dismissAlert()
                }
            }
        )
    }
    
    var body: some View {
        EmptyView()
            .alert(isPresented: showAlertBinding) {
                Alert(title: Text(title),
                      message: Text(viewModel.errorMessage ?? ""),
                      dismissButton: .default(Text("OK"), action: onDismiss))
            }
    }
}


