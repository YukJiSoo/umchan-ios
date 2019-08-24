//
//  ProfileViewController.swift
//  Umchan
//
//  Created by 육지수 on 8/25/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var navigationBar: CustomNavigationBar!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        
        self.navigationBar.delegate = self
        self.navigationBar.configureButton(location: .left, type: .close)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        
    }
    
    @IBAction func modifyButtonPressed(_ sender: UIButton) {
        
    }
}

extension ProfileViewController: CustomNavigationBarDelegate {
    
    func leftBarButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
