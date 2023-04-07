//
//  TCPService.swift
//  Services
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation
import Socket

final public class TCPService {

    // MARK: - Constants

    private enum Constants {
        static let host: String = "ios-test.printful.lv"
        static let port: Int32 = 6111
        static let bufferSize: Int = 4096
        static let timeout: UInt = 5 // Seconds

        static let emailOccurrences: String = "###"
        static let authorizeCommand: String = "AUTHORIZE \(emailOccurrences)\n"
    }

    // MARK: - Private

    private let queue = DispatchQueue(label: "com.TCPService", qos: .userInitiated, target: .global(qos: .userInitiated))
    private var isConnectingEnabled: Bool = false
    private var socket: Socket?

    // MARK: - Init

    public init() {

    }

    // MARK: - Public methods

    public func closeSocket() {
        isConnectingEnabled = false
        socket?.close()
        socket = nil
    }

    public func run(with email: String, completion: @escaping (Result<String, TCPError>) -> Void) {
        isConnectingEnabled = true
        let command = Constants.authorizeCommand.replacingOccurrences(of: Constants.emailOccurrences, with: email)

        queue.async { [weak self] in
            do {
                let socket = try Socket.create()
                self?.socket = socket

                try socket.connect(to: Constants.host, port: Constants.port)
                try socket.write(from: command)
                try socket.setReadTimeout(value: Constants.timeout)

                while self?.isConnectingEnabled ?? false {
                    var readData = Data(capacity: Constants.bufferSize)
                    let bytesRead = try socket.read(into: &readData)

                    guard bytesRead > .zero, let response = String(data: readData, encoding: .utf8) else {
                        completion(.failure(.emptyResponse))
                        continue
                    }

                    completion(.success(response))
                }
            } catch {
                completion(.failure(.uknown))
                self?.closeSocket()
            }
        }
    }
}
