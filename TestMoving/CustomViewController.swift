//
//  ViewController.swift
//  TestMoving
//
//  Created by Taco Kind on 05-08-16.
//  Copyright © 2016 Taco Kind. All rights reserved.
//

import UIKit

import UIKit
import RealmSwift

class ObjectList: Object {
    let list1 = List<DemoObject>()
    let list2 = List<DemoObject>()
    let list3 = List<DemoObject>()

}

class DemoObject: Object {
    dynamic var title = ""
}

class CustomViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var itemsList = [List<DemoObject>]()
    private var collectionView : UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.registerClass(CustomCell.self, forCellWithReuseIdentifier: "cell")
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CustomViewController.handleGesture(_:)))
        self.collectionView.addGestureRecognizer(panGesture)

        self.view.addSubview(self.collectionView)

        let realm = try! Realm()
        if realm.isEmpty {
            try! realm.write {
                let list = ObjectList()
                list.list1.appendContentsOf(["one", "two", "three","four","five","six","seven","eight","nine","ten","eleven","twelve"].map {
                    DemoObject(value: [$0])
                    })
                list.list2.appendContentsOf(["one", "two", "three","four","five","six","seven","eight","nine","ten","eleven","twelve"].map {
                    DemoObject(value: [$0])
                    })
                
                realm.add(list)

            }
        }
        let items1 = realm.objects(ObjectList.self).first!.list1
        let items2 = realm.objects(ObjectList.self).first!.list2
        
        itemsList = [items1, items2]
        
    }

    override func viewWillLayoutSubviews() {
        let margins = view.layoutMarginsGuide
        self.collectionView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 0).active = true
        self.collectionView.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: 0).active = true
        self.collectionView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: 0).active = true
        self.collectionView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 0).active = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    // MARK: - Data source and delegate methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int   {
        return itemsList.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
         return itemsList[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        
        let items = itemsList[indexPath.section]
        cell.label.text = items[indexPath.row].title
        return cell
    }

                
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let itemsFrom = itemsList[sourceIndexPath.section]
        let itemsTo = itemsList[destinationIndexPath.section]
        
        try! itemsFrom.realm?.write {
            let itemToMove = itemsFrom[sourceIndexPath.row]
            itemsFrom.removeAtIndex(sourceIndexPath.row)
            itemsTo.insert(itemToMove, atIndex: destinationIndexPath.row)
        }
    }

    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width, 80)
    }
    
    func handleGesture(gesture: UIPanGestureRecognizer) {
        switch(gesture.state) {
        case UIGestureRecognizerState.Began:
            guard let selectedIndexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
                break }
            collectionView.beginInteractiveMovementForItemAtIndexPath(selectedIndexPath)
        case UIGestureRecognizerState.Changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
        case UIGestureRecognizerState.Ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}



class CustomCell: UICollectionViewCell {
    var label: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        self.label = UILabel()
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = self.contentView.layoutMarginsGuide
        self.label.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
        self.label.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
        self.label.centerYAnchor.constraintEqualToAnchor(self.contentView.centerYAnchor).active = true
    }
}
