//
//  HorizontalScrollView.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import UIKit

class HorizontalScrollView: BaseScrollView<[UIImage]> {
    let horizontalWidth: CGFloat
    let horizontalHeight: CGFloat
    
    init(horizontalWidth: CGFloat, horizontalHeight: CGFloat) {
        self.horizontalWidth = horizontalWidth
        self.horizontalHeight = horizontalHeight
        
        super.init(frame: .zero)
        
        configureUI()
    }
    
    override func configureUI() {
        super.configureUI()
        
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
    }
    
    override func bind(_ model: [UIImage]) {
        super.bind(model)
        
        setImages()
        updateScrollViewContentWidth()
    }
    
    private func setImages() {
        guard let images = model else { return }
        images
            .enumerated()
            .forEach {
                let imageView = UIImageView(image: $0.element)
                imageView.contentMode = .scaleAspectFill
                imageView.layer.masksToBounds = true
                let xOffset = horizontalWidth * CGFloat($0.offset)
                
                imageView.frame = CGRect(x: xOffset, y: 0, width: horizontalWidth, height: horizontalHeight)
                addSubview(imageView)
            }
    }
    
    private func updateScrollViewContentWidth() {
        contentSize.width = horizontalWidth * CGFloat(model?.count ?? 1)
    }
}
