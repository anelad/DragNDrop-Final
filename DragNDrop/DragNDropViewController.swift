//
//  DragNDropViewController.swift
//  DragNDrop
//
//  Created by Dan Fairbanks on 1/3/15.
//  Copyright (c) 2015 Dan Fairbanks. All rights reserved.
//

import UIKit

class DragNDropViewController: UITableViewController {
  
  var itemsArray : [String]
  
  required init(coder aDecoder: NSCoder) {
    itemsArray = [String]()
    
    let item1 = "Bananas"
    let item2 = "Oranges"
    let item3 = "Kale"
    let item4 = "Milk"
    let item5 = "Yogurt"
    let item6 = "Crackers"
    let item7 = "Cheese"
    let item8 = "Carrots"
    let item9 = "Ice Cream"
    let item10 = "Olive Oil"
    
    itemsArray.append(item1)
    itemsArray.append(item2)
    itemsArray.append(item3)
    itemsArray.append(item4)
    itemsArray.append(item5)
    itemsArray.append(item6)
    itemsArray.append(item7)
    itemsArray.append(item8)
    itemsArray.append(item9)
    itemsArray.append(item10)
    
    super.init(coder: aDecoder)!
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    
    let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(gestureRecognizer:)))
    tableView.addGestureRecognizer(longpress)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
    let longPress = gestureRecognizer as! UILongPressGestureRecognizer
    let state = longPress.state
    let locationInView = longPress.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: locationInView)
    
    struct My {
      static var cellSnapshot : UIView? = nil
      static var cellIsAnimating : Bool = false
      static var cellNeedToShow : Bool = false
    }
    struct Path {
      static var initialIndexPath : IndexPath? = nil
    }
    
    switch state {
      case UIGestureRecognizerState.began:
        if indexPath != nil {
          Path.initialIndexPath = indexPath!
          let cell = tableView.cellForRow(at: indexPath!)!
          My.cellSnapshot  = snapshotOfCell(inputView: cell)
          
          var center = cell.center
          My.cellSnapshot!.center = center
          My.cellSnapshot!.alpha = 0.0
          tableView.addSubview(My.cellSnapshot!)
          
          UIView.animate(withDuration: 0.25, animations: { () -> Void in
            center.y = locationInView.y
            My.cellIsAnimating = true
            My.cellSnapshot!.center = center
            My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            My.cellSnapshot!.alpha = 0.98
            cell.alpha = 0.0
          }, completion: { (finished) -> Void in
            if finished {
              My.cellIsAnimating = false
              if My.cellNeedToShow {
                My.cellNeedToShow = false
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                  cell.alpha = 1
                })
              } else {
                cell.isHidden = true
              }
            }
          })
      }
      
      case UIGestureRecognizerState.changed:
        if My.cellSnapshot != nil {
          var center = My.cellSnapshot!.center
          center.y = locationInView.y
          My.cellSnapshot!.center = center
          
          if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
            itemsArray.insert(itemsArray.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
            tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
            Path.initialIndexPath = indexPath
          }
      }
      default:
        if Path.initialIndexPath != nil {
          let cell = tableView.cellForRow(at: Path.initialIndexPath!)!
          if My.cellIsAnimating {
            My.cellNeedToShow = true
          } else {
            cell.isHidden = false
            cell.alpha = 0.0
          }
          
          UIView.animate(withDuration: 0.25, animations: { () -> Void in
            My.cellSnapshot!.center = cell.center
            My.cellSnapshot!.transform = CGAffineTransform.identity
            My.cellSnapshot!.alpha = 0.0
            cell.alpha = 1.0
            
          }, completion: { (finished) -> Void in
            if finished {
              Path.initialIndexPath = nil
              My.cellSnapshot!.removeFromSuperview()
              My.cellSnapshot = nil
            }
          })
      }
    }
  }
  
  func snapshotOfCell(inputView: UIView) -> UIView {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
    inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let cellSnapshot : UIView = UIImageView(image: image)
    cellSnapshot.layer.masksToBounds = false
    cellSnapshot.layer.cornerRadius = 0.0
    cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
    cellSnapshot.layer.shadowRadius = 5.0
    cellSnapshot.layer.shadowOpacity = 0.4
    return cellSnapshot
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itemsArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
    cell.textLabel?.text = itemsArray[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
}
