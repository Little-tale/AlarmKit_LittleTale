//
//  AlarmActionIntent.swift
//  AlarmKit_LittleTale
//
//  Created by Jae hyung Kim on 12/23/25.
//

import AlarmKit
import AppIntents

struct AlarmActionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Alarm Action"
    static var isDiscoverable: Bool = false
    
    @Parameter
    var id: String
    
    @Parameter
    var isCancelled: Bool
    
    @Parameter
    var isResumed: Bool

    init(id: UUID, isCancelled: Bool, isResumed: Bool) {
        self.id = id.uuidString
        self.isCancelled = isCancelled
        self.isResumed = isResumed
    }
    
    init() {
        
    }
    
    func perform() async throws -> some IntentResult {
        guard let alarmID = UUID(uuidString: id) else {
            return .result()
        }
        if (isCancelled) {
            try AlarmManager.shared.cancel(id: alarmID)
        } else {
            if (isResumed) {
                try AlarmManager.shared.resume(id: alarmID)
            } else {
                try AlarmManager.shared.pause(id: alarmID)
            }
        }
        
        return .result()
    }
}
