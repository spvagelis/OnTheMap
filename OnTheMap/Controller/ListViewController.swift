//
//  ListViewController.swift
//  OnTheMap
//
//  Created by vagelis spirou on 31/3/21.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listOfStudentLocation = [StudentInformation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "On the Map"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OTMClient.getStudentLocation { (studentLocations, error) in
            if error != nil {
                
                DispatchQueue.main.async {
                    self.showFailToGetStudentLocation(message: error?.localizedDescription ?? "")
                }
                
                return
                
            }
            
            self.listOfStudentLocation = studentLocations
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func showFailToGetStudentLocation(message: String) {
        
        let alert = UIAlertController(title: "Error with Student Location", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        OTMClient.getPublicUserData { (success, error) in
            
            if success {
                
                self.performSegue(withIdentifier: "fromListVCToInformationVC", sender: nil)
                
            }
        }
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        
        OTMClient.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        
        OTMClient.getStudentLocation { (studentLocations, error) in
            if error != nil {
                
                DispatchQueue.main.async {
                    self.showFailToGetStudentLocation(message: error?.localizedDescription ?? "")
                }
                
                return
                
            }

            self.listOfStudentLocation = studentLocations
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfStudentLocation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectedStudent = listOfStudentLocation[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = "\(selectedStudent.firstName) \(selectedStudent.lastName)"
        cell.imageView?.image = UIImage(systemName: "mappin.and.ellipse")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedStudent = listOfStudentLocation[indexPath.row]
        guard let url = URL(string: selectedStudent.mediaURL) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
    }
    
}
