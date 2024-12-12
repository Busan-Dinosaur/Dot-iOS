//
//  BaseViewModelType.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import Foundation

import Moya

protocol BaseViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(from input: Input) -> Output
}
