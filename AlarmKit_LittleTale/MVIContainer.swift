//
//  MVIContainer.swift
//  AlarmKit_LittleTale
//
//  Created by Jae hyung Kim on 12/7/25.
//

import Foundation
import Combine

// MARK: - MVI Core Protocols

/// 사용자의 의도를 표현하는 타입  enum 으로 정의
public protocol MVIIntent { }

/// 화면에 표시되는 상태
public protocol MVIState: Equatable { }

/// 사이드 이펙트
public protocol MVIEffect { }

@MainActor
public class MVIContainer<Intent: MVIIntent, State: MVIState, Effect: MVIEffect>: ObservableObject {
    
    @Published public private(set) var state: State

    private let effectSubject = PassthroughSubject<Effect, Never>()
    
    public var effects: AnyPublisher<Effect, Never> { effectSubject.eraseToAnyPublisher() }

    private var cancellables = Set<AnyCancellable>()

    public init(initial state: State) {
        self.state = state
        bind()
    }

    /// 상태 바인딩이 필요할 때
    public func bind() { }

    /// Intent 처리 진입점
    public func send(_ intent: Intent) { }

    /// 상태  변경
    public func setState(_ reducer: (inout State) -> Void) {
        var next = state
        reducer(&next)
        if next != state { // Equatable 로 변경 여부 판단
            state = next
        }
    }

    /// 일회성 이펙트 전파
    public func emit(_ effect: Effect) {
        effectSubject.send(effect)
    }
    
    deinit {
        print(#file, #function, #line, "-deinit")
    }
}

// MARK: - 샘플 템플릿
public enum SampleIntent: MVIIntent {
    case onAppear
    case buttonTapped
}

public struct SampleState: MVIState {
    public var title: String = ""
    public var isLoading: Bool = false

    public init(title: String = "", isLoading: Bool = false) {
        self.title = title
        self.isLoading = isLoading
    }
}

public enum SampleEffect: MVIEffect {
    case showToast(String)
}

