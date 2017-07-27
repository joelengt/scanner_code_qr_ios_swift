//
//  FaceViewController.swift
//  QRCodeReader
//
//  Created by joel gonzales tipismana on 7/26/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit

typealias Parameters = [String: String]

class FaceViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var loderMessage: UILabel!
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBAction func importImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true) {
            // After it is complete
        }
    }

    // upload photo
    @IBAction func uploadPhotoButton(_ sender: Any) {
        if (self.myImageView.image == nil) {
            loderMessage.text = "Import a photo first!"
            return;
        }
        
        loderMessage.text = "Scanning..."
        
        print("Event post")
        let parameters = ["name": "MyTestFile123321",
                          "description": "My tutorial test file for MPFD uploads"]
        
        let imageData = myImageView.image
        print(imageData!)
        
        guard let mediaImage = Media(withImage: imageData!, forKey: "photo") else { return }
        
        print("--------")
        print(mediaImage)
        print("--------")
        
        guard let url = URL(string: "http://138.197.121.244:3000/api/verify-face/check-face") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundary()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Client-ID f65203f7020dddc", forHTTPHeaderField: "Authorization")
        
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("first!!")
                print(response)
            }
        
            var messages = [String]()
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let message = json["message"] as? String {
                    messages.append(message)
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            self.loderMessage.text = messages[0]
            print("Message >>>>>>")
            print(messages[0])
            print("Message <<<<<<")
            
        }.resume()

    }
    
    // image picker function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImageView.image = image
        } else {
            // Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


