//
//  UsersService.swift
//  Services
//
//  Created by Eugene Mokhan on 08/04/2023.
//

import Foundation
import Combine

public protocol UsersServiceHolder {
    var usersService: UsersServiceProtocol { get }
}

public protocol UsersServiceProtocol {
    func getUserModels(for email: String) -> AnyPublisher<[UserModel], TCPError>
}

final public class UsersService: UsersServiceProtocol {

    // MARK: - Dependencies
    
    public struct Dependencies {
        public let tcpService: TCPServiceProtocol
    }

    // MARK: - Private properties

    private let dependencies: Dependencies

    private var userModels: [UserModel] = []
    private var userModelsSubject = PassthroughSubject<[UserModel], TCPError>()

    // MARK: - Init

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    public func getUserModels(for email: String) -> AnyPublisher<[UserModel], TCPError> {
        defer {
            setupUserModels(for: email)
            updateUserModels()
        }
        return userModelsSubject.eraseToAnyPublisher()
    }
}

// MARK: - Private methods

private extension UsersService {
    func setupUserModels(for email: String) {
        dependencies.tcpService.run(
            with: email,
            completion: { [weak self] result in
                switch result {
                case .failure(_):
                    self?.userModelsSubject.send(completion: .finished)
                case .success(let models):
                    self?.userModels = models
                    self?.userModelsSubject.send(models)
                }
            }
        )
    }

    func updateUserModels() {
        dependencies.tcpService.getAnyUpdates(
            completion: { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    self.userModelsSubject.send(completion: .failure(error))
                case .success(let models):
                    models.forEach({ self.updateUserModel(with: $0) })
                    self.userModelsSubject.send(self.userModels)
                }
            }
        )
    }

    func updateUserModel(with model: UserModel) {
        guard let userModel = userModels.first(where: { $0.id == model.id }),
              let index = userModels.firstIndex(where: { $0.id == model.id }) else {
            return
        }

        if model.latitude != userModel.latitude {
            userModels[index].latitude = model.latitude
        }
        if model.longitude != userModel.longitude {
            userModels[index].longitude = model.longitude
        }
    }
}
