//
//  ViewController.swift
//  OCR
//
//  Created by Audhy Virabri Kressa on 07/07/20.
//  Copyright © 2020 Audhy Virabri Kressa. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController {
    
    @IBOutlet weak var IDImage: UIImageView!
    @IBOutlet weak var scanButton: UIButton!
    private var ocrRequest = VNRecognizeTextRequest(completionHandler: nil)
    var data = [String]()
    @IBOutlet weak var nik: UITextField!
    @IBOutlet weak var nama: UITextField!
    @IBOutlet weak var jenisKelamin: UITextField!
    @IBOutlet weak var alamat: UITextField!
    @IBOutlet weak var agama: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var kewarganegaraan: UITextField!
    @IBOutlet weak var berlaku: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)
        configureOCR()
        
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
                
                let sayHello = topCandidate.string
                let result = sayHello.components(separatedBy: ":")
                for x in result {
                    if x != "" {
                        self.data.append(x)
                    }
                }
            }
            
            if self.data[11] == "Alamat"{
                self.data.insert("-", at: 11)
            }
            
            DispatchQueue.main.async {
                if self.data.count > 3 {
                    self.nik.text = self.data[3]
                }
                if self.data.count > 5 {
                    self.nama.text = self.data[5]
                }
                if self.data.count > 9 {
                    self.jenisKelamin.text = self.data[9]
                }
                if self.data.count > 13 {
                    self.alamat.text = self.data[13]
                }
                if self.data.count > 21 {
                    self.agama.text = self.data[21]
                }
                if self.data.count > 23 {
                    self.status.text = self.data[23]
                }
                if self.data.count > 27 {
                    self.kewarganegaraan.text = self.data[27]
                }
                if self.data.count > 30 {
                    self.berlaku.text = self.data[30]
                }

                for y in self.data {
                    print(y)
                }
                self.scanButton.isEnabled = true
            }
        }
        
        ocrRequest.recognitionLevel = .accurate 
        ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
        ocrRequest.usesLanguageCorrection = true
    }
    
    
    
}

extension ViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        let image = scan.imageOfPage(at: scan.pageCount-1)
        
        guard let noirImage = image.noir else{
            return
        }
        
        IDImage.image = noirImage
        processImage(noirImage)
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

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}
