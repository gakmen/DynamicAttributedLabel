//
//  ViewController.swift
//  DynamicAttributedLabel
//
//  Created by Gosha Akmen on 02.06.2024.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let label = AttributedLabel(text: "TEXT")
    label.backgroundColor = .green

    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }


}

