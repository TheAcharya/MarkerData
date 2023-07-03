//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct TokenLabelSettingsView: View {
    var body: some View {
        Text("Token Label Settings View")
    }
}

struct TokenLabelSettingsView_Previews: PreviewProvider {

    @StateObject static private var settingsStore = SettingsStore()

    static var previews: some View {
        TokenLabelSettingsView()
    }

}
