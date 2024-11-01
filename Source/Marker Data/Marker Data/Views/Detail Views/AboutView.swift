//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("AppIconSingle")
                .resizable()
                .frame(width: 200, height: 200)
            
            Text("Marker Data")
                .font(.largeTitle)
                .bold()
            
            Text("Version \(Bundle.main.version) (\(Bundle.main.buildNumber))")
            Text("Copyright © 2024 The Acharya. All rights reserved.")
            
            Link("Acknowledgments & Credits", destination: URL(string: "https://markerdata.theacharya.co/credits/")!)
        }
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
        .padding()
        .frame(width: 500, height: 500)
}
