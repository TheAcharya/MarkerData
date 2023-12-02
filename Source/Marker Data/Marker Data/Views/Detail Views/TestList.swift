//
//  TestList.swift
//  Marker Data
//
//  Created by Theo S on 12/05/2023.
//

import SwiftUI

struct TestList: View {
    let data = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    // Add a state property for the Picker selection
        @State private var selectedValue: String = "Item 1"
    
    var body: some View {
        List(data, id: \.self) { item in
            HStack {
                Text(item)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Picker(selection: $selectedValue, label: Text("Select")) {
                    ForEach(data, id: \.self) {
                        Text($0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct TestList_Previews: PreviewProvider {
    static var previews: some View {
        TestList()
    }
}
