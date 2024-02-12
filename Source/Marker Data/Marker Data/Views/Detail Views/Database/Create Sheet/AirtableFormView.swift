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
            airtableFields
            
            Divider()
                .padding(.vertical, 8)
            
            DropboxSetupView()
        }
    }
        
    var airtableFields: some View {
        VStack {
            PlatformInfoTextField(
                title: "Airtable Token",
                prompt: "Personal access token",
                text: $profileModel.token,
                isRequired: true,
                secureField: true
            )
            
            PlatformInfoTextField(
                title: "Airtable Base ID",
                prompt: "Base IDs begin with \"app\"",
                text: $profileModel.baseID,
                isRequired: true,
                secureField: true
            )
            
            PlatformInfoTextField(
                title: "Airtable Table ID",
                prompt: "Table IDs begin with \"tbl\"",
                text: $profileModel.tableID,
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
