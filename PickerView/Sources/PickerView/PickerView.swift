import SwiftUI

public protocol AnyPickerComponentProtocol {
    var elements: [AnyHashable] { get }
    var selection: Binding<AnyHashable?> { get }
    var initialValue: AnyHashable? { get }
    var stringBuilder: (AnyHashable) -> String { get }
}

public struct PickerView: UIViewRepresentable {

    @Environment(\.pickerViewStyle) var pickerViewStyle

    private let components: [AnyPickerComponentProtocol]

    public init(
        @PickerComponentBuilder components: () -> [AnyPickerComponentProtocol]
    ) {
        self.components = components()
    }

    public func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()

        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator

        for (componentIndex, component) in components.enumerated() {
            guard
                let selection = component.selection.wrappedValue ?? component.initialValue,
                let rowIndex = component.elements.firstIndex(where: { $0 == selection }) else {
                continue
            }
            picker.selectRow(rowIndex, inComponent: componentIndex, animated: false)
        }

        return picker
    }

    public func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self
        DispatchQueue.main.async {
            picker.reloadAllComponents()
            for (componentIndex, component) in components.enumerated() {
                guard let selection = component.selection.wrappedValue ?? component.initialValue,
                      let rowIndex = component.elements.firstIndex(where: { $0 == selection }) else {
                    continue
                }

                guard picker.numberOfComponents > componentIndex,
                      picker.numberOfRows(inComponent: componentIndex) > rowIndex else {
                    return
                }
                picker.selectRow(rowIndex, inComponent: componentIndex, animated: true)
                picker.reloadComponent(componentIndex)
            }
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

        var parent: PickerView

        init(parent: PickerView) {
            self.parent = parent
        }

        // MARK: - UIPickerViewDataSource

        public func numberOfComponents(in pickerView: UIPickerView) -> Int {
            parent.components.count
        }

        public func pickerView(
            _ pickerView: UIPickerView,
            numberOfRowsInComponent component: Int
        ) -> Int {
            parent.components[safe: component]?.elements.count ?? 0
        }

        // MARK: - UIPickerViewDelegate

        public func pickerView(
            _ pickerView: UIPickerView,
            viewForRow row: Int,
            forComponent component: Int,
            reusing view: UIView?
        ) -> UIView {
            guard let pickerComponent = parent.components[safe: component],
                  let element = pickerComponent.elements[safe: row] else {
                return (view ?? UIView())
            }
            return parent.pickerViewStyle.pickerView(
                pickerView,
                viewForRow: row,
                forComponent: component,
                forStringRepresentation: pickerComponent.stringBuilder(element),
                reusing: view
            )
        }

        public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.pickerViewStyle.pickerView(pickerView, didSelectRow: row, inComponent: component)
            let selection = parent.components[component].selection
            let value = parent.components[component].elements[row]
            selection.wrappedValue = value
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
