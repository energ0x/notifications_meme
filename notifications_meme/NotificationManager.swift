import Foundation
import UserNotifications
import SwiftUI
import Combine

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            if let error = error {
                print("Помилка запиту дозволу: \(error.localizedDescription)")
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            }
        }
    }
    
    func scheduleNotifications(title: String, subtitle: String, body: String, count: Int, intervalInSeconds: Int, startDate: Date) {
        let center = UNUserNotificationCenter.current()
        
        // Очищаємо попередні заплановані сповіщення, якщо потрібно (або можна залишити)
        // center.removeAllPendingNotificationRequests() 
        
        for i in 0..<count {
            let content = UNMutableNotificationContent()
            content.title = title
            if !subtitle.isEmpty {
                content.subtitle = subtitle
            }
            content.body = body
            content.sound = .default
            
            let triggerDate = startDate.addingTimeInterval(TimeInterval(i * intervalInSeconds))
            
            // Якщо час вже минув, то додаємо 1 секунду в майбутнє, щоб сповіщення точно прийшло зараз
            let finalDate = triggerDate > Date() ? triggerDate : Date().addingTimeInterval(1)
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: finalDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Помилка планування сповіщення: \(error.localizedDescription)")
                } else {
                    print("Сповіщення заплановано на \(finalDate)")
                }
            }
        }
    }
    
    // Дозволяє показувати сповіщення навіть коли застосунок відкритий
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
