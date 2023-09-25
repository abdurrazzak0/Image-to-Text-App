//
//  ViewController.swift
//  Image to Text App
//
//  Created by Abdur Razzak on 25/9/23.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var actiVityIndicator: UIActivityIndicatorView!
    
    var request = VNRecognizeTextRequest(completionHandler: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        stopanimating()
    }
   private func starAnimating() {
       self.actiVityIndicator.startAnimating()
    }
    func stopanimating() {
        self.actiVityIndicator.stopAnimating()
    }
    
    @IBAction func TouchUpInsideCameraButton(_ sender: Any) {
        setupGallery()
    }
    private func setupGallery(){
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            let imagePhotoLibraryPicker = UIImagePickerController()
            imagePhotoLibraryPicker.delegate = self
            imagePhotoLibraryPicker.allowsEditing = true
            imagePhotoLibraryPicker.sourceType = .photoLibrary
            self.present(imagePhotoLibraryPicker, animated: true, completion: nil)
        }
    }
    private func setupVisionTextReconizeImage(image: UIImage?){
        
        var textString = ""
        
        request = VNRecognizeTextRequest(completionHandler: {(request,error) in
            
            guard let observation = request.results as? [VNRecognizedTextObservation] else {fatalError("Receved Invalid Observation")}
            for observation in observation {
                guard let topCandidate = observation.topCandidates(1).first else{
                    print("No Candidate")
                    continue
                }
                
                textString += "/n\(topCandidate.string)"
                DispatchQueue.main.async{
                    self.stopanimating()
                    self.textView.text = textString
                }
            }
        })
        
        request.customWords = ["Coustom"]
        request.minimumTextHeight = 0.03125
        request.recognitionLanguages = ["en_US"]
        request.usesLanguageCorrection = true
        
        let requests = [request]
        
        DispatchQueue.global(qos: .userInitiated).async{
            
            guard let img = image?.cgImage else {fatalError("Missing Image to scan")}
            let handle = VNImageRequestHandler(cgImage: img,options:[:])
            try? handle.perform(requests)
            
        }
    }
}
extension ViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true,completion: nil)
        
        starAnimating()
        self.textView.text = ""
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imageView.image = image
        
        setupVisionTextReconizeImage(image: image)
    }
}
