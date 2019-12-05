//
//  UIPageViewController.swift
//  iOS-GoogleMapRoute
//
//  Created by BOTTAK on 12/5/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import UIKit

class UIPageViewController: UIViewController {

    static var curView : UIPageViewController? = nil
    var loadDataCount = 0
    var loadingView : UILabel? = nil
    
    static var className: String {
        return String(describing: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoadingView()
        UIPageViewController.curView = self
        loadViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIPageViewController.curView = self
    }
    
    func loadViewController() {
    }
    
    func openPage(_ page: UIPageViewController.Type, _ animated: Bool = true){
        let page = self.storyboard?.instantiateViewController(withIdentifier: page.className)
        self.navigationController?.pushViewController((page as! UIPageViewController) as UIViewController, animated: animated)
    }
    
    func createAlert(error: String) {
        let alert = UIAlertController(title: "Ошибка", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createLoadingView() {
        let label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height / 2 - 20, width: self.view.frame.width, height: 45))
        label.font = label.font.withSize(40)
        label.isHidden = true
        label.text = "Идет загрузка"
        label.textAlignment = .center
        loadingView = label
        self.view.addSubview(label)
    }
    
    func startLoading() {
        loadDataCount += 1
        loadingView?.isHidden = false
    }
    
    func stopLoading() {
        loadDataCount -= 1
        if(loadDataCount == 0) {
            loadingView?.isHidden = true
        }
    }
    
}
