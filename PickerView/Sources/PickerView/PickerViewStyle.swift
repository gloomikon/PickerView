import SwiftUI

public protocol PickerViewStyle {

    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        forStringRepresentation string: String,
        reusing view: UIView?
    ) -> UIView

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
}

public struct DefaultPickerViewStyle: PickerViewStyle {

    public func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        forStringRepresentation string: String,
        reusing view: UIView?
    ) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.text = string
        return label
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}

public extension PickerViewStyle where Self == DefaultPickerViewStyle {

    static var `default`: Self { Self() }
}

public struct PrimaryPickerViewStyle: PickerViewStyle {

    let tintColor: UIColor

    public func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        forStringRepresentation string: String,
        reusing view: UIView?
    ) -> UIView {
        let isSelected = pickerView.selectedRow(inComponent: component) == row

        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.text = string
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = isSelected ? tintColor : .gray
        return label
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(component)
    }
}

public extension PickerViewStyle where Self == PrimaryPickerViewStyle {

    static var primary: Self {
        Self(tintColor: .green)
    }

    static func primary(tintColor: UIColor) -> Self {
        Self(tintColor: tintColor)
    }
}

public extension EnvironmentValues {
    @Entry var pickerViewStyle: PickerViewStyle = DefaultPickerViewStyle()
}

public extension View {

    func pickerViewStyle(_ style: PickerViewStyle) -> some View {
        environment(\.pickerViewStyle, style)
    }
}
