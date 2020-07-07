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
        
        //        ocrTextView.text = ""
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
            
//            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }

                let sayHello = topCandidate.string
                let result = sayHello.components(separatedBy: ":")
//                print(result)
                for x in result {
                    if x != "" {
                        self.data.append(x)
                    }
                }
//                ocrText += topCandidate.string + "\n"
//                self.data.append(topCandidate.string.replacingOccurrences(of: ":", with: ""))
                
                //TODO coba split jika mengandung :
                //https://stackoverflow.com/questions/25678373/split-a-string-into-an-array-in-swift
            }
            
            
            DispatchQueue.main.async {
//                print(ocrText)
//                self.ocrTextView.text = ocrText
                self.nik.text = self.data[4]
                self.nama.text = self.data[6]
                self.jenisKelamin.text = self.data[10]
                self.alamat.text = self.data[14]
                self.agama.text = self.data[1]
                self.status.text = self.data[21]
                self.kewarganegaraan.text = self.data[23]
                self.berlaku.text = self.data[26]
//                print(self.data)
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
        
        let image = scan.imageOfPage(at: 0)
//        let noirImage = image.noir // noirImage is an optional UIImage (UIImage?)
        
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
