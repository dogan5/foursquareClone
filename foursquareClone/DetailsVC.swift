//
//  DetailsVC.swift
//  foursquareClone
//
//  Created by Doğan seçilmiş on 21.06.2022.
//

import UIKit
import MapKit
import Parse

class DetailsVC: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var detailsMapView: MKMapView!
    @IBOutlet weak var detailsAtmosphereLAbel: UILabel!
    @IBOutlet weak var detailsTypeLabel: UILabel!
    @IBOutlet weak var detailsNameLabel: UILabel!
    @IBOutlet weak var detailsImageView: UIImageView!
    
    var chosenPlaceId = ""
    var chosenPlaceLatitude = Double()
    var chosenPlaceLongLatitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       getDataFromParse()
        detailsMapView.delegate = self
        
    }
    func getDataFromParse() {
        
        let query = PFQuery(className: "Places")
        query.whereKey("objectId", equalTo: chosenPlaceId)
        query.findObjectsInBackground { objects, error in
            if error != nil {
                
            }else{
                if objects != nil {
                  let chosenPlaceObject = objects![0]
                    
                    if let placeName = chosenPlaceObject.object(forKey: "name") as? String {
                        self.detailsNameLabel.text = placeName
            }
                    if let placeType = chosenPlaceObject.object(forKey: "type") as? String {
                        self.detailsTypeLabel.text = placeType
            }
                    if let placeAtmosphere = chosenPlaceObject.object(forKey: "atmosphere") as? String {
                        self.detailsAtmosphereLAbel.text = placeAtmosphere
            }
                    if let placeLatitude = chosenPlaceObject.object(forKey: "latitude") as? String{
                        if let placeLatitudeDouble = Double(placeLatitude) {
                            self.chosenPlaceLatitude = placeLatitudeDouble
                        }
                    }
                    if let placeLongitude = chosenPlaceObject.object(forKey: "longitude") as? String{
                        if let placeLongitude = Double(placeLongitude){
                            self.chosenPlaceLongLatitude = placeLongitude
                        }
                    }
                    if let imageData = chosenPlaceObject.object(forKey: "image") as? PFFileObject{
                        imageData.getDataInBackground { data, error in
                            if error == nil {
                                self.detailsImageView.image = UIImage(data: data!)
                            }
                        }
                    }
        }
                let location = CLLocationCoordinate2D(latitude: self.chosenPlaceLatitude, longitude: self.chosenPlaceLongLatitude)
                let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
                let region = MKCoordinateRegion(center: location, span: span)
                self.detailsMapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = self.detailsNameLabel.text!
                annotation.subtitle = self.detailsTypeLabel.text!
                self.detailsMapView.addAnnotation(annotation)
    }
    


}
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if self.chosenPlaceLatitude != 0.0 && self.chosenPlaceLongLatitude != 0.0 {
            let requestLocation = CLLocation(latitude: self.chosenPlaceLatitude, longitude: chosenPlaceLongLatitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                if let placemark = placemarks {
                    if placemark.count > 0 {
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.detailsNameLabel.text
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
                
            }
        }
    }
}
