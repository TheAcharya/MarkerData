//
//  DialogIcon.swift
//  Marker Data
//
//  Created by Vigneswaran Rajkumar
//
//
//  Forces SwiftUI alerts/confirmations to show the PNG app icon (Icon Composer
//  assets often leave dialogs with the generic blank document glyph).
//

import SwiftUI

extension View {
    /// Applies the PNG `AppIconSingle` as the dialog icon for alerts and confirmation dialogs.
    func appDialogIcon() -> some View {
        self.dialogIcon(Image("AppIconSingle"))
    }
}
