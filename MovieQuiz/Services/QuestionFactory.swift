//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Глеб Хамин on 09.10.2023.
//

import Foundation

final class QuestionFactoryImpl {

    //MARK: - Properties

    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var movieIndicesForQuestions: Set<Int> = []
    private var imageMovies: [Int:Data] = [:]
    private let serialQueue = DispatchQueue(label: "com.example.serialQueue")

    //MARK: - Init

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    private func safeSetImage(_ id: Int, _ poster: Data) {
        serialQueue.async { [weak self] in
            self?.imageMovies[id] = poster
        }
    }

    private func getQuestion(type: QuestionType, movie: MostPopularMovie) -> (questionText: String, correctAnswert: Bool) {
        switch type {
        case .year:
            let year = movie.year
            var yearQuestion = 0
            repeat {
                yearQuestion = year + [-3, -2, -1, 1, 2, 3].randomElement()!
            } while yearQuestion > 2024
            let boolQuestion = [">", "<"].randomElement()!
            let text = "Фильм вышел в прокат \(boolQuestion == ">" ? "позже" : "раньше") \(yearQuestion) года?"
            let correctAnswer = boolQuestion == ">" ? year > yearQuestion : year < yearQuestion
            return (text, correctAnswer)
        case .rating:
            let rating = Float(movie.rating.kp)
            let ratingQuestion = Int(rating) + [1, -1].randomElement()!
            let boolQuestion = [">", "<"].randomElement()!
            let text = "Рейтинг этого фильма \(boolQuestion == ">" ? "больше" : "меньше") чем \(ratingQuestion)?"
            let correctAnswer = boolQuestion == ">" ? rating > Float(ratingQuestion) : rating < Float(ratingQuestion)
            return (text, correctAnswer)
        }
    }

    private func fillMovieIndicesForQuiz() -> MostPopularMovie? {
        if movieIndicesForQuestions.count == 0 {
            while movieIndicesForQuestions.count < 10 {
                guard let index = (0..<movies.count).randomElement() else {continue}
                movieIndicesForQuestions.insert(index)
            }
            let group = DispatchGroup()
            getImagesQuestion(group)
            group.wait()
        }

        let index = movieIndicesForQuestions.removeFirst()
        let movie = movies[safe: index]
        return movie
    }

    private func getImagesQuestion(_ group: DispatchGroup) {
        for index in movieIndicesForQuestions {
            group.enter()
            DispatchQueue.global().async { [weak self] in
                defer {
                    group.leave()
                }
                guard let self else {
                    return
                }
                let id = self.movies[index].id
                guard self.imageMovies[id] == nil else {
                    return
                }
                var imageData = Data()
                do {
                    imageData = try Data(contentsOf: self.movies[index].poster.url)
                    if !imageData.isEmpty {
                        self.safeSetImage(movies[index].id, imageData)
                    }
                } catch {
                    print("Failed to load image")
                }

            }
        }
    }
}

extension QuestionFactoryImpl: QuestionFactory {

    //MARK: - Public Methods

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.docs
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else {
                return
            }
            guard let movie = fillMovieIndicesForQuiz() else {
                return
            }

            let questionType = QuestionType.random()
            let questionSegment = getQuestion(type: questionType, movie: movie)

            guard let poster = imageMovies[movie.id] else {
                return
            }

            let question = QuizQuestion(image: poster,
                                        text: questionSegment.questionText,
                                        correctAnswer: questionSegment.correctAnswert)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.delegate?.didReceiveNextQuestion(question)
            }
        }
    }
}
