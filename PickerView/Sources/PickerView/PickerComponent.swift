import SwiftUI

public protocol PickerComponentProtocol<Element> {
    associatedtype Element: Hashable

    var elements: [Element] { get }
    var selection: Binding<Element?> { get }
    var initialValue: Element? { get }
    var stringBuilder: (Element) -> String { get }
}

public struct PickerComponent<Element: Hashable>: PickerComponentProtocol {

    public let elements: [Element]
    public let selection: Binding<Element?>
    public let initialValue: Element?
    public let stringBuilder: (Element) -> String

    public init(
        elements: [Element],
        selection: Binding<Element?>,
        initialValue: Element?,
        stringBuilder: @escaping (Element) -> String = { element in
            String(describing: element)
        }
    ) {
        self.elements = elements
        self.selection = selection
        self.initialValue = initialValue
        self.stringBuilder = stringBuilder
    }

    public init(
        elements: [Element],
        selection: Binding<Element>,
        stringBuilder: @escaping (Element) -> String = { element in
            String(describing: element)
        }
    ) {
        self.elements = elements
        self.selection = .init(get: {
            selection.wrappedValue
        }, set: { newValue in
            if let newValue {
                selection.wrappedValue = newValue
            }
        })
        self.initialValue = selection.wrappedValue
        self.stringBuilder = stringBuilder
    }
}
