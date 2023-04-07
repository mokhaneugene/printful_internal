//
//  TCPService.swift
//  Services
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation
import Socket

public protocol TCPServiceHolder {
    var tcpService: TCPServiceProtocol { get }
}

public protocol TCPServiceProtocol {
    func closeSocket()
    func run(with email: String, completion: @escaping (Result<[UserModel], TCPError>) -> Void)
    func getAnyUpdates(completion: @escaping (Result<[UserModel], TCPError>) -> Void)
}

final public class TCPService: TCPServiceProtocol {

    // MARK: - Constants

    private enum Constants {
        static let host: String = ProcessInfo.processInfo.environment["HOST_URL"] ?? ""
        static let port: Int32 = 6111
        static let bufferSize: Int = 4096
        static let timeout: UInt = 5 // Seconds
    }

    // MARK: - Private

    private let queue = DispatchQueue(label: "com.TCPService", qos: .userInitiated, target: .global(qos: .userInitiated))
    private var isUserModelExist: Bool = false
    private var isShouldGetUpdates: Bool = true
    private var socket: Socket?

    // MARK: - Init

    public init() { }

    // MARK: - Public methods

    public func closeSocket() {
        isShouldGetUpdates = false
        socket?.close()
        socket = nil
    }

    public func run(with email: String, completion: @escaping (Result<[UserModel], TCPError>) -> Void) {
        let command = TCPCommand.authorize.value + email + "\n"
        
        queue.async { [weak self] in
            guard let self = self else { return }

            do {
                let socket = try Socket.create()
                self.socket = socket

                try socket.connect(to: Constants.host, port: Constants.port)
                try socket.write(from: command)
                try socket.setReadTimeout(value: Constants.timeout)

                // Can be edit to waiting the new users
                while !self.isUserModelExist {
                    guard let userModels = try self.getUserModels(for: .userlist) else { continue }

                    completion(.success(userModels))
                    self.isUserModelExist = true
                }
            } catch {
                self.closeSocket()
                if let error = error as? TCPError {
                    completion(.failure(error))
                }
                completion(.failure(.uknown))
            }
        }
    }

    public func getAnyUpdates(completion: @escaping (Result<[UserModel], TCPError>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }

            do {
                while self.isShouldGetUpdates {
                    guard let userModels = try self.getUserModels(for: .update) else { continue }
                    
                    completion(.success(userModels))
                }
            } catch {
                self.closeSocket()
                if let error = error as? TCPError {
                    completion(.failure(error))
                }
                completion(.failure(.uknown))
            }
        }
    }
}

// MARK: - Private

private extension TCPService {
    func getUserModels(for command: TCPCommand) throws -> [UserModel]? {
        var readData = Data(capacity: Constants.bufferSize)
        let bytesRead = try? socket?.read(into: &readData)

        guard bytesRead ?? .zero > .zero,
              let response = String(data: readData, encoding: .utf8),
              response.contains(command.value) else {
            return nil
        }

        let userlist = response.replacingOccurrences(of: command.value, with: "")
        let userStrings = userlist.components(separatedBy: command.separator)

        var userModels: [UserModel] = []
        for userString in userStrings {
            let component = userString.components(separatedBy: ",")
            if command == .userlist, component.count == command.parametersCount {
                let userModel = UserModel(id: component[0],
                                          name: component[1],
                                          image: component[2],
                                          latitude: component[3],
                                          longitude: component[4])
                userModels.append(userModel)
            }
            if command == .update, component.count == command.parametersCount {
                let userModel = UserModel(id: component[0],
                                          latitude: component[1],
                                          longitude: component[2])
                userModels.append(userModel)
            }
        }
        return userModels
    }
}
