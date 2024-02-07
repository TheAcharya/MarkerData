//
//  NotionFormView.swift
//  Marker Data
//
//  Created by Milán Várady on 07/02/2024.
//

import SwiftUI

struct NotionFormView: View {
    @StateObject var profileModel: NotionDBModel
    
    var body: some View {
        VStack(alignment: .leading) {
            PlatformInfoTextField(
                title: "Notion Workspace",
                prompt: "Workspace Name",
                text: $profileModel.workspaceName,
                isRequired: true,
                secureField: false
            )
            
            PlatformInfoTextField(
                title: "Notion V2 Token",
                prompt: "Token",
                text: $profileModel.token,
                isRequired: true,
                secureField: true
            )
            
            PlatformInfoTextField(
                title: "Notion Database URL",
                prompt: "Database URL",
                text: $profileModel.databaseURL,
                isRequired: false,
                secureField: true
            )
            
            PlatformInfoTextField(
                title: "Rename Key Column",
                prompt: "Different key column name in Notion (Default is \"Marker ID\")",
                text: $profileModel.renameKeyColumn,
                isRequired: false,
                secureField: false
            )
            
            Divider()
            
            Group {
                Text("Merge Only") +
                Text(" (Optional)").fontWeight(.thin) +
                Text(":")
            }
            
            ZStack(alignment: .bottomTrailing) {
                List(NotionMergeOnlyColumn.allCases) { mergeColumn in
                    HStack {
                        Toggle("", isOn: Binding<Bool>(
                            get: {
                                return profileModel.mergeOnlyColumns.contains(mergeColumn)
                            },
                            set: { enable in
                                if enable {
                                    profileModel.mergeOnlyColumns.append(mergeColumn)
                                } else {
                                    if let index = profileModel.mergeOnlyColumns.firstIndex(where: { $0 == mergeColumn }) {
                                        profileModel.mergeOnlyColumns.remove(at: index)
                                    }
                                }
                            }
                        ))
                        
                        Text(mergeColumn.rawValue)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button {
                    profileModel.mergeOnlyColumns.removeAll()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .padding(.trailing, 30)
                .padding(.bottom, 10)
            }
            .frame(height: 140)
        }
    }
}

#Preview {
    NotionFormView(profileModel: NotionDBModel())
        .padding()
        .preferredColorScheme(.dark)
}
