//
//  ScanViewController.swift
//  OCR
//
//  Created by Audhy Virabri Kressa on 23/07/20.
//  Copyright © 2020 Audhy Virabri Kressa. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ScanViewController: UIViewController {

    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    @IBOutlet weak var imageScan: UIImageView!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    var data = [String]()
    var appear =  true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureOCR()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if appear {
            scanDocument()
        }
        
        appear = false
    }

    @IBAction func retake(_ sender: UIButton) {
        scanDocument()
    }
    @objc private func scanDocument() {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        scanButton.isEnabled = false
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    private func configureOCR() {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                
//                let sayHello = topCandidate.string
//                let result = sayHello.components(separatedBy: ":")
//                for x in topCandidate.string {
                    self.data.append(topCandidate.string)
//                }
            }
            
            
            DispatchQueue.main.async {
                print(self.data)
                
                var text = ""
                
                for x in self.data {
                    text = text+" "+x
                }
                
                print(text)
                self.result.text = text
                self.scanButton.isEnabled = true
            }
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
        ocrRequest.usesLanguageCorrection = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ScanViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        print("ss")
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        let image = scan.imageOfPage(at: scan.pageCount-1)
        
//        guard let noirImage = image.noir else{
//            return
//        }
        
        imageScan.image = image
        processImage(image)
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}

