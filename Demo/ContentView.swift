import PickerView
import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = ViewModel()

    private var title: some View {
        Text("What is your **height?**")
            .font(.system(size: 28))
    }

    @ViewBuilder
    private var imperialMajorView: some View {
        if let major = viewModel.heightMajor {
            Text(verbatim: "\(major)")
                .monospacedDigit()
                .numberTransition(value: major)
                .animation(.easeInOut(duration: 0.2), value: major)
        } else {
            Text(verbatim: "0")
                .hidden()
        }
    }

    @ViewBuilder
    private var imperialMinorView: some View {
        if let minor = viewModel.heightMinor {
            Text(verbatim: "\(minor)")
                .monospacedDigit()
                .numberTransition(value: minor)
                .animation(.easeInOut(duration: 0.2), value: minor)
        } else {
            Text(verbatim: "0")
                .hidden()
        }
    }

    private var imperialView: some View {
        HStack(alignment: .lastTextBaseline) {
            imperialMajorView
                .frame(width: 34)

            Text(verbatim: "ft")
                .font(.system(size: 30))

            imperialMinorView
                .frame(width: 68, alignment: .trailing)

            Text(verbatim: "in")
                .font(.system(size: 30))
        }
    }

    @ViewBuilder
    private var metricsValueView: some View {
        if let heightMajor = viewModel.heightMajor,
            let heightMinor = viewModel.heightMinor {
                let value = Double(heightMajor) + Double(heightMinor) / 10
                Text(verbatim: String(format: "%.1f", value))
                    .monospacedDigit()
                    .numberTransition(value: value)
                    .animation(.easeInOut(duration: 0.2), value: value)
            } else {
                Text(verbatim: "0")
                    .hidden()
            }
    }

    private var metricsView: some View {
        HStack(alignment: .lastTextBaseline) {
            metricsValueView
                .frame(width: 145)

            Text("cm")
                .font(.system(size: 30))
        }
    }

    var body: some View {
        VStack {
            title
            HStack {
                switch viewModel.measurementSystem {
                case .imperial:
                    imperialView
                case .metric:
                    metricsView
                }
            }
            .font(.system(size: 48))
            .padding(.top, 34)

            Spacer()

            PickerView {
                PickerComponent(
                    elements: viewModel.majorAllowedComponents,
                    selection: $viewModel.heightMajor,
                    initialValue: viewModel.initialMajor
                )
                PickerComponent(
                    elements: [","],
                    selection: .constant(nil),
                    initialValue: nil
                )
                PickerComponent(
                    elements: viewModel.minorAllowedComponents,
                    selection: $viewModel.heightMinor,
                    initialValue: viewModel.initialMinor
                )
                PickerComponent(
                    elements: viewModel.measurementSystemComponents,
                    selection: $viewModel.measurementSystem
                ) { system in
                    system.height.rawValue
                }
            }
            .pickerViewStyle(.primary(tintColor: .green))
        }
        .padding(.vertical, 64)
    }
}
