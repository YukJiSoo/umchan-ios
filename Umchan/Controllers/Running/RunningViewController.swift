//
//  RunningViewController.swift
//  Umchan
//
//  Created by 육지수 on 8/25/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import UIKit

class RunningViewController: UIViewController, NibLodable {

    // MARK: - Outlets
    @IBOutlet weak var navigationBar: CustomNavigationBar!
    @IBOutlet weak var oneLineLabel: UILabel!
    @IBOutlet weak var registerDateLabel: UILabel!
    @IBOutlet weak var runningDateLabel: UILabel!
    @IBOutlet weak var leaderView: UIStackView!
    @IBOutlet weak var membersView: UIStackView!
    
    // MARK: - Properties
    var running: RunningType?
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubViews()
        self.setupNavigationBar()
        self.setupParticipatingLeaderAndMembers()
    }
    
    // MARK: - Functions
    func setupSubViews() {
        
        self.oneLineLabel.text = self.running?.oneLine
        
        if let running = running {
            let (runningDate, registerDate) = convertRunningDateString(running: running)
            self.registerDateLabel.text = registerDate
            self.runningDateLabel.text = runningDate
        }
    }
    
    func setupNavigationBar() {
        
        self.navigationBar.delegate = self
        
        if let title = self.running?.name {
            self.navigationBar.title = title
        }
        self.navigationBar.configureButton(location: .left, type: .back)
    }
    
    func setupParticipatingLeaderAndMembers() {
        
        let captinViewNib = UserView.instanceFromNib()
        captinViewNib.configure(user: User(name: "크루장", nickname: "별명", imagePath: "이미지", location: Location(latitude: 20.0, longitude: 10.2)))
        let firstMemberViewNib = UserView.instanceFromNib()
        firstMemberViewNib.configure(user:  User(name: "크루원1", nickname: "별명", imagePath: "이미지", location: Location(latitude: 20.0, longitude: 10.2)))
        let secondMemberViewNib = UserView.instanceFromNib()
        secondMemberViewNib.configure(user:  User(name: "크루원2", nickname: "별명", imagePath: "이미지", location: Location(latitude: 20.0, longitude: 10.2)))
        
        self.leaderView.addArrangedSubview(captinViewNib)
        self.membersView.addArrangedSubview(firstMemberViewNib)
        self.membersView.addArrangedSubview(secondMemberViewNib)
    }
    
    @IBAction func requestButtonPressed(_ sender: UIButton) {
        
        let alertController = self.createBasicAlertViewController(title: "참가신청", message: "리더에게 참가 신청을 보냈습니다")  {
            self.dismiss(animated: true, completion: nil)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension RunningViewController: CustomNavigationBarDelegate {
    
    func leftBarButtonPressed(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
