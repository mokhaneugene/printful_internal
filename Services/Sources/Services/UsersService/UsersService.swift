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
    func getUsersUpdates() -> AnyPublisher<[UserModel], TCPError>
}

final public class UsersService: UsersServiceProtocol {

    // MARK: - Dependencies
    
    public struct Dependencies {
        public let tcpService: TCPServiceProtocol
    }

    // MARK: - Private properties

    private let dependencies: Dependencies

    private var userModels: [UserModel] = []
    private var modelsSubject = PassthroughSubject<[UserModel], TCPError>()
    private var updatesSubject = PassthroughSubject<[UserModel], TCPError>()

    // MARK: - Init

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Public methods

    public func getUserModels(for email: String) -> AnyPublisher<[UserModel], TCPError> {
        defer {
            setupUserModels(for: email)
        }
        return modelsSubject.eraseToAnyPublisher()
    }

    public func getUsersUpdates() -> AnyPublisher<[UserModel], TCPError> {
        defer {
            updateUserModels()
        }
        return updatesSubject.eraseToAnyPublisher()
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
                    self?.modelsSubject.send(completion: .finished)
                case .success(let models):
                    self?.userModels = models
                    self?.modelsSubject.send(models)
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
                    self.updatesSubject.send(completion: .failure(error))
                case .success(let models):
                    let userModels = models.compactMap({ self.updateUserModel(with: $0) })
                    self.updatesSubject.send(userModels)
                }
            }
        )
    }

    func updateUserModel(with model: UserModel) -> UserModel? {
        guard let userModel = userModels.first(where: { $0.id == model.id }) else { return nil }

        if model.latitude != userModel.latitude {
            return model
        }
        if model.longitude != userModel.longitude {
            return model
        }

        return nil
    }
}
