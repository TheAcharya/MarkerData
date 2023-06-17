//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("AppIcon2")
                .resizable()
                .frame(width: 100, height: 100)
        }
        
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .padding()
    }
}
