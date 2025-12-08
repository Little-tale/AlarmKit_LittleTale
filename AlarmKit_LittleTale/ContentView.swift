//
//  ContentView.swift
//  AlarmKit_LittleTale
//
//  Created by Jae hyung Kim on 12/7/25.
//

import SwiftUI
import AlarmKit
import AppIntents

struct ContentView: View {
    
    @StateObject private var store = ViewModel(initial: ViewState())
    
    var body: some View {
        NavigationStack {
            Group {
                if store.state.isAuth {
                    listView
                } else {
                    Text("권한 확인이 필요")
                        .font(Font.system(size: 30))
                        .padding(.all, 10)
                        .glassEffect()
                }
            }
            .navigationTitle("Alarm Kit 살펴보기")
        }
        .task {
            store.send(.onAppear)
        }
    }
}

extension ContentView {
    private var listView: some View {
        List {
            Section("Date & Time") {
                DatePicker("", selection: Binding(get: {
                    store.state.scheduleDate
                }, set: { newValue in
                    store.send(.upDateScheduleDate(newValue))
                }), displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
            }
            
            Button("set Alarm") {
                Task {
                    try? await setAlarm()
                }
            }
        }
    }
    
    private func setAlarm() async throws {
        let alert = AlarmPresentation.Alert(
            title: "일어나",
            secondaryButton: AlarmButton(
                text: "Go To App",
                textColor: .blue,
                systemImageName: "app.fill"
            ),
            secondaryButtonBehavior: .custom
        )
        // 위는 UI 구성 요소
        let presentation = AlarmPresentation(alert: alert)
        
        let attributed = AlarmAttributes<CountDownAttribute>(presentation: presentation, metadata: CountDownAttribute(), tintColor: .orange)
        
        let id = UUID()
        
        //        let schedule = Alarm.Schedule.Relative(time: T##Alarm.Schedule.Relative.Time, repeats: T##Alarm.Schedule.Relative.Recurrence)
        let schedule = Alarm.Schedule.fixed(store.state.scheduleDate)
        let config = AlarmManager.AlarmConfiguration(
            schedule: schedule,
            attributes: attributed,
            secondaryIntent: OpenAppIntents(id: id)
        )
        
        let _ = try await AlarmManager.shared.schedule(id: id, configuration: config)
        
        print(store.state.scheduleDate)
        print("Success")
    }
}


#Preview {
    ContentView()
}

struct OpenAppIntents: LiveActivityIntent {
    static var title: LocalizedStringResource = "Opens App"
    static var supportedModes: IntentModes = .foreground
    static var isDiscoverable: Bool = false
    
    
    @Parameter
    var id: String
    
    init(id: UUID) {
        self.id = id.uuidString
    }
    
    init() {
        
    }
    
    func perform() async throws -> some IntentResult {
        
        if let alarmID = UUID(uuidString: id) {
            print(alarmID)
        }
        
        return .result()
    }
}
