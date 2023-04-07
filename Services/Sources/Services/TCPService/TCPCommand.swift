//
//  TCPCommand.swift
//  Services
//
//  Created by Eugene Mokhan on 07/04/2023.
//

import Foundation

enum TCPCommand: String {
    case authorize
    case userlist
    case update

    var value: String {
        return rawValue.uppercased() + " "
    }

    var parametersCount: Int {
        switch self {
        case .authorize: return .zero
        case .userlist: return 5
        case .update: return 3
        }
    }

    var separator: String {
        switch self {
        case .authorize: return ""
        case .userlist: return ";"
        case .update: return "\n"
        }
    }
}
