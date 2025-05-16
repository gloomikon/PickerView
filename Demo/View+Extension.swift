import SwiftUI

extension View {

    @ViewBuilder
    func numberTransition<Number: Numeric & Hashable>(value: Number) -> some View {
        if #available(iOS 17.0, *) {
            if let value = value as? Double {
                contentTransition(.numericText(value: value))
            } else if let value = value as? (any BinaryInteger) {
                contentTransition(.numericText(value: Double(value)))
            } else {
                transitUpdate(id: value)
            }
        } else {
            transitUpdate(id: value)
        }
    }

    private func transitUpdate<Number: Numeric & Hashable>(id: Number) -> some View {
        self.id(id)
            .transition(.asymmetric(
                insertion: .offset(y: -12).combined(with: .opacity),
                removal: .offset(y: 12).combined(with: .opacity)
            ))
    }
}
