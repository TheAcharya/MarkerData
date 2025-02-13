//
//  NotificationManager.swift
//  Marker Data
//
//  Created by Milán Várady on 21/01/2024.
//

import Foundation
import UserNotifications
import OSLog

struct NotificationManager {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NotificationManager")
    
    static func sendNotification(taskFinished: Bool, title: String, body: String = "") async {
        let frequencyInt = UserDefaults.standard.integer(forKey: "notificationFrequency")
        guard let notificationFrequency = NotificationFrequency(rawValue: frequencyInt) else {
            Self.logger.error("Failed to read notification frequency settings")
            return
        }
        
        // Check if we should send notifiction
        // else return
        switch notificationFrequency {
        case .never:
            return
        case .onlyOnCompletion:
            if !taskFinished {
                return
            }
        case .allSteps:
            break
        }
        
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        guard (settings.authorizationStatus == .authorized) ||
                (settings.authorizationStatus == .provisional) else {

            // Ask for authorization
            do {
                try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                logger.error("Failed to request notification authorization. Error: \(error.localizedDescription)")
            }

            return
        }

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: .leastNonzeroMagnitude, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logger.error("Failed to send notication. Error: \(error.localizedDescription)")
        }
    }
}
