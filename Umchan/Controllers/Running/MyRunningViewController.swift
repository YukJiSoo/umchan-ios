//
//  MyRunningViewController.swift
//  Umchan
//
//  Created by 육지수 on 9/29/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import UIKit
import CoreLocation

class MyRunningViewController: UIViewController, NibLodable {

    // MARK: - Outlets
    @IBOutlet weak var navigationBar: CustomNavigationBar!
    @IBOutlet weak var oneLineLabel: UILabel!
    @IBOutlet weak var registerDateLabel: UILabel!
    @IBOutlet weak var runningDateLabel: UILabel!
    @IBOutlet weak var leaderView: UIStackView!
    @IBOutlet weak var membersView: UIStackView!
    @IBOutlet weak var mapView: MapView!
    // member 전용
    @IBOutlet weak var goOutRunningButton: UIButton!
    // leader 전용
    @IBOutlet weak var manageMemberButton: UIButton!
    @IBOutlet weak var cancelRunningButton: UIButton!

    var loadingView = UIView(frame: .zero)
    var indicatorView = UIActivityIndicatorView(style: .whiteLarge)

    // MARK: - Properties
    var id: String?
    var district: String?
    var running: RunningQueryType?
    var memberState: MemberStateType?

    var captinViews = [UserView]()
    var memberViews = [UserView]()

    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // white back ground
        self.view.addSubview(self.loadingView)
        self.loadingView.backgroundColor = .white
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.loadingView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true

        // indicator
        self.indicatorView.color = Color.symbol
        self.view.addSubview(self.indicatorView)

        self.indicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.indicatorView.startAnimating()

        self.setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.indicatorView.startAnimating()
        self.setupData()
    }

    // MARK: - Functions
    func setupData() {

        guard let id = self.id, let district = self.district else {
            return
        }
        RunningService.shared.running(id: id, district: district) { (response) in
            switch response {
            case .success(_):

                guard let data = try? response.get() else {
                    debugPrint("cannot get data")
                    return
                }

                self.running = data.0
                self.memberState = data.1
                DispatchQueue.main.async {
                    self.setupSubViews()
                    self.loadingView.isHidden = true
                    self.indicatorView.stopAnimating()
                }
            case .failure(RunningAPIError.runningList(let message)):

                print(message)
            default:
                debugPrint("Uncorrect access")
            }
        }
    }

    func setupSubViews() {

        self.oneLineLabel.text = self.running?.oneLine

        if let running = self.running {
            self.navigationBar.title = running.name ?? "러닝"

            let (runningDate, registerDate) = convertRunningDateString(running: running)
            self.registerDateLabel.text = registerDate
            self.runningDateLabel.text = runningDate
        }

        self.setupLeaderAndMembers()
        self.setupMapView()
        self.setupButtons()
    }

    func setupNavigationBar() {

        self.navigationBar.delegate = self
        self.navigationBar.configureButton(location: .left, type: .back)
    }

    func setupLeaderAndMembers() {

        guard
            let leaderName = self.running?.leader?.name,
            let leaderNickname = self.running?.leader?.nickname,
            let leaderDistrict = self.running?.leader?.district,
            let leaderID = self.running?.leader?.userId
        else {
                return
        }

        self.captinViews.forEach { (view) in
            view.removeFromSuperview()
        }

        for view in self.memberViews {
            print(view)
            view.removeFromSuperview()
        }

        let captinViewNib = UserView.instanceFromNib()
        captinViewNib.configure(user: User(id: leaderID, name: leaderName, nickname: leaderNickname, district: leaderDistrict))

        self.captinViews.append(captinViewNib)
        self.leaderView.addArrangedSubview(captinViewNib)

        self.running?.members?.forEach({ (member) in
            guard
                let memberName = member?.name,
                let memberNickname = member?.nickname,
                let memberDistrict = member?.district,
                let memberID = member?.userId
            else {
                    return
            }

            let memberViewNib = UserView.instanceFromNib()
            memberViewNib.configure(user: User(id: memberID, name: memberName, nickname: memberNickname, district: memberDistrict))

            self.memberViews.append(memberViewNib)
            self.membersView.addArrangedSubview(memberViewNib)
        })
    }

    func setupMapView() {

        guard let runningPointDatas = self.running?.runningPoints else {
            return
        }

        var index = 0
        runningPointDatas.forEach { (data) in
            guard let latitude = data?.latitude, let longitude = data?.longitude else {
                return
            }

            index += 1
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let runningPoint = RunningPoint(coordinate: coordinate, order: index)
            self.mapView.annotationList.append(runningPoint)
        }

        self.mapView.reloadAnnotation()
        self.mapView.drawRunningCourse()
    }

    func setupButtons() {
        guard
            let leaderID = self.running?.leader?.userId,
            let myID = UserDataService.shared.user?.id,
            leaderID == myID
        else {
            if self.manageMemberButton != nil {
                self.manageMemberButton.removeFromSuperview()
                self.cancelRunningButton.removeFromSuperview()
            }
            return
        }

        if self.goOutRunningButton != nil {
            self.goOutRunningButton.removeFromSuperview()
        }
    }

    @IBAction func goOutRunningButtonPressed(_ sender: UIButton) {
        guard
            let id = self.id,
            let district = self.district
            else {
                debugPrint("id, district is nil")
                return
        }

        RunningService.shared.goOutRunning(id: id, district: district) { (response) in

            switch response {
            case .success(_):

                let alertController = self.createBasicAlertViewController(title: "참가취소", message: "러닝참가를 취소했습니다")  {
                    self.dismiss(animated: true, completion: nil)
                }
                self.present(alertController, animated: true, completion: nil)
            case .failure(RunningAPIError.goOutRunning(let message)):

                self.presentFailAlertController("취소 실패", with: message)
            default:
                debugPrint("Uncorrect access")
            }
        }
    }

    @IBAction func manageMemberButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardName.running, bundle: nil)
        let viewController = storyboard.viewController(ManageRunningMemberViewController.self)

        if
            let id = self.id,
            let district = self.district,
            let awaitMembers = self.running?.awaitMembers,
            let members = self.running?.members {

            viewController.id = id
            viewController.district = district
            viewController.awaitMembers = awaitMembers as? [RunningQueryType.AwaitMember]
            viewController.members = members as? [RunningQueryType.Member]
        }

        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func cancelRunningButton(_ sender: UIButton) {
        guard
            let id = self.id,
            let district = self.district
            else {
                debugPrint("id, district is nil")
                return
        }

        RunningService.shared.cancelRunning(id: id, district: district) { (response) in

            switch response {
            case .success(_):

                let alertController = self.createBasicAlertViewController(title: "참가취소", message: "러닝참가를 취소했습니다")  {
                    self.dismiss(animated: true, completion: nil)
                }
                self.present(alertController, animated: true, completion: nil)
            case .failure(RunningAPIError.goOutRunning(let message)):

                self.presentFailAlertController("취소 실패", with: message)
            default:
                debugPrint("Uncorrect access")
            }
        }
    }
}

extension MyRunningViewController: CustomNavigationBarDelegate {

    func leftBarButtonPressed(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }
}
