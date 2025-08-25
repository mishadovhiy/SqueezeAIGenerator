//
//  CollectionView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import SwiftUI
import UIKit

struct CollectionView: UIViewControllerRepresentable {

    @Binding var contentHeight:CGFloat
    var isopacityCells: Bool = true
    var canUpdate = true
    let data: [CollectionViewController.CollectionData]
    var didSelect:((_ at:Int?)->())?

    func makeUIViewController(context: Context) -> CollectionViewController {
        let layout = FlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let vc = CollectionViewController(collectionViewLayout: layout)
        vc.data = data
        vc.isopacityCells = isopacityCells
        vc.dataUpdated = false
        vc.contentHeightUpdated = {
            self.contentHeight = $0
        }
        vc.didSelectRow = didSelect
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }
    
    func updateUIViewController(_ uiViewController: CollectionViewController, context: Context) {
        uiViewController.dataUpdated = false
        if canUpdate {
            if uiViewController.data != data {
                uiViewController.data = data
                uiViewController.collectionView.reloadData()
            }

        }
    }
}

class CollectionViewController: UICollectionViewController {
    var data:[CollectionData] = [] {
        didSet {
            view.gestureRecognizers?.forEach({
                $0.isEnabled = data.isEmpty
            })
        }
    }
    var isopacityCells: Bool = true
    var didSelectRow:((_ row:Int?) -> ())?
    var dataUpdated = false
    var dict:(CGFloat,Int) = (0,0)

    var contentHeightUpdated:((_ newHeight:CGFloat)->())?
    private var heightHolder:CGFloat = 0 {
        didSet {
            contentHeightUpdated?(heightHolder)
            self.view.heightAnchor.constraint(equalToConstant: heightHolder).isActive = true

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: .init(describing: CollectionViewCell.self))
//        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.minimumInteritemSpacing = 1
//            layout.minimumLineSpacing = 1
//            layout.scrollDirection = .vertical
//            
//            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
    }
    
//    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.collectionView.contentSize.height + 30 != heightHolder {
            if !dataUpdated {
                if self.dict.1 != self.data.count || self.dict.0 != (self.collectionView.contentSize.height + 30) {
                    dataUpdated = true
                    DispatchQueue.main.async {
                        self.heightHolder = self.collectionView.contentSize.height + 30
                        self.dict.0 = self.collectionView.contentSize.height + 30
                        self.dict.1 = self.data.count
                    }
                }
            }
            
        }
    }

    
    @objc func viewTapped(_ sender:UITapGestureRecognizer) {
        didSelectRow?(nil)
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: CollectionViewCell.self), for: indexPath) as! CollectionViewCell
        cell.set(data[indexPath.row], isWhite: !isopacityCells)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectRow?(indexPath.row)
    }
}

class FlowLayout: UICollectionViewFlowLayout {
    
    required init(minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        super.init()
        
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        sectionInsetReference = .fromSafeArea
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard scrollDirection == .vertical else { return layoutAttributes }
        
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })
        
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            var leftInset = sectionInset.left
            
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }
        
        return layoutAttributes
    }
    
}


extension [CollectionViewController.CollectionData] {
    static var demo: Self {
        Array(self.demos.shuffled().prefix([3, 4, 3, 6, 7].randomElement()!))
    }
    
    fileprivate static var demos: Self {
        [
            .init(title: "Proffessional Skills", cellBackground: .white, extraSmall: false),
            .init(title: "Nervious", cellBackground: .white, extraSmall: false),
            .init(title: "Shizophrenia Shizophrenia Shizophrenia", cellBackground: .white, extraSmall: false),
            .init(title: "sdffd", cellBackground: .white, extraSmall: false),
            .init(title: "cxvfasd cxvfasd cxvfasd cxvfasd cxvfasd cxvfasd cxvfasd", cellBackground: .white, extraSmall: false),
            .init(title: "rtegf", cellBackground: .white, extraSmall: false),
            .init(title: "5g4refw 5g4refw 5g4refw 5g4refw 5g4refw 5g4refw", cellBackground: .white, extraSmall: false),
            .init(title: "dfvc", cellBackground: .white, extraSmall: false)
        ]
    }
}
