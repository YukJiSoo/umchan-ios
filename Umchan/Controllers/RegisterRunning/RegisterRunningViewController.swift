//
//  RegisterRunningViewController.swift
//  Umchan
//
//  Created by 육지수 on 8/21/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import UIKit
import MapKit

class RegisterRunningViewController: UIViewController, NibLodable {

    // MARK: - Outlets
    @IBOutlet weak var navigationBar: CustomNavigationBar!
    @IBOutlet weak var runningNameLabel: UITextField!
    @IBOutlet weak var oneLineLabel: UITextField!
    @IBOutlet weak var registerLimitDateView: DateView!
    @IBOutlet weak var runningDateView: DateView!
    @IBOutlet weak var mapView: MapView!
    
    // MARK: - Properties
    var runningCourseData: [RunningPoint]?
    var runningCourseOverlays = [MKOverlay]()
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupGesture()
        self.setupDateView()
        self.setupMapView()
    }
    
    // MARK: - Functions
    func setupNavigationBar() {
        
        self.navigationBar.delegate = self
        self.navigationBar.configureButton(location: .left, type: .close)
    }
    
    func setupGesture() {
        
        self.addGestureForEndEditting()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapForSetRunningCourse(_:)))
        self.mapView.addGestureRecognizer(tapGesture)
    }
    
    func setupDateView() {
        
        self.registerLimitDateView.delegate = self
        self.registerLimitDateView.dateLabelPlaceholder = "신청기간 설정"
        
        self.runningDateView.delegate = self
        self.runningDateView.dateLabelPlaceholder = "달리는 날 설정"
    }
    
    func setupMapView() {
        
        self.mapView.setupFix()

        if let runningCourseData = self.runningCourseData {
            
            self.mapView.annotationList = runningCourseData
            self.mapView.reloadAnnotation()
        } else {
            self.mapView.configureLocationServices()
        }
    }
    
    func updateMapView() {
        
        self.mapView.clearRunningCourse()
        
        if let runningCourseData = self.runningCourseData {
            
            self.mapView.annotationList = runningCourseData
            self.mapView.reloadAnnotation()
            self.mapView.drawRunningCourse()
        }
    }
    
    @objc func tapForSetRunningCourse(_ gesture: UIGestureRecognizer) {
        
        let storyboard = UIStoryboard(name: StoryboardName.map, bundle: nil)
        let viewController = storyboard.viewController(MapViewController.self)
        viewController.modalPresentationStyle = .custom
        
        if let runningCourseData = self.runningCourseData {
            viewController.runningCourseData = runningCourseData
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func unwindToRegisterRunningViewController(segue: UIStoryboardSegue) {
        
        if segue.identifier == Segue.unwindToRegisterRunningViewController {
            
            guard let mapViewController = segue.source as? MapViewController else {
                debugPrint("fail to convert \(MapViewController.nibId)")
                return
            }
            
            self.runningCourseData = mapViewController.runningCourseData
            self.updateMapView()
        }
    }

    func registerRunningCompletion(_ response: Result<Bool, RunningAPIError>){

        switch response {
        case .success(_):

            self.dismiss(animated: true, completion: nil)
        case .failure(RunningAPIError.createRunning(let message)):

            self.presentFailAlertController("러닝 등록 실패", with: message)
        default:
            debugPrint("Uncorrect access")
        }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {

        guard
            let name = self.runningNameLabel.text, !name.isEmpty,
            let oneLine = self.oneLineLabel.text, !oneLine.isEmpty,
            let runningDate = self.runningDateView.getDateAndTimeComponents(),
            let registerLimitDate = self.registerLimitDateView.getDateAndTimeComponents(),
            let runningCourseData = self.runningCourseData, runningCourseData.count != 0
            else {
                debugPrint("All field is not filled")
                return
        }

        
        let runningPoint = runningCourseData.map { (Double($0.coordinate.latitude), Double($0.coordinate.longitude)) }

        DistrictInfoService.shared.convertLocationToDisrict(latitude: runningPoint[0].0, longitude: runningPoint[0].1) { (result) in

            switch result {
            case .success(let district):

                RunningService.shared.registerRunning(
                    name: name,
                    oneLine: oneLine,
                    runningDate: runningDate,
                    registerLimitDate: registerLimitDate,
                    runningPoint: runningPoint,
                    district: district,
                    completion: self.registerRunningCompletion(_:)
                )
            case .failure(DistrictInfoError.failToConvertLocation(let message)):

                self.presentFailAlertController("지역구 변환 실패", with: message)
            }

        }
    }
}

extension RegisterRunningViewController: CustomNavigationBarDelegate {
    
    func leftBarButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
