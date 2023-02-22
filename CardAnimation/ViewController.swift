//
//  ViewController.swift
//  CardAnimation
//
//  Created by Kai Nguyen on 2/15/23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        title = "Home"
        view.backgroundColor = .white
    }
    
    private lazy var card: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .clear
        image.image = UIImage(named: "front")
        image.isUserInteractionEnabled = true
        return image
    }()
    
    func setupView() {
        view.addSubview(card)
        card.snp.makeConstraints { make in
            make.width.equalTo(177 * 0.25)
            make.height.equalTo(287 * 0.25)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pushToDestination))
        card.addGestureRecognizer(tapGesture)
        
        // Perspective view
        var identity = CATransform3DIdentity
        identity.m34 = 1.0 / -500
        let rotate = CATransform3DRotate(identity, 30.0 * -.pi / 180.0, 0.0, 1.0, -0.3)
        card.layer.transform = rotate
        
    }
    @objc func pushToDestination() {
        let vc = DestinationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ViewController: TransitionInfoProtocol {
  func viewsToAnimate() -> [UIView] {
    return [card]
  }
  
    func copyForView(_ subView: UIView) -> UIView {
        let imageView = UIImageView(image: card.image)
        imageView.tag = 111
        return imageView
    }
}
