//
//  AuthService.swift
//  Umchan
//
//  Created by 육지수 on 9/13/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import Foundation

typealias AuthCompletion = (_ Response: Result<Bool, AuthAPIError>) -> Void

protocol AuthServiceType {
    
    var accessToken: String? { get }
    
    func authorize(email: String, password: String, completion: @escaping AuthCompletion)
}

final class AuthService: AuthServiceType {
    
    // MARK: Singleton
    static let shared = AuthService()
    
    // MARK: Properties
    var accessToken: String?
    
    // MARK: Func
    func authorize(email: String, password: String, completion: @escaping AuthCompletion) {
        
        let loginInput = LoginInput(email: email, password: password)
        Apollo.shared.client.perform(mutation: LoginMutation(account: loginInput)) { result in
            
            guard
                let data = try? result.get().data,
                let code = data.login?.code,
                let message = data.login?.message
                else {
                    completion(.failure(.login("Internal server error")))
                    return
            }
            
            // check reseponse HTTP code
            guard code.isSuccessfulResponse else {
                completion(.failure(.login(message)))
                return
            }
            
            // response from server
            guard let token = data.login?.token, let value = data.login?.user?.jsonObject else {
                completion(.failure(.login("Fail Convert json data")))
                return
            }

            // save token in Keychain
            guard Keychain.saveValue(token, for: "access_token") else {
                completion(.failure(.login("KeychainError.failToSave")))
                return
            }
            self.accessToken = token
            
            // response from server
            UserDataService.shared.saveUserData(value) { (result) in
                switch result {
                case .success(_):
                    completion(.success(true))

                case .failure(KeychainError.failToSave):
                    completion(.failure(.login("KeychainError.failToSave")))
                }
            }
        }
    }
    
    func register(email: String, password: String, name: String, nickname: String, district: String, completion: @escaping AuthCompletion) {
        
        let registerInput = RegisterUserInput(email: email, password: password, name: name, nickname: nickname, district: district)
        
        Apollo.shared.client.perform(mutation: RegisterUserMutation(user: registerInput)) { result in
            
            guard
                let data = try? result.get().data,
                let code = data.register?.code,
                let message = data.register?.message
                else {
                    completion(.failure(.register("Internal server error")))
                    return
            }
            
            // check reseponse HTTP code
            guard code.isSuccessfulResponse else {
                completion(.failure(.register(message)))
                return
            }
            
            // response from server
            guard let token = data.register?.token else {
                completion(.failure(.login("Fail Convert json data")))
                return
            }

            // save token in Keychain
            guard Keychain.saveValue(token, for: "access_token") else {
                completion(.failure(.login("KeychainError.failToSave")))
                return
            }
            self.accessToken = token

            UserDataService.shared.setUser(user: User(id: "id", name: name, nickname: nickname, district: district))

            // response from server
            completion(.success(true))
        }
    }
}
