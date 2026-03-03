//
//  LoginRequest.swift
//  CertfiedEmail
//
//  DTO richiesta login verso backend Vapor.
//


/// Payload di autenticazione username/password.
struct LoginRequest: Codable {
    let username: String
    let password: String
}