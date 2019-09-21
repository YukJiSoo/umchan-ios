//
//  Error.swift
//  Umchan
//
//  Created by 육지수 on 9/13/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import Foundation

enum UserAPIError: Error {
    case user(String)
}

enum AuthAPIError: Error {
    case login(String)
    case register(String)
}

enum RunningAPIError: Error {
    case createRunning(String)
    case runningList(String)
    case running(String)
}

enum CrewAPIError: Error {
    case createCrew(String)
}

enum KeychainError: Error {
    case failToSave(String)
}
