//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Глеб Хамин on 09.10.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    
    //MARK: - Private Properties
    
    private let networkClient: NetworkRouting
    
    //MARK: - Initializators
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    //MARK: - URL
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://api.kinopoisk.dev/v1.4/movie") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    //MARK: - URLRequest

    private var mostPopularMoviesRequest: URLRequest {
        var components = URLComponents(url: mostPopularMoviesUrl, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "page", value: "1"),
          URLQueryItem(name: "limit", value: "100"),
          URLQueryItem(name: "selectFields", value: "id"),
          URLQueryItem(name: "selectFields", value: "name"),
          URLQueryItem(name: "selectFields", value: "poster"),
          URLQueryItem(name: "selectFields", value: "year"),
          URLQueryItem(name: "selectFields", value: "rating"),
          URLQueryItem(name: "lists", value: "top250"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "X-API-KEY": "KCTM2SY-JK04VQ9-GZT96ZJ-17JEX9Z"
        ]
        return request
    }

    //MARK: - Public Methods
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(request: mostPopularMoviesRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
