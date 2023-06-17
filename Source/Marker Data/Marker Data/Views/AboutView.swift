//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct AboutView: View {
    
    let versionBuildIdentifier: String = {
        let dictionary = Bundle.main.infoDictionary ?? [:]
        let version = dictionary["CFBundleShortVersionString"] as? String
        let build = dictionary["CFBundleVersion"] as? String
        var result = ""
        if let version = version {
            result += version
        }
        if let build = build {
            result += " (\(build))"
        }
        return result
    }()
    
    var body: some View {
        VStack(spacing: 20) {
            Image("AppIcon2")
                .resizable()
                .frame(width: 200, height: 200)
            Text("Marker Data")
                .font(.largeTitle)
                .bold()
            Text("Version \(versionBuildIdentifier)")
            Text("Copyright © 2023 The Acharya. All rights reserved.")
            Text("Acknowledgments & Credits")
            
        }
        
    }
    
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .padding()
            .frame(width: 500, height: 500)
    }
}
