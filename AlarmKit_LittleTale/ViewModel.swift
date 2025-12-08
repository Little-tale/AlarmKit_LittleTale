//
//  ViewModel.swift
//  AlarmKit_LittleTale
//
//  Created by Jae hyung Kim on 12/7/25.
//

import Foundation
import AlarmKit

enum ViewIntent: MVIIntent {
    case onAppear
    case upDateScheduleDate(Date)
}

struct ViewState: MVIState {
    var isAuth = false
    var scheduleDate: Date = .now
}

enum ViewEffect: MVIEffect {
    case showToast(String)
}

final class ViewModel: MVIContainer<ViewIntent, ViewState, ViewEffect> {
    
    override func send(_ intent: ViewIntent) {
        switch intent {
        case .onAppear:
            Task(priority: .high) {
                do {
                    try await checkAndAuthorize()
                } catch {
                    print(error.localizedDescription)
                    emit(.showToast("Error - \(error.localizedDescription)"))
                }
            }
            
        case let .upDateScheduleDate(date):
            setState { state in
                state.scheduleDate = date
            }
            
            
        }
    }
}

extension ViewModel {
    private func checkAndAuthorize() async throws {
        var currentValue = false
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            let status = try await AlarmManager.shared.requestAuthorization()
            currentValue = status == .authorized
        case .denied:
            currentValue = false
        case .authorized:
            currentValue = true
        @unknown default:
            fatalError()
        }
        
        setState { state in
            state.isAuth = currentValue
        }
    }
}

