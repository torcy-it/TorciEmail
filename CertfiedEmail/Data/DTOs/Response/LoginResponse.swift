//
//  LoginResponse.swift
//  CertfiedEmail
//
//  DTO risposta login.
//


/// Risposta autenticazione contenente token JWT.
struct LoginResponse: Codable {
    let token: String
}