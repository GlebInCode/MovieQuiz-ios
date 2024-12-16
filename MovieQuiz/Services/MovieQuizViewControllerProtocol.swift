//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Глеб Хамин on 25.10.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    
    func showFinalResults()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    
    func showNetworkError(message: String)
}
