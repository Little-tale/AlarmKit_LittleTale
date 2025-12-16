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


struct CountDownWidgetLiveActivity: Widget {
    
    @State private var dateFormatter: DateComponentsFormatter = {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.minute, .second]
        dateFormatter.unitsStyle = .positional
        dateFormatter.zeroFormattingBehavior = .pad
        return dateFormatter
    }()
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: AlarmAttributes<CountDownAttribute>.self) { context in
            // Lock screen/banner UI goes here
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    switch context.state.mode {
                    case let .countdown(countDown):
                        Group {
                            Text(context.attributes.presentation.countdown?.title ?? "")
                                .font(.title3)
                            
                            Text(countDown.fireDate, style: .timer)
                                .font(.title2)
                        }
                    case let .paused(paused):
                        Group {
                            Text(context.attributes.presentation.countdown?.title ?? "")
                                .font(.title3)
                            
                            Text(dateFormatter.string(from: paused.totalCountdownDuration - paused.previouslyElapsedDuration ) ?? "00:00")
                                .font(.title2)
                        }
                    case .alert(_):
                        Text(context.attributes.presentation.alert.title)
                            .font(.title3)
                        
                        Text("00:00")
                            .font(.title2)
                    @unknown default:
                        fatalError()
                    }
                }
                .lineLimit(1)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 8) {
                    Button {
                        
                    } label: {
                        Text("Cancel")
                    }
                    .tint(.orange)

                    Button {
                        
                    } label: {
                        Text("?")
                    }
                    .tint(.red)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .font(.title)
            }
            .padding(.all, 8)
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom ")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("MinimalContent")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

#if DEBUG
#Preview(as: .systemMedium) {
    CountDownWidgetLiveActivity()
} timeline: {
    let date = Date()
    SimpleEntry(date: date, emoji: "")
}
#endif
