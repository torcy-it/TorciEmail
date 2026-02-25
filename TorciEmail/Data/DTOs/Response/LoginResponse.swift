//
//  LoginResponse.swift
//  TorciEmail
//
//  DTO risposta login.
//


/// Risposta autenticazione contenente token JWT.
struct LoginResponse: Codable {
    let token: String
}