//
//  ViewController.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 04/04/2023.
//

import UIKit
import SnapKit
import Services

class ViewController: UIViewController {

    // MARK: - Private properties

    private let tcpService = TCPService()
    private let button = UIButton()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupItems()
        tcpService.run(
            with: "mokhaneugene",
            completion: { result in
                switch result {
                case .failure(let error):
                    guard error != .emptyResponse else { return }
                    print("error: \(error)")
                case .success(let response):
                    print("response: \(response)")
                }
            }
        )
    }
}

// MARK: - Private

private extension ViewController {
    func setupItems() {
        view.backgroundColor = .white
        setupButton()
    }

    func setupButton() {
        button.backgroundColor = .red
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(100.0)
            make.height.equalTo(50.0)
        }
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @objc func didTapButton() {
        print("didTapButton")
        tcpService.closeSocket()
    }
}
