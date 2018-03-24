/**
 *  https://github.com/tadija/AEViewModel
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import AEViewModel

struct SettingsViewModel: ViewModel {
    struct Id {
        static let profile = "profile"
        static let airplane = "airplane"
        static let wifi = "wifi"
        static let bluetooth = "bluetooth"
        static let cellular = "cellular"
        static let hotspot = "hotspot"
        static let vpn = "vpn"
        static let carrier = "carrier"
        
        struct Wifi {
            static let wifiSwitch = "wifiSwitch"
            static let wifiNetwork = "wifiNetwork"
            static let joinNetworksSwitch = "joinNetworksSwitch"
        }
    }

    var title: String?
    var sections: [Section]

    init() {
        do {
            let url = Bundle.main.url(forResource: "settings", withExtension: "json")!
            let data = try Data(contentsOf: url)
            let viewModel = try BasicViewModel(with: data)
            title = viewModel.title
            sections = viewModel.sections
        } catch {
            debugPrint(error)
            fatalError("Failed to load settings.json.")
        }
    }
}
