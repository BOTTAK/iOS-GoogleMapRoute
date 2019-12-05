//
//  AddressConvertor.swift
//  iOS-GoogleMapRoute
//
//  Created by BOTTAK on 12/5/19.
//  Copyright © 2019 BOTTAK. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class AddressConvertor {

    static func addressToCoords(address: String, callback: @escaping (_ lat: Double, _ lng: Double) -> Void) {
        let rPoint = address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        Request.new(address: "https://maps.googleapis.com/maps/api/geocode/json?address=" + rPoint + "&key=AIzaSyCOsDzwdBQCwZjJ9keUKeBYdUBydijVSoI", method: "GET", {response in
            var hasCoords = false
            let res = response?.value as! [String : Any]
            for a in res {
                if(a.key == "results") {
                    if let b = a.value as? [Any] {
                        if(b.count != 0) {
                            let c = b[0]
                            if let d = c as? [String : Any] {
                                for e in d {
                                    if(e.key == "geometry") {
                                        if let f = e.value as? [String : Any] {
                                            for g in f {
                                                if(g.key == "location") {
                                                    if let h = g.value as? [String : Any] {
                                                        hasCoords = true
                                                        let lat = Double(round(1000000*(h["lat"] as! Double))/1000000)
                                                        let lng = Double(round(1000000*(h["lng"] as! Double))/1000000)
                                                        callback(lat, lng)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(!hasCoords) {
                callback(-1.0, -1.0)
            }
        })
    }
    
    static func coordsToAddress(latlng: String, callback: @escaping (_ res: String) -> Void) {
        Request.new(address: "https://maps.googleapis.com/maps/api/geocode/json?latlng=" + latlng +
        "&language=ru&key=AIzaSyCOsDzwdBQCwZjJ9keUKeBYdUBydijVSoI", method: "GET", {response in
            var hasAddress = false
            let res = response?.value as! [String : Any]
            for a in res {
                if(a.key == "results") {
                    if let b = a.value as? [Any] {
                        if(b.count != 0) {
                            let c = b[0]
                            if let d = c as? [String : Any] {
                                for e in d {
                                    if(e.key == "formatted_address") {
                                        hasAddress = true
                                        var f = (e.value as! String).replacingOccurrences(of: "Unnamed Road, ", with: "")
                                        callback(f)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(!hasAddress) {
                callback("-")
            }
        })
    }

    
    static func getPath(address1: String, address2: String, callback: @escaping (_ path: GMSPath) -> Void) {
        let rPoint1 = address1.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let rPoint2 = address2.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        Request.new(address: "https://maps.googleapis.com/maps/api/directions/json?origin=" + rPoint1 + "&destination=" + rPoint2 + "&key=AIzaSyCOsDzwdBQCwZjJ9keUKeBYdUBydijVSoI", method: "GET", {response in
            let path = response?.value as! [String : Any]
            if(path["routes"] == nil || path["routes"] as? [Any] == nil || (path["routes"] as? [Any])?.count == 0) {
                UIPageViewController.curView!.createAlert(error: "Ошибка получения точек пути!")
                return
            }
            
            let routes = (path["routes"] as! [Any])[0] as! [String : Any]
            let overview_polyline = routes["overview_polyline"] as! [String : Any]
            let points = overview_polyline["points"] as! String
            callback(GMSPath.init(fromEncodedPath: points)!)
        })
    }
    
    static var lastAutocompleteRequestTime : Int64 = 0
    static func getAutocomplete(address: String, callback: @escaping (_ res: [String]) -> Void) {
        let rPoint1 = address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        print(getCurrentMillis() - lastAutocompleteRequestTime)
        if(getCurrentMillis() - lastAutocompleteRequestTime < 200) {
            return
        }
        lastAutocompleteRequestTime = getCurrentMillis()
        Request.new(address: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" + rPoint1 + "&types=geocode&language=ru&key=AIzaSyCOsDzwdBQCwZjJ9keUKeBYdUBydijVSoI", method: "GET", {response in
            let res = response?.value as! [String : Any]
            var addressArr : [String] = []
            for a in res {
                if(a.key == "predictions") {
                    if let b = a.value as? [Any] {
                        if(b.count != 0) {
                            for c in b {
                            if let d = c as? [String : Any] {
                                print("E")
                                for e in d {
                                    if(e.key == "structured_formatting") {
                                        if let ad = e.value as? [String : Any] {
                                            var f = (ad["secondary_text"] as? String ?? "")
                                            f = f.replacingOccurrences(of: "Unnamed Road, ", with: "")
                                            addressArr.append(f + ", " + (ad["main_text"] as? String ?? ""))
                                        }
                                    }
                                }
                            }
                        }
                        }
                    }
                }
            }
            callback(addressArr)
        })
    }
    
    private static func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }

}
