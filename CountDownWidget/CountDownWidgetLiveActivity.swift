//
//  CountDownWidgetLiveActivity.swift
//  CountDownWidget
//
//  Created by Jae hyung Kim on 12/15/25.
//

//import ActivityKit
import WidgetKit
import SwiftUI
import AlarmKit
import AppIntents


struct CountDownWidgetLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        return ActivityConfiguration(for: AlarmAttributes<MyAlarmMetaData>.self) { context in
            // Lock screen/banner UI goes here
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 0) {
                        LockScreenContentView(attributes: context.attributes, state: context.state)
                        Spacer()
                        setTrailingButton(state: context.state)
                    }
                }
                .lineLimit(1)
                
            }
            .padding(.all, 8)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    alarmTitle(attributes: context.attributes, state: context.state)
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    getIcon(attributes: context.attributes)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center, spacing: 8) {
                        countdownView(state: context.state, maxWidth: .infinity, align: .center)
                        setTrailingButton(state: context.state)
                    }
                }
            } compactLeading: {
                alarmTitle(attributes: context.attributes, state: context.state)
            } compactTrailing: {
                getIcon(attributes: context.attributes)
            } minimal: {
                Text("MinimalContent")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

// MARK: - Common UI
extension CountDownWidgetLiveActivity {
    private func setTrailingButton(
        state: AlarmPresentationState
    ) -> some View {
        return HStack(spacing: 8) {
            // MARK: Not Work cus Can't Touch Button
//            Button {
//                do {
//                    if let alarmID = UUID(uuidString: state.alarmID.uuidString) {
//                        try AlarmManager.shared.cancel(id: alarmID)
//                    }
//                    print("tapped")
//                } catch {
//                    print(error)
//                }
//            } label: {
//                Text("Stop")
//            }
//            .tint(.orange)
            
            // MARK: AppIntent Button is Work.
            Button(intent: AlarmActionIntent(id: state.alarmID, isCancelled: true, isResumed: false)) {
                Image(systemName: "xmark")
            }
            .tint(.orange)
            
            if case .paused = state.mode {
                Button(intent: AlarmActionIntent(id: state.alarmID, isCancelled: false, isResumed: true)) {
                    Image(systemName: "play.fill")
                }
            } else {
                Button(intent: AlarmActionIntent(id: state.alarmID, isCancelled: false, isResumed: false)) {
                    Text("pause")
                }
                .tint(.red)
            }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .font(.title)
    }
}

// MARK: - Lock Screen UI
extension CountDownWidgetLiveActivity {
    /// Lock Screen UI
    /// - Parameters:
    ///   - attributes: need MyAlarmMetaData struct
    ///   - state: AlarmPresentationState
    ///   - alert: Alert Info
    /// - Returns: View
    private func LockScreenContentView(
        attributes: AlarmAttributes<MyAlarmMetaData>,
        state: AlarmPresentationState
    ) -> some View {
        return VStack {
            HStack(alignment: .center) {
                alarmTitle(attributes: attributes, state: state)
                
                // MARK: - MetaData 를 통해 부모 앱에게서 정보를 가져옵니다.
                getIcon(attributes: attributes)
                
                if case let .alert(alert) = state.mode {
                    Text("\(alert.time.hour):\(alert.time.minute)")
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .padding(.trailing, 6)
                } else {
                    countdownView(state: state, maxWidth: 120)
                }
            }
        }
    }
    
    func alarmTitle(attributes: AlarmAttributes<MyAlarmMetaData>, state: AlarmPresentationState) -> some View {
        let title: LocalizedStringResource? = switch state.mode {
        case .countdown:
            attributes.presentation.countdown?.title
        case .paused:
            attributes.presentation.paused?.title
        default:
            nil
        }
        
        return Text(title ?? "")
            .font(.title3)
            .lineLimit(1)
            .fontWeight(.semibold)
    }
    

    func getIcon(attributes: AlarmAttributes<MyAlarmMetaData>) -> some View {
        Group {
            if let icon = attributes.metadata?.method?.icon {
                Image(systemName: icon)
            } else {
                EmptyView()
            }
        }
    }
    
    func countdownView(state: AlarmPresentationState, maxWidth: CGFloat = .infinity, align: TextAlignment = .leading) -> some View {
        Group {
            switch state.mode {
            case .countdown(let countdown):
                Text(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
                    
            case .paused(let state):
                let remaining = Duration.seconds(state.totalCountdownDuration - state.previouslyElapsedDuration)
                let pattern: Duration.TimeFormatStyle.Pattern = remaining > .seconds(60 * 60) ? .hourMinuteSecond : .minuteSecond
                Text(remaining.formatted(.time(pattern: pattern)))
                    
            default:
                EmptyView()
            }
        }
        .lineLimit(1)
        .multilineTextAlignment(align)
    }
}
