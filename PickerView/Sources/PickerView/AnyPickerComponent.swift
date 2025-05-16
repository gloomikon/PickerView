import SwiftUI

@resultBuilder
public enum PickerComponentBuilder {

    public static func buildBlock(_ components: any PickerComponentProtocol...) -> [AnyPickerComponentProtocol] {
        components.map { AnyPickerComponent($0) }
    }
}

private struct AnyPickerComponent: AnyPickerComponentProtocol {

    let elements: [AnyHashable]
    let selection: Binding<AnyHashable?>
    let initialValue: AnyHashable?
    let stringBuilder: (AnyHashable) -> String

    init<PC: PickerComponentProtocol>(_ component: PC) {
        self.elements = component.elements
        self.selection = .init(get: {
            component.selection.wrappedValue
        }, set: { newValue in
            component.selection.wrappedValue = newValue as? PC.Element
        })
        self.initialValue = component.initialValue
        self.stringBuilder = { element in
            guard let element = element as? PC.Element else {
                return String(describing: element)
            }
            return component.stringBuilder(element)
        }
    }
}
