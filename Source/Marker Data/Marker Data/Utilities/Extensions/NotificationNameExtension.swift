//
//  NotificationNameExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 26/05/2024.
//

import Foundation

extension Notification.Name {
    static let openFile = Notification.Name("OpenFile")
    static let workflowExtensionFileReceived = Notification.Name("WorkflowExtensionFileReceived")
    static let rolesChanged = Notification.Name("RolesChanged")
    static let FCPShareStart = Notification.Name("FCPShareStart")
    static let updateAvailable = Notification.Name("updateAvailable")
}
