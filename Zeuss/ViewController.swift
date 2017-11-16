//
//  ViewController.swift
//  Zeuss
//
//  Created by Cristhian Pinzon on 29/09/17.
//  Copyright © 2017 Cristhian Pinzon. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import Toast_Swift
//let imageSpin = UIImage(named: "s")!.withRenderingMode(.alwaysTemplate)
var arrRes = [[String:AnyObject]]()


class ViewController: UIViewController,CLLocationManagerDelegate{
// manejador que trae datos del gps del iphone
var locationManager = CLLocationManager()
    
var mapView:GMSMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mostrarMapa()
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mostrarMapa() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        locationManager.startUpdatingLocation()
        let camera = GMSCameraPosition.camera(withLatitude: 8.9381237,
                                              longitude: -75.0384922, zoom: 14.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.accessibilityElementsHidden = true
        mapView.accessibilityElementsHidden = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.compassButton = true;
        mapView.delegate = self
    
        // inicializacion del manejador del gps
        self.locationManager.delegate = self
        // actualiza la ubicacion actual
        self.locationManager.startUpdatingLocation()
        
        
        view = mapView
        // Creates a marker in the center of the map.

        // llama metodo que trae la ubicacion GPS. 
        traerUbicacion(locationManager)
        // metodo encargado de poner marcados a partir del json 
        ponerMarcadores(vista: mapView)
        
        
        //evento click a tocar un markador
        if let selectedMarker = mapView.selectedMarker {
            print("toco marker \(!(selectedMarker.title != nil))")
        }
    }
    
    
    // metodo encargado de traer la ubicacion gps 
    func traerUbicacion(_ manager: CLLocationManager) {
        
        let location = manager.location
        
        print("Mi ubicacion-> lat: \(location!.coordinate.latitude), lon: \(location!.coordinate.longitude) ")
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    
    func ponerMarcadores(vista:GMSMapView){
        
    // imagen marcador que utiliza un metodo q mejora la resolucion de la imagen.
    let imageSpin = resizeImage(image: UIImage(named: "spinzeuss")!, targetSize: CGSize(width: 40, height: 40))
    //let imageSpin = UIImage(named: "spinzeuss")!
        
      print("spin-> \(imageSpin)")
        
        
        traerEstaciones{nombres,posisx,posisy in
        
            

            for edss in nombres{
               // print(posisy[nombres.index(of: edss)!])
                let markerEds = GMSMarker()
                let lat = Double(posisx[nombres.index(of: edss)!])
                let lon = Double(posisy[nombres.index(of: edss)!])
                
                print("\(edss) POS-> \(lat!), \(lon!)")
                markerEds.position = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                markerEds.title = edss
                markerEds.snippet = edss
                markerEds.icon = imageSpin
                markerEds.map = vista
                
            }
        }

        

    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    

    

    
    
    func traerEstaciones(complete: @escaping (_ names: [String],_ posisx: [String],_ posisy: [String]) ->     ()){
        let parametros = ["tck":"Zeuss01*_*1037"]
        
        var nombresEds = [String]()
        var posxEds = [String]()
        var posyEds = [String]()
        //print(objEstacion!.verDatos())
        //listStation.php?tck=Zeuss01*_*1037
        Alamofire.request("http://zeusswebservices.mieds.com/listStation.php",method: .post, parameters : parametros)
            .responseJSON {response in
                //print(response.result.value!)
                if((response.result.value) != nil){
                    let jsonVar = JSON(response.result.value!)
                    //print(jsonVar)
                    if let resData = jsonVar["estaciones"].arrayObject{
                        //print(resData)
                        arrRes = resData as! [[String:AnyObject]]
                        //print("tam ->" + String(self.arrRes.count))
                        // print(self.arrRes.)
                        //dump(self.arrRes)
                        
                        for element in arrRes {
                            let nombre = (element)["nombre_estacion"]
                            let posx = (element)["latitud_estacion"]
                            let posy = (element)["longitud_estacion"]
                            
                            //print("Pos-> \(posx!)  \(posy!)")
                            //let datos = ("\(nombre!) Pos-> \(posx!)  \(posy!)")
                            nombresEds.append(nombre as! String)
                            posxEds.append(posx as! String)
                            posyEds.append(posy as! String)
                            //print("tamNombresEds->" + String(nombresEds.count))
                        }
                        complete(nombresEds,posxEds,posyEds)
                        
                    }
                }
        }
        
    }


}

extension ViewController: GMSMapViewDelegate {
    
    // seleccion de un marcador
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var style = ToastStyle()
        
        // this is just one of many style options
        style.messageColor = .lightText
        style.backgroundColor = .darkGray
        
        // present the toast with the new style
        self.view.makeToast("Selecciono-> \(marker.title)", duration: 3.0, position: .center, style: style)

        //self.view.makeToast("Selecciono-> \(marker.title)")
        return true
    }
}




