// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SwiftUI

// 🙏 https://www.swiftbysundell.com/basics/combine/
class YAPublisher<T>: ObservableObject {
    var publisher: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    var binding: Binding<T> {
        Binding(get: { self.value }, set: { self.value = $0 })
    }

    var value: T {
        didSet { subject.send(value) }
    }

    init(_ value: T) { self.value = value }

    private let subject = PassthroughSubject<T, Never>()
}
