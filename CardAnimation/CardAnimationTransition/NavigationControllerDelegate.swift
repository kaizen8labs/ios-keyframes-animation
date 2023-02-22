//
//  NavigationControllerDelegate.swift
//  CardAnimation
//
//  Created by Kai Nguyen on 2/16/23.
//

import Foundation
import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
  
  var interactiveTransition: UIPercentDrivenInteractiveTransition?
  
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    let transition: UIViewControllerAnimatedTransitioning?
    
    switch (fromVC, toVC) {
      case (_, is DestinationViewController):
        let CardAnimationTransition = CardAnimationTransition()
        CardAnimationTransition.operation = .push
        transition = CardAnimationTransition
      case (is DestinationViewController, _):
        let CardAnimationTransition = CardAnimationTransition()
        CardAnimationTransition.operation = .pop
        transition = CardAnimationTransition
      
      default:
        transition = nil
    }
    
    return transition
  }
  
  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactiveTransition
  }
}
