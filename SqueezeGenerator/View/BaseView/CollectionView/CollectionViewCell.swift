//
//  CollectionViewCell.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import SwiftUI

class CollectionViewCell: UICollectionViewCell {
    struct Configuration {
        struct Paddings {
            static let contentHorizontal: CGFloat = 10
            static let contentVertical: CGFloat = 8
        }
    }
    private var label: UILabel? { (textStack?.arrangedSubviews.first(where: {$0 is UIStackView}) as? UIStackView)?.arrangedSubviews.first(where: {$0 is UILabel && $0.tag == 0}) as? UILabel }
    private var tagLabel: UILabel? { (textStack?.arrangedSubviews.first(where: {$0 is UIStackView}) as? UIStackView)?.arrangedSubviews.first(where: {$0 is UILabel && $0.tag == 2}) as? UILabel }
    private var mainImageView: UIImageView? {
        (textStack?.arrangedSubviews.first(where: {
            $0 is UIStackView
        }) as? UIStackView)?.arrangedSubviews.first(where: {$0 is UIImageView && $0.tag == 0}) as? UIImageView

    }

    private var progressView: UIProgressView? {
        textStack?.arrangedSubviews.first(where: {$0 is UIProgressView}) as? UIProgressView

    }

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
        mainImageView?.image = nil
        imageStack?.arrangedSubviews.forEach({
            if let image = $0 as? UIImageView {
                image.image = nil
            }
        })
    }

    func fetchImage(
        imageURL: String,
        completion: @escaping(_ image: UIImage)->()) {
            guard let imageURL = URL(string: imageURL) else {
                self.mainImageView?.isHidden = true
                return
            }
            DispatchQueue.init(label: "db", qos: .userInitiated).async {
                let task = URLSession.shared.dataTask(
                    with: .init(url: imageURL, cachePolicy: .reloadRevalidatingCacheData)
                ) { data, response, error in
                    DispatchQueue.main.async {
                        self.mainImageView?.image = .init(data: data ?? .init())
                        self.mainImageView?.isHidden = false
                    }
                }
                task.resume()
            }
    }

    func set(_ data: CollectionViewController.CollectionData,
             isWhite: Bool) {
        label?.text = data.title.capitalized
        let progress = Float(data.percent ?? "") ?? 0
        progressView!.isHidden = progress == 0
        progressView?.progress = progress / 100
        tagLabel?.text = data.label ?? ""
        tagLabel?.isHidden = data.label?.isEmpty ?? true
        self.fetchImage(imageURL: data.imageURL) { image in

        }
        label?.font =
            .systemFont(
                ofSize: isWhite ? 13 : data.fontSize,
                weight: isWhite ? .medium : data.fontWeight
            )
        if let background = data.cellBackground {
            backgroundColoredView?.backgroundColor = (data.isType ? background : .white)
                .withAlphaComponent(isWhite ? 1 : (!data.isType ? 0.2 : 0.1))

        } else {
            backgroundColoredView?.backgroundColor = data.isType ? .red
                .withAlphaComponent(isWhite ? 1 : 0.2) : .white
                .withAlphaComponent(data.isSelected ? 1 : 0.1)
        }
        let isBackgroundLight = backgroundColoredView?.backgroundColor?.isLight ?? true
        label?.textColor = isWhite && data.isSelected ? (isBackgroundLight ? .black : .white) : (
            isWhite ? (isBackgroundLight ? UIColor.black : UIColor.white) : .white
        )
        .withAlphaComponent(isWhite ? 1 : (!data.isType ? 0.5 : 0.8))
        descriptionLabel?.text = data.description
        if data.title.isEmpty {
            descriptionLabel?.textColor = .white

        } else {
            descriptionLabel?.textColor = .white

        }
        descriptionLabel?.isHidden = true
//        if descriptionLabel?.isHidden != data.description?.isEmpty ?? true {
//            descriptionLabel?.isHidden = data.description?.isEmpty ?? true
//        }
//        label?.attributedText = attributedString
        //here
//        if let texts = textStack,
//           isWhite {
//            texts.topAnchor.constraint(equalTo: texts.superview!.topAnchor, constant: 5).isActive = true
//            texts.bottomAnchor.constraint(equalTo: texts.superview!.bottomAnchor, constant: -5).isActive = true
//            texts.layoutIfNeeded()
//            texts.superview?.layoutIfNeeded()
//
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel()
        let descriptionLabel = UILabel()
        descriptionLabel.tag = 1
        let valueLabel = UILabel()
        valueLabel.tag = 2
        let progress = UIProgressView()
        progress.tintColor = .white
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.lineBreakMode = .byClipping
        let backgroundOutline = UIView()
        backgroundOutline.layer.name = "backgroundOutlineView"
        let backgroundColoredView = UIView()
        backgroundColoredView.layer.name = "backgroundColoredView"
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .init(rawValue: 999)!))
        backgroundColoredView.addSubview(blur)
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.leadingAnchor.constraint(equalTo: blur.superview!.leadingAnchor).isActive = true
        blur.trailingAnchor.constraint(equalTo: blur.superview!.trailingAnchor).isActive = true

        blur.topAnchor.constraint(equalTo: blur.superview!.topAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: blur.superview!.bottomAnchor).isActive = true

//        let imageStack = UIStackView()
        let textStack = UIStackView()
        textStack.alignment = .leading
        let titleStack = UIStackView()
        let titleImage = UIImageView()
        titleStack.axis = .horizontal
        titleStack.spacing = 5
        titleStack.alignment = .center
        valueLabel.addSubview(.init())
        let imageBackground = UIView()
        imageBackground.backgroundColor = .white.withAlphaComponent(0.2)
        imageBackground.layer.cornerRadius = 8
        imageBackground.layer.zPosition = -100
        imageBackground.layer.masksToBounds = true
        titleImage.addSubview(imageBackground)
        [titleImage, label, valueLabel].forEach {//titleImage,
            titleStack.addArrangedSubview($0)
        }
        [titleStack, descriptionLabel, progress].forEach {
            textStack.addArrangedSubview($0)
        }
        textStack.spacing = 8
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
        label.textColor = .white.withAlphaComponent(.Opacity.description.rawValue)
        descriptionLabel.font = .systemFont(ofSize: 9, weight: .regular)
        descriptionLabel.textColor = .black.withAlphaComponent(0.2)
        backgroundOutline.layer.cornerRadius = .CornerRadius.medium.rawValue

        backgroundColoredView.layer.cornerRadius = .CornerRadius.medium.rawValue

        self.layer.cornerRadius = .CornerRadius.smallest.rawValue
        self.layer.masksToBounds = true

        titleImage.translatesAutoresizingMaskIntoConstraints = false
        titleImage.contentMode = .scaleAspectFit
        backgroundColoredView.translatesAutoresizingMaskIntoConstraints = false
        backgroundOutline.translatesAutoresizingMaskIntoConstraints = false
//        imageStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        imageBackground.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
[
            titleImage.widthAnchor.constraint(equalToConstant: 16),
            titleImage.heightAnchor.constraint(equalToConstant: 16),
            progress.leadingAnchor.constraint(equalTo: progress.superview!.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: progress.superview!.trailingAnchor),

//            label.widthAnchor.constraint(lessThanOrEqualToConstant: 80),

            
//            imageStack.topAnchor.constraint(equalTo: imageStack.superview!.topAnchor, constant: -5),
//            imageStack.leadingAnchor.constraint(equalTo: imageStack.superview!.leadingAnchor, constant: 0),
//            imageStack.heightAnchor.constraint(equalToConstant: 35),
//            imageStack.widthAnchor.constraint(equalToConstant: 100),

            imageBackground.leadingAnchor.constraint(equalTo: imageBackground.superview!.leadingAnchor, constant: -5),
            imageBackground.trailingAnchor.constraint(equalTo: imageBackground.superview!.trailingAnchor, constant: 5),
            imageBackground.bottomAnchor.constraint(equalTo: imageBackground.superview!.bottomAnchor, constant: 5),
            imageBackground.topAnchor.constraint(equalTo: imageBackground.superview!.topAnchor, constant: -5),
            textStack.topAnchor.constraint(equalTo: textStack.superview!.topAnchor, constant: Configuration.Paddings.contentVertical),
            textStack.bottomAnchor
                .constraint(
                    equalTo: textStack.superview!.bottomAnchor,
                    constant: -Configuration.Paddings.contentVertical
                ),
            textStack.leadingAnchor
                .constraint(
                    equalTo: textStack.superview!.leadingAnchor,
                    constant: Configuration.Paddings.contentHorizontal
                ),
            textStack.trailingAnchor.constraint(equalTo: textStack.superview!.trailingAnchor, constant: -Configuration.Paddings.contentHorizontal),

            backgroundOutline.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
//5),
            backgroundOutline.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
//-10),
            backgroundOutline.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
//5),
            backgroundOutline.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//-10),
            
            backgroundColoredView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
//8),
            backgroundColoredView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
//-8),
            backgroundColoredView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
//8),
            backgroundColoredView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//-8),
            
            descriptionLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]
)
        valueLabel.subviews.first?.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.subviews.first?.leadingAnchor
            .constraint(equalTo: valueLabel.leadingAnchor, constant: -2).isActive = true
        valueLabel.subviews.first?.trailingAnchor
            .constraint(equalTo: valueLabel.trailingAnchor, constant: 2).isActive = true
        valueLabel.subviews.first?.topAnchor
            .constraint(equalTo: valueLabel.topAnchor, constant: -2).isActive = true
        valueLabel.subviews.first?.bottomAnchor
            .constraint(equalTo: valueLabel.bottomAnchor, constant: 2).isActive = true
        valueLabel.subviews.first?.layer.zPosition = -1
        valueLabel.subviews.first?.backgroundColor = .red.withAlphaComponent(0.1)
        valueLabel.subviews.first?.layer.cornerRadius = 6
        valueLabel.font = .systemFont(ofSize: 9, weight: .semibold)
        valueLabel.textColor = .white

    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
