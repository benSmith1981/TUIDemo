//
//  CustomSearchTextfield.swift
//  TUIMobility
//
//  Created by Ben Smith on 26/01/2020.
//  Copyright © 2020 Ben Smith. All rights reserved.
//

import Foundation
import UIKit

enum SearchTextField: Int {
    case from = 0
    case to
    
    mutating func textFieldType(tag: Int) -> SearchTextField {
        switch tag {
        case SearchTextField.from.rawValue:
            return .from
        case SearchTextField.to.rawValue:
            return .to
        default:
            return .to
        }
    }
}

class CustomSearchTextField: UITextField, UITextFieldDelegate{
    weak var filterDelegate: filterSearch?
    private var tableView: UITableView?
    private var textFieldType: SearchTextField = .to
    var departureResults: [Connection] = [Connection]() {
        didSet{
            self.tableView?.reloadData()
        }
    }
    var destinationResults: [Connection] = [Connection](){
        didSet{
            self.tableView?.reloadData()
        }
    }
    
    // Connecting the new element to the parent view
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        textFieldType = textFieldType.textFieldType(tag: self.tag)
        tableView?.removeFromSuperview()
        
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.delegate = self
        self.addTarget(self, action: #selector(CustomSearchTextField.textFieldDidChange), for: .editingChanged)

    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        buildSearchTableView()
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateSearchTableView()
        tableView?.isHidden = false

    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textFieldType == .from {
            self.departureResults = []
            self.destinationResults = []
            self.filterDelegate?.clearRoute()
        }
        return true
    }
    
    @objc open func textFieldDidChange(){
        filterDelegate?.filter(textfieldType: textFieldType, searchText: self.text!)
        updateSearchTableView()
        tableView?.isHidden = false
    }


}

extension CustomSearchTextField: UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch textFieldType {
        case .from:
            return departureResults.count
        case .to:
            return destinationResults.count
        }
    }
    
    // MARK: TableViewDelegate methods
    //Adding rows in the tableview with the data from dataList
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomSearchTextFieldCell", for: indexPath) as UITableViewCell
        cell.backgroundColor = UIColor.clear
        switch textFieldType {
        case .from:
            cell.textLabel?.text = departureResults[indexPath.row].from
        case .to:
            cell.textLabel?.text = destinationResults[indexPath.row].to
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")

        switch textFieldType {
        case .from:
            //we must filter again the departure selected, to make sure we get the right destinations
            self.text = departureResults[indexPath.row].from
            filterDelegate?.filter(textfieldType: textFieldType, searchText: departureResults[indexPath.row].from)
        case .to:
            calculateRouteDetails()
            self.text = destinationResults[indexPath.row].to
        }
        
        tableView.isHidden = true
        self.endEditing(true)
    }
    
    func calculateRouteDetails() {
        self.filterDelegate?.sendPrice(price: destinationResults[self.tableView?.indexPathForSelectedRow?.row ?? 0].price)
        self.filterDelegate?.calculateRoute(for: self.destinationResults[self.tableView?.indexPathForSelectedRow?.row ?? 0])
    }
    
    func buildSearchTableView() {
        
        if let tableView = tableView {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CustomSearchTextFieldCell")
            tableView.delegate = self
            tableView.dataSource = self
            self.window?.addSubview(tableView)
            
        } else {
            tableView = UITableView(frame: CGRect.zero)
        }
        
        updateSearchTableView()
    }
    
    // Updating SearchtableView
    func updateSearchTableView() {
        
        if let tableView = tableView {
            superview?.bringSubviewToFront(tableView)
            var tableHeight: CGFloat = 0
            tableHeight = tableView.contentSize.height
            
            // Set a bottom margin of 10p
            if tableHeight < tableView.contentSize.height {
                tableHeight -= 10
            }
            
            // Set tableView frame
            var tableViewFrame = CGRect(x: 0, y: 0, width: frame.size.width - 4, height: tableHeight)
            tableViewFrame.origin = self.convert(tableViewFrame.origin, to: nil)
            tableViewFrame.origin.x += 2
            tableViewFrame.origin.y += frame.size.height + 2
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.tableView?.frame = tableViewFrame
            })
            
            //Setting tableView style
            tableView.layer.masksToBounds = true
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.layer.cornerRadius = 5.0
            tableView.separatorColor = UIColor.lightGray
            tableView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            
            if self.isFirstResponder {
                superview?.bringSubviewToFront(self)
            }
            
            tableView.reloadData()
        }
    }
}
