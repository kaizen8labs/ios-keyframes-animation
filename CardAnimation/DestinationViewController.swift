//
//  ViewController.swift
//  CardAnimation
//
//  Created by Kai Nguyen on 2/15/23.
//

import UIKit
import SnapKit

class DestinationViewController: UIViewController {

    var startX = CGFloat(0)
    var navigationControllerDelegate: NavigationControllerDelegate?
    
    private lazy var card: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .clear
        image.image = UIImage(named: "final-back")
        image.tag = 222
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        view.backgroundColor = .white
        title = "Destination"
        
        // interaction
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
      navigationControllerDelegate = navigationController?.delegate as? NavigationControllerDelegate
    }

    func setupView() {
        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.width.equalTo(287)
            make.height.equalTo(177)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-150)
        }    
    }
    
}

extension DestinationViewController: TransitionInfoProtocol {
    func viewsToAnimate() -> [UIView] {
      return [card]
    }
    
    func copyForView(_ subView: UIView) -> UIView {
      if subView == card {
        let imageViewCopy = UIImageView(image: card.image)
        imageViewCopy.contentMode = card.contentMode
        imageViewCopy.clipsToBounds = true
        return imageViewCopy
      }
      return UIView()
    }
}

extension DestinationViewController {
  @objc func pan(_ sender: UIPanGestureRecognizer) {
    
    let translation = sender.translation(in: view)
    
    let percent = min(1, max(0, (translation.x - startX)/200))
    
    switch sender.state {
      case .began:
        startX = translation.x
        navigationControllerDelegate?.interactiveTransition = UIPercentDrivenInteractiveTransition()
        navigationController?.popViewController(animated: true)
      case .changed:
        navigationControllerDelegate?.interactiveTransition?.update(percent)
      case .ended:
        fallthrough
      case .cancelled:
        if sender.velocity(in: sender.view).x < 0 && percent < 0.5 {
          navigationControllerDelegate?.interactiveTransition?.cancel()
        } else {
          navigationControllerDelegate?.interactiveTransition?.finish()
        }
        navigationControllerDelegate?.interactiveTransition = nil
      default:
        break
    }
    
  }
}
