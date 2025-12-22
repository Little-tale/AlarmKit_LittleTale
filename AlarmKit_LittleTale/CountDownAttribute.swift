//
//  CountDownAttribute.swift
//  AlarmKit_LittleTale
//
//  Created by Jae hyung Kim on 12/8/25.
//

import SwiftUI
import AlarmKit
import ActivityKit

/*
 ActivityAttributes
  - 잠금화면/다이나믹 아일랜드 - a lock screen/dynamic island
  - Live Activity가 표시할 정보를 정리하는 프로토콜 - Information that Live Activity will display
  
 ** example from Apple Docs **

 public import Foundation
 import ActivityKit


 struct PizzaDeliveryAttributes: ActivityAttributes {
     public typealias PizzaDeliveryStatus = ContentState


     public struct ContentState: Codable, Hashable {
         var driverName: String
         var deliveryTimer: ClosedRange<Date>
     }


     var numberOfPizzas: Int
     var totalAmount: String
     var orderNumber: String
 }
 
 다만 희한하게도 알람킷은 해당 방법으로 동작하는 방식이 아님.
 */
