//
//  MostPopularMavies.swift
//  MovieQuiz
//
//  Created by Глеб Хамин on 09.10.2023.
//

import Foundation

struct MostPopularMovies: Codable {
    let docs: [MostPopularMovie]
    let total: Int
    let limit: Int
    let page: Int
    let pages: Int
}

struct MostPopularMovie: Codable {
    let id: Int
    let name: String
    let year: Int
    let rating: Rating
    let poster: Poster
}

struct Rating: Codable {
    let kp: Double
}

struct Poster: Codable {
    let url: URL
}
