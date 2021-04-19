//
//  MapViewController.swift
//  OnTheMap
//
//  Created by vagelis spirou on 30/3/21.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addStudentBarButton: UIBarButtonItem!
    @IBOutlet weak var logOutBarButton: UIBarButtonItem!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    
    var listOfStudentsLocation = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        view.backgroundColor = .darkGray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = "On the Map"
        
        DispatchQueue.main.async {
            OTMClient.getStudentLocation(completion: self.handleGetStudentsLocation(studentsLocation:error:))
        }
    }
    
    func handleGetStudentsLocation(studentsLocation: [StudentInformation], error: Error?) {
       
        if error != nil {

            self.showFailToGetStudentLocation(message: "We can't download the students location.")
            return
            
        } else {

            self.listOfStudentsLocation = studentsLocation
            var annotations = [MKPointAnnotation]()

            for studentLocation in self.listOfStudentsLocation {

                let lat = CLLocationDegrees(studentLocation.latitude)
                let long = CLLocationDegrees(studentLocation.longitude)

                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let firstName = studentLocation.firstName
                let lastName = studentLocation.lastName
                let mediaURL = studentLocation.mediaURL
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL

                annotations.append(annotation)

            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    func showFailToGetStudentLocation(message: String) {
        
        let alert = UIAlertController(title: "Error to get Students Location", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        show(alert, sender: nil)
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        
        OTMClient.getStudentLocation(completion: handleGetStudentsLocation(studentsLocation:error:))
        
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        
        OTMClient.logout {
            DispatchQueue.main.async {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func addStudentPressed(_ sender: UIBarButtonItem) {
        
        OTMClient.getPublicUserData { (success, error) in
            
            if success {
                
                self.performSegue(withIdentifier: "toInformationPostingVC", sender: nil)
                
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        } else {
            pinView!.annotation = annotation
        }

        return pinView

    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            
            if let toOpen = view.annotation?.subtitle! {
            
                guard let url = URL(string: toOpen) else { return }
                app.open(url, options: [:], completionHandler: nil)
                
            }
        }
    }
}
