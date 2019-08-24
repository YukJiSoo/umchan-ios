//
//  SearchCrewViewController.swift
//  Umchan
//
//  Created by 육지수 on 8/24/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import UIKit

class SearchCrewViewController: SearchViewController {

    // MARK: - SubViews
    var crewListView = ScrollableStackView(frame: .zero)
    var stackView: UIStackView?
    
    // MARK: - Properties
    var crews = [Crew]()
//    var crews = [
//        Crew(name: "test1", numberOfPeople: 1, image: "test1"),
//        Crew(name: "test1", numberOfPeople: 1, image: "test1"),
//        Crew(name: "test1", numberOfPeople: 1, image: "test1"),
//        Crew(name: "test1", numberOfPeople: 1, image: "test1"),
//        Crew(name: "test1", numberOfPeople: 1, image: "test1"),
//        Crew(name: "test1", numberOfPeople: 1, image: "test1"),
//        Crew(name: "test1", numberOfPeople: 1, image: "test1")
//    ]
    
    override var searchType: CustomSearchBar.SearchType {
        return .crew
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupEmptyCase()
        self.setupCrewListView()
        self.setupActivityIndicator()
    }
    
    // MARK: - Functions
    override func setupSearchBar() {
        super.setupSearchBar()
        self.searchBar.configure(searchType: self.searchType)
    }
    
    override func loadData() {
        
        self.stackView?.isHidden = true
        self.crewListView.initializeSubViews()
        
        self.isLoading = true
        // get data from api server
        // update view
        
        if !crews.isEmpty {
            self.updateCrewListView()
        } else {
            self.stackView?.isHidden = false
        }
        
        self.isLoading = false
    }
    
    func setupEmptyCase() {
        
        // add views
        let emptyImageView = UIImageView(frame: .zero)
        
        emptyImageView.image = UIImage(named: AssetName.empty)
        emptyImageView.contentMode = .scaleAspectFit
        
        let emptyLabel = UILabel(frame: .zero)
        
        emptyLabel.font = UIFont.umchanFont(size: CGFloat(20), boldState: .extrabold)
        emptyLabel.text = "참여중인 크루가 없습니다"
        emptyLabel.textColor = Color.symbolTransparent
        
        let createCrewButton = UIButton(frame: .zero)
        
        createCrewButton.setImage(UIImage(named: AssetName.shoes), for: .normal)
        createCrewButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40)
        createCrewButton.setTitle("크루만들기", for: .normal)
        createCrewButton.titleLabel?.font = UIFont.umchanFont(size: CGFloat(20), boldState: .extrabold)
        createCrewButton.setTitleColor(Color.symbol, for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [ emptyImageView, emptyLabel, createCrewButton ])
        stackView.configure(axis: .vertical, distribution: .fill, alignment: .fill, spacing: 30)
        self.view.addSubview(stackView)
        
        // setConstraint
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 20).isActive = true
        
        let emptyImageViewWidthAnchor = emptyImageView.widthAnchor.constraint(equalToConstant: 200)
        let emptyImageViewHeightAnchor = emptyImageView.heightAnchor.constraint(equalToConstant: 200)
        
        let createCrewButtonWidthAnchor = createCrewButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 150)
        
        NSLayoutConstraint.activate([
            emptyImageViewWidthAnchor,
            emptyImageViewHeightAnchor,
            createCrewButtonWidthAnchor
        ])
        
        self.stackView = stackView
        self.stackView?.isHidden = true
    }

    func setupCrewListView() {
        
        self.view.addSubview(self.crewListView)
        
        self.crewListView.translatesAutoresizingMaskIntoConstraints = false
        
        let topAnchor = self.crewListView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor)
        let bottomAnchor = self.crewListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        let leadingAnchor = self.crewListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingAnchor = self.crewListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        
        NSLayoutConstraint.activate([ topAnchor, bottomAnchor, leadingAnchor, trailingAnchor ])
    }
    
    func updateCrewListView() {
        
        var crewViews = [CrewView]()
        for crew in crews {
            let crewView = CrewView(frame: .zero)
            crewView.configure(crew: crew)
            
            crewViews.append(crewView)
        }
        
        self.crewListView.configureSubViews(subViews: crewViews)
        self.crewListView.reloadInputViews()
    }
    
}
