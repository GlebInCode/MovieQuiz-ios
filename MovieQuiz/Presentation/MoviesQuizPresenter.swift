//
//  MoviesQuizPresenter.swift
//  MovieQuiz
//
//  Created by Глеб Хамин on 25.10.2023.
//

import Foundation
import UIKit

final class MoviesQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactory?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(_ question: QuizQuestion) {
        self.currentQuestion = question
        let viewModel = convert(model: question)
//        DispatchQueue.main.async { [weak self] in
//                    self?.viewController?.show(quiz: viewModel)
//                }
        viewController?.show(quiz: viewModel)
    }
    
    // MARK: - Private Methods
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion(){
            viewController?.showFinalResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Methods
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restsrtGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func makeResultMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let resultMessage =
        """
        Ваш результат: \(correctAnswers)\\\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)\\\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%2.f", statisticService.totalAccuracy))%
        """
        return resultMessage
    }
}
