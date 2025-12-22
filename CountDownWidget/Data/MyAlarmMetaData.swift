//
//  MyAlarmMetaData.swift
//  AlarmKit_LittleTale
//
//  Created by Jae hyung Kim on 12/23/25.
//

import AlarmKit

// 앱과 위젯 확장 간에 공유되는 활동 속성의 메타데이터 구조.
struct MyAlarmMetaData: AlarmMetadata {
    
    let createdAt: Date
    let method: Method?
    
    init(method: Method? = nil) {
        self.createdAt = Date.now
        self.method = method
    }
    
    enum Method: String, Codable {
        case wakeUp
        
        var icon: String {
            switch self {
            case .wakeUp: "flame.fill"
            }
        }
    }
}
