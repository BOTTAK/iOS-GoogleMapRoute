//
//  AddressTextField.swift
//  iOS-GoogleMapRoute
//
//  Created by BOTTAK on 12/5/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import UIKit
/**
 Класс текстового поля с адресом
 */
class AddressUITextField: UITextField, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var tableView : UITableView? = nil
    var tableViewOnPage = false
    
    var tableData=[String]()
    var addresses : [String] = []

    /**
     Ставим основные параметры
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: UIControl.Event.editingChanged)
    }
    
    /**
     При изменении текстового поля отправляем запрос на получение адресов по тексту
     */
    @objc func textFieldDidChanged(_ textField:UITextField ){
        AddressConvertor.getAutocomplete(address: self.text!, callback: {address in
            self.addresses = address
            self.tableView?.reloadData()
        })
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.tableView?.removeFromSuperview()
    }
    
    /**
     Ставим нужные параметры при начале редактирования поля
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
            let tableView = UITableView(frame: CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y + textField.frame.height + 2,
                                                      width: textField.frame.width, height: 0))
            tableView.layer.borderWidth = 1
            tableView.layer.cornerRadius = 3
            textField.superview?.addSubview(tableView)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
            self.tableView = tableView
    }
    
    /**
     Удаляем таблицу если она создана автоматически
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(!tableViewOnPage) {
            self.tableView?.removeFromSuperview()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!tableViewOnPage) {
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width, height: CGFloat((addresses.count > 5 ? 5 : addresses.count) * 45))
        }
        return addresses.count
    }
    
    /**
     Нажатие на ячейку таблицы
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*self.text = addresses[indexPath.item].name
        self.address = addresses[indexPath.item]
        if(self.address?.isHome != nil && (self.address?.isHome)!) {
            self.endEditing(true)
        }*/
        self.text = addresses[indexPath.item]
        self.endEditing(true)
        textFieldDidChanged(self)
    }
    
    /**
     Ячейка таблицы
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier:"addCategoryCell")
        
        cell.selectionStyle =  UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        cell.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        cell.textLabel?.text = addresses[indexPath.row]
        cell.tag = indexPath.row
        return cell
    }
}
