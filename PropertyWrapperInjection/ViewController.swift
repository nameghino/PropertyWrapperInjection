//
//  ViewController.swift
//  PropertyWrapperInjection
//
//  Created by Nico Ameghino on 25/01/2021.
//

import UIKit

class TimeViewModel {
    private weak var timeProvider: TimeProviderProtocol!

    init(container: ComponentContainer) throws {
        self.timeProvider = try container.resolve(type: TimeProviderProtocol.self)
    }

    var labelText: String = "* not yet set *"

    func update() {
        self.labelText = "\(timeProvider.now)"
    }
}

class ViewController: UIViewController {

    private func play(viewModel: TimeViewModel) {
        print(viewModel.labelText)
        viewModel.update()
        print(viewModel.labelText)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

