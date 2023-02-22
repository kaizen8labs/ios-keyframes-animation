//
//  CardAnimationTransition.swift
//  CardAnimation
//
//  Created by Kai Nguyen on 2/16/23.
//

import Foundation
import UIKit

@objc protocol TransitionInfoProtocol {
  var view: UIView! { get set }
  
  // Return the views which shoud be animated in the transition
  func viewsToAnimate() -> [UIView]
  
  // Return a copy of the view which is passed in
  // The passed in view is one of the views to animate
  func copyForView(_ subView: UIView) -> UIView
  
  // Optionally return the frames for the views which should be
  // animated. This is needed sometimes because for example
  // with custom container view contrllers the transitioning code
  // can't figure out where on screen the view is actually visible
  // when loaded.
  @objc optional func frameForView(_ subView: UIView) -> CGRect
}

class CardAnimationTransition: NSObject, UIViewControllerAnimatedTransitioning {

  var operation: UINavigationController.Operation = .push
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! TransitionInfoProtocol
      let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! TransitionInfoProtocol

      let containerView = transitionContext.containerView

      containerView.addSubview(fromViewController.view)
      containerView.addSubview(toViewController.view)

      if operation == .pop {
          containerView.bringSubviewToFront(fromViewController.view)
      }

      toViewController.view.setNeedsLayout()
      toViewController.view.layoutIfNeeded()
        

      let fromViews = fromViewController.viewsToAnimate()
      let toViews = toViewController.viewsToAnimate()

      assert(fromViews.count == toViews.count, "Number of elements in fromViews and toViews have to be the same.")

      var intermediateViews = [UIView]()

      var fromFrames = [CGRect]()
      var toFrames = [CGRect]()

      for i in 0..<fromViews.count {
          let fromView = fromViews[i]
          let fromFrame = fromView.superview!.convert(fromView.frame, to: nil)
          fromView.alpha = 0

          let intermediateView = fromViewController.copyForView(fromView)
          intermediateView.frame = fromFrame
          containerView.addSubview(intermediateView)
          intermediateViews.append(intermediateView)

          let toView = toViews[i]
          var toFrame: CGRect
          if let tempToFrame = toViewController.frameForView?(toView) {
              toFrame = tempToFrame
          } else {
              toFrame = toView.superview!.convert(toView.frame, to: nil)
          }
          toFrames.append(toFrame)
          fromFrames.append(fromView.frame)
          toView.alpha = 0
      }

      if operation == .push {
          toViewController.view.alpha = 0
      }
      
      // Fade to view
      if self.operation == .pop {
        fromViewController.view.alpha = 0
      } else {
        toViewController.view.alpha = 1
      }
      
      if let cardImageView = intermediateViews.first as? UIImageView, let fromFrame = fromFrames.first, let toFrame = toFrames.first {
          
          // Prevent clipping image
          cardImageView.layer.zPosition = 999
          
          // Double faces card solution (change front, back image)
          let changeImage = CAKeyframeAnimation(keyPath: "contents")
          changeImage.duration = 3
          changeImage.calculationMode = .discrete
          changeImage.values = [
            UIImage(named: "front")!.cgImage as AnyObject,
            UIImage(named: "back")!.cgImage as AnyObject,
            UIImage(named: "back")!.cgImage as AnyObject,
            UIImage(named: "front")!.cgImage as AnyObject,
            UIImage(named: "front")!.cgImage as AnyObject,
            UIImage(named: "back")!.cgImage as AnyObject
          ]
          changeImage.fillMode = .forwards
          changeImage.isRemovedOnCompletion = false
          cardImageView.layer.add(changeImage, forKey: "contents")
          
          
          // Animating combination
          first2Seconds(cardImageView: cardImageView, fromFrame: fromFrame, toFrame: toFrame) {
              self.last2Seconds(cardImageView: cardImageView, fromFrame: fromFrame, toFrame: toFrame) {
                  cardImageView.removeFromSuperview()
                  fromViews.first?.alpha = 1
                  toViews.first?.alpha = 1
                  transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
              }
          }
      }
    
  }
    func last2Seconds(cardImageView: UIImageView, fromFrame: CGRect, toFrame: CGRect, complete: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            complete()
        })
        cardImageView.layer.add(lastAnimations(fromFrame: fromFrame, toFrame: toFrame), forKey: "awesome_anim")
        CATransaction.commit()
    }
    
    func lastAnimations(fromFrame: CGRect, toFrame: CGRect) -> CAAnimationGroup {
        
        // Last 2 seconds
        
        var identity = CATransform3DIdentity
        identity.m34 = 1.0 / -500
        
        
        let radian1 = 30.0 * -.pi / 180.0
        let rotate1 = CATransform3DRotate(identity, radian1, 0.0, 1.0, -0.3)
        
        let radian2 = 90 * .pi / 180.0
        let rotate2 = CATransform3DRotate(identity, radian2, 0.0, 0.0, -1.0)
        
        
        let radian3 = 180 * .pi / 180.0
        let rotate3 = CATransform3DRotate(identity, radian3, 0.0, 1.0, 0.0)
        
        let perspectiveTransform = CAKeyframeAnimation(keyPath: "transform")
        perspectiveTransform.duration = 1
        perspectiveTransform.values = [rotate1, CATransform3DConcat(rotate3, rotate2)]
        perspectiveTransform.keyTimes = [0, 1]
        
        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.duration = 1
        scale.values = [1, 3.7]
        scale.keyTimes = [0, 1]
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: fromFrame.midX, y: fromFrame.midY))
        path.addLine(to: CGPoint(x: toFrame.midX, y: toFrame.midY))
        let position = CAKeyframeAnimation(keyPath: "position")
        position.duration = 1
        position.path = path.cgPath
        position.isRemovedOnCompletion = false
        position.fillMode = .forwards
        position.keyTimes = [0.5]
        
        let group = CAAnimationGroup()
        group.duration = 1
        group.isRemovedOnCompletion = false
        group.animations = [perspectiveTransform, scale, position]
        
        return group
    }
    
    
    
    func first2Seconds(cardImageView: UIImageView, fromFrame: CGRect, toFrame: CGRect, complete: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            complete()
        })
        cardImageView.layer.add(firstAnimations(fromFrame: fromFrame, toFrame: toFrame), forKey: "awesome_anim")
        CATransaction.commit()
    }
    
    func firstAnimations(fromFrame: CGRect, toFrame: CGRect) -> CAAnimationGroup {
        
        // First 2 seconds
        let originalY = fromFrame.origin.y + fromFrame.size.height/2
        let bounce = CAKeyframeAnimation(keyPath: "position.y")
        bounce.duration = 1
        bounce.repeatCount = 2
        bounce.values = [originalY, originalY - 40, originalY]
        bounce.keyTimes = [0.0, 0.5, 1]
        
        let rotate = CAKeyframeAnimation(keyPath: "transform.rotation.y")
        rotate.duration = 2
        rotate.repeatCount = 1
        rotate.values = [0, 3, 0]
        rotate.keyTimes = [0.0, 0.5, 1]
        
        var identity = CATransform3DIdentity
        identity.m34 = 1.0 / -500
        let radian = 30.0 * -.pi / 180.0
        let rotate1 = CATransform3DRotate(identity, radian, 0.0, 1.0, -0.3)
        let rotate2 = CATransform3DRotate(identity, radian, 0.0, 1.0, 0.6)
        
        let perspectiveTransform = CAKeyframeAnimation(keyPath: "transform")
        perspectiveTransform.duration = 2
        perspectiveTransform.values = [rotate1, rotate2, rotate1]
        perspectiveTransform.keyTimes = [0, 0.5, 1]
        
        let group = CAAnimationGroup()
        group.duration = 2
        group.isRemovedOnCompletion = false
        group.animations = [perspectiveTransform, bounce, rotate]
        
        return group
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 3
    }
}
