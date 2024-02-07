//
//  AirtableFormView.swift
//  Marker Data
//
//  Created by Milán Várady on 07/02/2024.
//

import SwiftUI

struct AirtableFormView: View {
    @StateObject var profileModel: AirtableDBModel
    
    var body: some View {
        VStack {
            PlatformInfoTextField(
                title: "Airtable API Key",
                prompt: "API Key",
                text: $profileModel.apiKey,
                isRequired: true,
                secureField: true
            )
            
            PlatformInfoTextField(
                title: "Airtable Base ID",
                prompt: "Database URL",
                text: $profileModel.baseID,
                isRequired: true,
                secureField: true
            )
            
            PlatformInfoTextField(
                title: "Rename Key Column",
                prompt: "Different key column name in Notion (Default is \"Marker ID\")",
                text: $profileModel.renameKeyColumn,
                isRequired: false,
                secureField: false
            )
        }
    }
}

#Preview {
    AirtableFormView(profileModel: AirtableDBModel())
        .padding()
        .preferredColorScheme(.dark)
}
