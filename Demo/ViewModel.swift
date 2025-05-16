import Combine
import Foundation

enum MeasurementSystem: Hashable {
    case imperial
    case metric

    var height: HeightUnit {
        switch self {
        case .imperial:
                .inches
        case .metric:
                .cm
        }
    }

    var other: Self {
        switch self {
        case .imperial:
                .metric
        case .metric:
                .imperial
        }
    }
}

struct Height {
    let major: Int
    let minor: Int
    private let system: MeasurementSystem

    private var valueInCm: Double {
        switch system {
        case .metric:
            return Double(major) + Double(minor) / 10.0  // cm
        case .imperial:
            let totalInches = Double(major * 12 + minor)
            return totalInches * 2.54  // to cm
        }
    }

    init(major: Int, minor: Int, system: MeasurementSystem) {
        self.major = major
        self.minor = minor
        self.system = system
    }

    func convert(to system: MeasurementSystem) -> Height {
        switch system {
        case .metric:
            let totalCm = valueInCm
            let major = Int(totalCm)
            let minor = Int((totalCm - Double(major)) * 10)
            return Height(major: major, minor: minor, system: .metric)
        case .imperial:
            let totalInches = valueInCm / 2.54
            let feet = Int(totalInches) / 12
            let inches = Int(totalInches) % 12
            return Height(major: feet, minor: inches, system: .imperial)
        }
    }
}

enum HeightUnit: String {
    case cm
    case inches = "in"
}

class ViewModel: ObservableObject {

    private enum Constant {
        static func majorComponents(for system: MeasurementSystem) -> [Int] {
            switch system {
            case .imperial:
                imperialMajorAllowedComponents
            case .metric:
                metricMajorAllowedComponents
            }
        }

        static func minorComponents(for system: MeasurementSystem) -> [Int] {
            switch system {
            case .imperial:
                imperialMinorAllowedComponents
            case .metric:
                metricMinorAllowedComponents
            }
        }

        static func initialMajor(for system: MeasurementSystem) -> Int {
            switch system {
            case .imperial:
                imperialInitialMajor
            case .metric:
                metricInitialMajor
            }
        }

        static func initialMinor(for system: MeasurementSystem) -> Int {
            switch system {
            case .imperial:
                imperialInitialMinor
            case .metric:
                metricInitialMinor
            }
        }

        private static let metricMajorAllowedComponents: [Int] = Array(120...229)
        private static let metricMinorAllowedComponents: [Int] = Array(0...9)
        private static let metricInitialMajor = 175
        private static let metricInitialMinor = 0

        private static let imperialMajorAllowedComponents: [Int] = Array(4...7)
        private static let imperialMinorAllowedComponents: [Int] = Array(0...11)
        private static let imperialInitialMajor = 5
        private static let imperialInitialMinor = 9
    }

    @Published var majorAllowedComponents = Constant.majorComponents(for: .metric)
    @Published var heightMajor: Int?
    @Published var initialMajor = Constant.initialMajor(for: .metric)

    @Published var minorAllowedComponents = Constant.minorComponents(for: .metric)
    @Published var heightMinor: Int?
    @Published var initialMinor = Constant.initialMinor(for: .metric)

    let measurementSystemComponents: [MeasurementSystem] = [.imperial, .metric]

    @Published var measurementSystem: MeasurementSystem = .metric

    private var bag = Set<AnyCancellable>()

    init() {
        bind()
    }

    private func bind() {
        // User changed the major component.
        // If minor is not selected, preselect with default value to update the UI
        $heightMajor
            .first { $0 != nil }
            .filter { [unowned self] _ in
                heightMinor == nil
            }
            .map { [unowned self] _ in
                Constant.initialMinor(for: measurementSystem)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$heightMinor)

        // User changed the minor component.
        // If major is not selected, preselect with default value to update the UI
        $heightMinor
            .first { $0 != nil }
            .filter { [unowned self] _ in
                heightMajor == nil
            }
            .map { [unowned self] _ in
                Constant.initialMajor(for: measurementSystem)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$heightMajor)

        // User changes measurement system
        $measurementSystem
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] system in
                if heightMajor == nil, heightMinor == nil { // User didn't change his height before
                    updateAllowedComponents(for: system) // Just update allowed components values
                } else if let heightMajor, let heightMinor { // User has selected height
                    updateHeight(major: heightMajor, minor: heightMinor, to: system) // Recalculate height
                }
            }
            .store(in: &bag)
    }

    private func updateAllowedComponents(for system: MeasurementSystem) {
        switch system {
        case .imperial:
            (majorAllowedComponents, minorAllowedComponents) = (Constant.majorComponents(for: .imperial), Constant.minorComponents(for: .imperial))
        case .metric:
            (majorAllowedComponents, minorAllowedComponents) = (Constant.majorComponents(for: .metric), Constant.minorComponents(for: .metric))
        }

        self.initialMajor = Constant.initialMajor(for: system)
        self.initialMinor = Constant.initialMinor(for: system)
    }

    private func updateHeight(major: Int, minor: Int, to system: MeasurementSystem) {
        let height = Height(major: major, minor: minor, system: system.other)
        let convertedHeight = height.convert(to: system)

        majorAllowedComponents = Constant.majorComponents(for: system)
        minorAllowedComponents = Constant.minorComponents(for: system)

        let major = convertedHeight.major
        let minor = convertedHeight.minor

        if major > majorAllowedComponents.last! {
            (heightMajor, heightMinor) = (majorAllowedComponents.last, minorAllowedComponents.last)
        } else if major < majorAllowedComponents.first! {
            (heightMajor, heightMinor) = (majorAllowedComponents.first, minorAllowedComponents.first)
        } else {
            heightMajor = major
            heightMinor = minorAllowedComponents.contains(minor) ? minor : minorAllowedComponents.first
        }
    }
}
