//
//  DetailViewController.swift
//  VisitorList
//
//  Created by yunus emre vural on 3.10.2022.
//

import UIKit
import PhotosUI
import CoreData

//class DetailViewController: UIViewController, PHPickerViewController, PHPickerViewControllerDelegate {
class DetailViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var chosenName = ""
    
    var chosenId   : UUID?
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        saveButton.isEnabled = true
        // The client is responsible for presentation and dismissal
        picker.dismiss (animated: true)
        
        // Get the first item provider from the results
        let itemProvider = results.first?.itemProvider
        
        // Access the UIImage representation for the result
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) {  image, error in
                if let image = image as? UIImage {
                    // Do something with the UIImage
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if chosenName != ""{
            //CoreData
            
            //saveButton.isEnabled = true
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DB")
            
            let idString = chosenId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try   context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]
                    {
                        if let name = result.value(forKey: "name") as? String{
                            nameTextField.text = name}
                        
                        if let job = result.value(forKey: "job") as? String{
                            jobTextField.text = job}
                        
                        if let date = result.value(forKey: "date") as? Date{
                            
                            // Create Date
                            //let dateConv = Date()
                            
                            // Create Date Formatter
                            let dateFormatter = DateFormatter()
                            
                            // Set Date Format
                            dateFormatter.dateFormat = "dd.MM.yyyy"
                            
                            // Convert Date to String
                            let varConv = dateFormatter.string(from: date)
                            
                            dateTextField.text = varConv}
                        
                        
                        if let image = result.value(forKey: "image") as? Data{
                            
                            let image = UIImage(data: image)
                            
                            imageView.image = image
                            
                        }
                    }
                    
                }
                
            }catch{
                
            }
            
        } else{
            saveButton.isEnabled = false
            
        }
        
        let keyboardTapRecognizer = UITapGestureRecognizer(target: self, action: #selector (hideKeyboard))
        
        view.addGestureRecognizer(keyboardTapRecognizer)
        
        imageView.isUserInteractionEnabled = true
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
        
    }
    
    @objc func selectImage(){
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = self
        
        present(picker, animated: true)
        
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let newValues = NSEntityDescription.insertNewObject(forEntityName: "DB", into: context)
        
        newValues.setValue(nameTextField.text!, forKey: "name")
        
        newValues.setValue(jobTextField.text!, forKey: "job")
        
        //let date = NSDate()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let dateString = dateFormatter.date(from: dateTextField.text!)
        
        newValues.setValue(dateString, forKey: "date")
        
        newValues.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newValues.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
