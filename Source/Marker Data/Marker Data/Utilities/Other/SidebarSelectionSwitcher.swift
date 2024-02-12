//
//  SidebarSelectionSwitcher.swift
//  Marker Data
//
//  Created by Milán Várady on 03/02/2024.
//

import Foundation
import SwiftUI

/// Recieves events from the FCP Share Destination and Workflow Extension
/// and sets the sidebar selection to the Extract Panel so we can see the progress
final class SidebarSelectionSwitcher {
    @Binding var sidebarSelection: MainViews
    
    init(sidebarSelection: Binding<MainViews>) {
        self._sidebarSelection = sidebarSelection
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToExtactView),
            name: Notification.Name("OpenFile"),
            object: nil)
        
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(switchToExtactView),
            name: Notification.Name("WorkflowExtensionFileReceived"),
            object: nil)
    }
    
    @objc func switchToExtactView() {
        self.sidebarSelection = .extract
    }
}
