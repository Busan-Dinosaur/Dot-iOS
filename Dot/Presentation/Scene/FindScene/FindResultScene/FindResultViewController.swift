//
//  FindResultViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/18.
//

import UIKit

import SnapKit
import Then

final class FindResultViewController: UIViewController {
    
    // MARK: - ui component
    
    let findResultView: FindResultView = FindResultView()
    
    // MARK: - init
    
    deinit {
        print("\(#file) is dead")
    }
    
    // MARK: - life cycle
    
    override func loadView() {
        self.view = self.findResultView
    }
}
