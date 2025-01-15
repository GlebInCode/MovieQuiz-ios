//
//  QuestionType.swift
//  MovieQuiz
//
//  Created by Глеб Хамин on 15.01.2025.
//

import Foundation

enum QuestionType: CaseIterable {
    case year
    case rating

    static func random() -> QuestionType {
        return QuestionType.allCases.randomElement()!
    }
}
