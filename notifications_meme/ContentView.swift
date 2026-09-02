import SwiftUI

struct ContentView: View {
    @StateObject private var notificationManager = NotificationManager()
    
    @State private var title: String = "Instagram"
    @State private var subtitle: String = ""
    @State private var bodyText: String = "Хтось вподобав вашу розповідь."
    
    @State private var startDate: Date = Date().addingTimeInterval(5) // По замовчуванню через 5 секунд
    @State private var notificationCount: Int = 1
    @State private var intervalInSeconds: Int = 5
    
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Текст сповіщення")) {
                    TextField("Заголовок (наприклад, Telegram)", text: $title)
                    TextField("Підзаголовок (необов'язково)", text: $subtitle)
                    TextField("Текст повідомлення", text: $bodyText)
                }
                
                Section(header: Text("Час та кількість")) {
                    DatePicker("Час першого сповіщення", selection: $startDate, displayedComponents: [.hourAndMinute, .date])
                    
                    Stepper("Кількість: \(notificationCount)", value: $notificationCount, in: 1...100)
                    
                    if notificationCount > 1 {
                        Stepper("Інтервал: \(intervalInSeconds) секунд", value: $intervalInSeconds, in: 1...3600)
                    }
                }
                
                Section {
                    Button(action: {
                        if !notificationManager.isAuthorized {
                            notificationManager.requestAuthorization()
                        } else {
                            scheduleNotifications()
                        }
                    }) {
                        Text(notificationManager.isAuthorized ? "Запланувати сповіщення" : "Надати дозвіл на сповіщення")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(notificationManager.isAuthorized ? .blue : .red)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Налаштування")
            .onAppear {
                notificationManager.checkAuthorizationStatus()
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Успіх!"),
                    message: Text("Заплановано \(notificationCount) сповіщень. Перше прийде о \(startDate.formatted(date: .omitted, time: .shortened))."),
                    dismissButton: .default(Text("ОК"))
                )
            }
        }
    }
    
    private func scheduleNotifications() {
        notificationManager.scheduleNotifications(
            title: title,
            subtitle: subtitle,
            body: bodyText,
            count: notificationCount,
            intervalInSeconds: intervalInSeconds,
            startDate: startDate
        )
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
