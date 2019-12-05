//
//  ViewController.swift
//  iOS-GoogleMapRoute
//
//  Created by BOTTAK on 12/5/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import UIKit

import GoogleMaps

class MapViewController: UIPageViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var address1TextField: AddressUITextField!
    @IBOutlet weak var address2TextField: AddressUITextField!
    @IBOutlet weak var changeTextFieldTypeBtn: UIButton!
    
    let locManager = CLLocationManager()
    var markerImgViews : [UIImageView] = []
    var gmspath = GMSPath()
    var pathLine = GMSPolyline()
    var userLocation = CLLocationCoordinate2D()
    var zoomLevel: Float = 15
    
    var addressType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.camera = GMSCameraPosition.camera(withTarget: userLocation, zoom: zoomLevel)
        mapView.settings.myLocationButton = true
    }
    
    override func loadViewController() {
        loadMap()
        changeTextFieldTypeBtn.setTitle("Адрес -> Координаты", for: .normal)
    }
    
    func changeTextFieldType() {
        if(addressType == 0) {
            var lat01 = -1.0
            var lng01 = -1.0
            var lat02 = -1.0
            var lng02 = -1.0
            AddressConvertor.addressToCoords(address: self.address1TextField.text!, callback: {_lat01, _lng01 in
                if(_lat01 != -1.0 && _lng01 != -1.0) {
                    lat01 = _lat01
                    lng01 = _lng01
                }
                AddressConvertor.addressToCoords(address: self.address2TextField.text!, callback: {_lat02, _lng02 in
                    if(_lat02 != -1.0 && _lng02 != -1.0) {
                        lat02 = _lat02
                        lng02 = _lng02
                    }
                    if(lat01 != -1.0 && lng01 != -1.0 && lat02 != -1.0 && lng02 != -1.0) {
                        self.address1TextField.text = String(lat01) + "," + String(lng01)
                        self.address2TextField.text = String(lat02) + "," + String(lng02)
                        self.changeTextFieldTypeFinally(true)
                    } else {
                        self.changeTextFieldTypeFinally(false)
                    }
                    
                })
            })
        } else {
            if(address1TextField.text == "" && address2TextField.text == "") {
                self.changeTextFieldTypeFinally(true)
                return
            }
            var address1 = "-"
            var address2 = "-"
            AddressConvertor.coordsToAddress(latlng: self.address1TextField.text!, callback: {_address1 in
                address1 = _address1
                AddressConvertor.coordsToAddress(latlng: self.address2TextField.text!, callback: {_address2 in
                    address2 = _address2
                    if(address1 == "-" || address2 == "-") {
                        self.changeTextFieldTypeFinally(false)
                    } else {
                        self.address1TextField.text = address1
                        self.address2TextField.text = address2
                        self.changeTextFieldTypeFinally(true)
                    }
                })
            })
        }
    }
    
    func changeTextFieldTypeFinally(_ success: Bool) {
        if(success) {
            if(addressType == 0) {
                changeTextFieldTypeBtn.setTitle("Координаты -> Адрес", for: .normal)
                addressType = 1
            } else {
                changeTextFieldTypeBtn.setTitle("Адрес -> Координаты", for: .normal)
                addressType = 0
            }
        } else {
            self.createAlert(error: "Ошибка преобразования адреса!")
        }
    }
    
    func loadMap() {
        mapView.camera = GMSCameraPosition.camera(withLatitude: 53.9006011, longitude: 27.558972, zoom: 13)
        mapView.delegate = self
        
        /*locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()*/
    }
    
    @IBAction func changeTextFieldsTypeBtnClick(_ sender: Any) {
        changeTextFieldType()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.first != nil && mapView != nil) {
            mapView.camera = GMSCameraPosition(target: locations.first!.coordinate, zoom: 13, bearing: 0, viewingAngle: 0)
            locManager.stopUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        var size = Int((position.zoom - 11) * 25)
        size = size < 10 ? 0 : size
        size = size > 100 ? 100 : size
        for markerView in markerImgViews {
            markerView.frame.size = CGSize(width: size, height: size)
            markerView.layer.cornerRadius = CGFloat(size / 2)
        }
    }
    
    @IBAction func calculatePathBtnClick(_ sender: Any) {        calculatePath(point1: address1TextField.text!, point2: address2TextField.text!)
    }
    
    func calculatePath(point1: String, point2: String) {
        AddressConvertor.getPath(address1: address1TextField.text!, address2: address2TextField.text!, callback: {path in
            self.gmspath = path
            self.drawPath()
        })
    }
    
    func drawPath(){
        pathLine.map = nil
        pathLine = GMSPolyline(path: gmspath)
        pathLine.strokeColor = UIColor(red: 1, green: 0.75, blue: 0.8, alpha: 1)
        pathLine.strokeWidth = 5
        pathLine.map = mapView
    }

}

