//
//  CollectionViewCell.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import SwiftUI

class CollectionViewCell: UICollectionViewCell {
    
    private var label: UILabel? { (textStack?.arrangedSubviews.first(where: {$0 is UIStackView}) as? UIStackView)?.arrangedSubviews.first(where: {$0 is UILabel && $0.tag == 0}) as? UILabel }
    private var mainImageView: UIImageView? { (textStack?.arrangedSubviews.first(where: {$0 is UIStackView}) as? UIStackView)?.arrangedSubviews.first(where: {$0 is UIImageView}) as? UIImageView }

    private var descriptionLabel: UILabel? { textStack?.arrangedSubviews.first(where: {$0 is UILabel && $0.tag == 1}) as? UILabel }

    private var backgroundColoredView:UIView? { contentView.subviews.first(where: {$0.layer.name == "backgroundColoredView"})}
    
    private var backgroundOutline:UIView? { contentView.subviews.first(where: {$0.layer.name == "backgroundOutline"})}
    private var imageStack:UIStackView? { backgroundColoredView?.subviews.first(where: {$0 is UIStackView && $0.tag == 0}) as? UIStackView}
    private var textStack:UIStackView? {
        contentView.subviews.first(where: {$0 is UIStackView && $0.tag == 1}) as? UIStackView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLabel?.text = ""
        imageStack?.arrangedSubviews.forEach({
            if let image = $0 as? UIImageView {
                image.image = nil
            }
        })
    }
    
    func set(_ data:CollectionViewController.CollectionData) {
        label?.text = data.title
        label?.font = .systemFont(ofSize: data.isType ? 12 : 17, weight: data.isType ? .semibold : .regular)

        descriptionLabel?.text = data.description
        if data.title.isEmpty {
            descriptionLabel?.textColor = .white

        } else {
            descriptionLabel?.textColor = .white

        }
        if descriptionLabel?.isHidden != data.description?.isEmpty ?? true {
            descriptionLabel?.isHidden = data.description?.isEmpty ?? true
        }
//        label?.attributedText = attributedString
        if let background = data.cellBackground {
            backgroundColoredView?.backgroundColor = background.withAlphaComponent(0.85)

        } else {
            backgroundColoredView?.backgroundColor = data.isType ? .red : .white
        }

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel()
        let descriptionLabel = UILabel()
        descriptionLabel.tag = 1
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byWordWrapping
        let backgroundOutline = UIView()
        backgroundOutline.layer.name = "backgroundOutlineView"
        let backgroundColoredView = UIView()
        backgroundColoredView.layer.name = "backgroundColoredView"
//        let imageStack = UIStackView()
        let textStack = UIStackView()
        textStack.alignment = .leading
        let titleStack = UIStackView()
        let titleImage = UIImageView()
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        [titleImage, label].forEach {
            titleStack.addArrangedSubview($0)
        }
        [titleStack, descriptionLabel].forEach {
            textStack.addArrangedSubview($0)
        }
        textStack.spacing = -2
        textStack.tag = 1
        textStack.axis = .vertical
        textStack.distribution = .fillProportionally
        
        contentView.addSubview(backgroundColoredView)
        contentView.addSubview(backgroundOutline)

//        backgroundColoredView.addSubview(imageStack)
        backgroundColoredView.layer.masksToBounds = true
        contentView.addSubview(textStack)
//        imageStack.alpha = 0.15
//        imageStack.distribution = .fillEqually
//        imageStack.spacing = -2
//        imageStack.axis = .horizontal
//        for i in 0..<5 {
//            let image = UIImageView(image: .banana)
//            image.tag = i
//            image.contentMode = .scaleAspectFit
//            imageStack.addArrangedSubview(image)
//        }
        label.textColor = .black
        descriptionLabel.font = .systemFont(ofSize: 9, weight: .regular)
        descriptionLabel.textColor = .black.withAlphaComponent(0.2)
        backgroundOutline.layer.cornerRadius = 12
        backgroundOutline.layer.borderWidth = 0.4
        backgroundOutline.layer.borderColor = UIColor.black.cgColor
        backgroundColoredView.layer.cornerRadius = 12
       
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        
        backgroundColoredView.translatesAutoresizingMaskIntoConstraints = false
        backgroundOutline.translatesAutoresizingMaskIntoConstraints = false
//        imageStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleImage.widthAnchor.constraint(equalToConstant: 16),
//            titleImage.heightAnchor.constraint(equalToConstant: 16),

            
//            imageStack.topAnchor.constraint(equalTo: imageStack.superview!.topAnchor, constant: -5),
//            imageStack.leadingAnchor.constraint(equalTo: imageStack.superview!.leadingAnchor, constant: 0),
//            imageStack.heightAnchor.constraint(equalToConstant: 35),
//            imageStack.widthAnchor.constraint(equalToConstant: 100),
            
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            backgroundOutline.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),//5),
            backgroundOutline.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),//-10),
            backgroundOutline.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),//5),
            backgroundOutline.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),//-10),
            
            backgroundColoredView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),//8),
            backgroundColoredView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),//-8),
            backgroundColoredView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),//8),
            backgroundColoredView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),//-8),
            
            descriptionLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ])
        
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}


