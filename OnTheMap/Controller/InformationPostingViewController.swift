//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by vagelis spirou on 9/4/21.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {
    
    @IBOutlet weak var addLocationTextField: UITextField!
    @IBOutlet weak var addLinkTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var mediaURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findLocationButton.layer.cornerRadius = 10

        addLocationTextField.delegate = self
        addLinkTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Add Location"
        createDismissKeyboardTapGesture()
        mapView.delegate = self
        self.mapView.isHidden = true
        self.finishButton.isHidden = true
        
    }
    
    func createDismissKeyboardTapGesture() {
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func updateLocationOnMap(to location: CLLocation) {
        
        
        let point = MKPointAnnotation()
        
        point.coordinate = location.coordinate
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(point)
        
        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: Constants.latitudinalMeters, longitudinalMeters: Constants.longitudinalMeters)
        self.mapView.setRegion(viewRegion, animated: true)
        
    }
    
    func updatePlaceMark(to address: String) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            self.setToGeocoding(false)
            
            if error != nil {
                
                let alert = UIAlertController(title: "The Location doesn't exist", message: "Sorry i can't find that location, try again please.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                    self.mapView.isHidden = true
                    self.finishButton.isHidden = true
                }))
                self.present(alert, animated: true, completion: nil)
                return
            } else {
                guard let placemark = placemarks?.first, let location = placemark.location else { return }
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.updateLocationOnMap(to: location)
            }
        }
    }
    
    @IBAction func findLocationButtonPressed(_ sender: UIButton) {
        
        setToGeocoding(true)
        
        let address = addLocationTextField.text
        if let address = address, address != "", addLinkTextField.text != "" {
            self.mapView.isHidden = false
            self.finishButton.isHidden = false
            self.updatePlaceMark(to: address)
        } else {
            
            let alert = UIAlertController(title: "", message: "Please don't let your location and your link empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setToGeocoding(_ isGeocoding: Bool) {
        
        if isGeocoding {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        addLocationTextField.isEnabled = !isGeocoding
        addLinkTextField.isEnabled = !isGeocoding
        findLocationButton.isEnabled = !isGeocoding
        
    }
    
    func showPostFailure(message: String) {
        
        let alert = UIAlertController(title: "Post Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            self.mapView.isHidden = true
            self.finishButton.isHidden = true
            self.addLinkTextField.isHidden = false
            self.addLocationTextField.isHidden = false
            self.findLocationButton.isHidden = false
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        
        let address = addLocationTextField.text
        let mediaURL = addLinkTextField.text
        if let address = address, let mediaURL = mediaURL {
            OTMClient.postStudentLocation(uniqueKey: OTMClient.Auth.userId, firstName: OTMClient.Auth.firstName, lastName: OTMClient.Auth.lastName, mapString: address, mediaURL: mediaURL, latitude: latitude, longitude: longitude) { (success, error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.showPostFailure(message: "The data couldn't upload to server, please try again.")
                    }
                }
                
                if success {
                    
                    self.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "toMapVC", sender: nil)
                }
            }
        }
    }
}

extension InformationPostingViewController: MKMapViewDelegate {
    
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
}

extension InformationPostingViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}
