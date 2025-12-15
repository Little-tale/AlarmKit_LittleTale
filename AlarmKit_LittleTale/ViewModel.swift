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
    case alertIsPresented(Bool)
    case showAlert(String)
}

struct ViewState: MVIState {
    var isAuth = false
    var scheduleDate: Date = .now
    
    var alertIsPresented: Bool = false
    var alertMessage: String = ""
}


enum FeatureEffect: MVIEffect {
    case updateViewState(Bool)
    case showToast(String)
}

enum AlarmAuthorizationState {
    case reCheckNeed
    case authorized
    case denied
}

@MainActor
final class ViewModel: MVIContainer<ViewIntent, ViewState, FeatureEffect> {
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func send(_ intent: ViewIntent) {
        switch intent {
        case .onAppear:
            Task(priority: .high) {
                do {
                    let result = try await checkAndAuthorize()
                    emit(.updateViewState(result))
                } catch {
                    print(error.localizedDescription)
                    emit(.showToast("Error - \(error.localizedDescription)"))
                }
            }
            
        case let .upDateScheduleDate(date):
            setState { state in
                state.scheduleDate = date
            }
            emit(.showToast(dateFormatter.string(from: date)))
            
        case let .alertIsPresented(isPresented):
            setState { state in
                state.alertIsPresented = isPresented
            }
            
        case let .showAlert(text):
            emit(.showToast(text))
        }
    }
    
    override func emit(_ effect: FeatureEffect) {
        switch effect {
        case .updateViewState(let bool):
            setState { state in
                state.isAuth = bool
            }
        case .showToast(let string):
            setState { state in
                state.alertIsPresented = true
                state.alertMessage = string
            }
        }
    }
}

extension ViewModel {
    private func checkAndAuthorize() async throws -> Bool {
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
        
        return currentValue
    }
}

