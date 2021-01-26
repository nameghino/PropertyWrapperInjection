//
//  ViewController.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import UIKit

class TimeViewModel {
    @Injected<TimeProviderProtocol>
    var timeProvider

    @Injected<TimeProviderProtocol>(label: "my birthday")
    var nico

    var labelText: String = "* not yet set *"

    func update(nico: Bool = false) {
        if nico {
            self.labelText = "\(self.nico.now)"
        } else {
            self.labelText = "\(self.timeProvider.now)"
        }
    }
}

class ViewController: UIViewController {

    private func play(viewModel: TimeViewModel) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

