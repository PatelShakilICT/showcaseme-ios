//
//  Login.swift
//  showcaseme
//
//  Created by MuhammadShakil Patel on 07/04/25.
//

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse<T : Codable>: Codable {
    let message: String
    let status : Bool
    let data : T
}

struct UserData : Codable{
    let token : String
}
