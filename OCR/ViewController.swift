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
    var similarity = [Similarity]()
    let threshold = 0.8
    @IBOutlet weak var nik: UITextField!
    @IBOutlet weak var nama: UITextField!
    @IBOutlet weak var jenisKelamin: UITextField!
    @IBOutlet weak var alamat: UITextField!
    @IBOutlet weak var agama: UITextField!
    @IBOutlet weak var status: UITextField!
    @IBOutlet weak var kewarganegaraan: UITextField!
    @IBOutlet weak var berlaku: UITextField!
    
    struct Similarity {
        var name: String
        var value: Double
    }
    
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
                let nikIndex = self.data.indices.filter {self.data[$0] == "NIK"}
                if nikIndex.count > 0 && nikIndex.count > 0 {
                    self.nik.text = self.data[nikIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "NIK")
                    self.nik.text = metchingWord
                }
                let namaIndex = self.data.indices.filter {self.data[$0] == "Nama"}
                if namaIndex.count > 0 && self.data.count > namaIndex[0]+1 {
                    self.nama.text = self.data[namaIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "Nama")
                    self.nama.text = metchingWord
                }
                let jkIndex = self.data.indices.filter {self.data[$0] == "Jenis Kelamin"}
                if jkIndex.count > 0 && self.data.count > jkIndex[0]+1 {
                    self.jenisKelamin.text = self.data[jkIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "Jenis Kelamin")
                    self.jenisKelamin.text = metchingWord
                    
                }
                let alamatIndex = self.data.indices.filter {self.data[$0] == "Alamat"}
                if alamatIndex.count > 0 && self.data.count > alamatIndex[0]+1 {
                    self.alamat.text = self.data[alamatIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "Alamat")
                    self.alamat.text = metchingWord
                }
                let agamaIndex = self.data.indices.filter {self.data[$0] == "Agama"}
                if agamaIndex.count > 0 && self.data.count > agamaIndex[0]+1 {
                    self.agama.text = self.data[agamaIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "Agama")
                    self.agama.text = metchingWord
                }
                let statusIndex = self.data.indices.filter {self.data[$0] == "Status Perkawinan"}
                if statusIndex.count > 0 && self.data.count > statusIndex[0]+1 {
                    self.status.text = self.data[statusIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "Status Perkawinan")
                    self.status.text = metchingWord
                }
                let kewarganegaraanIndex = self.data.indices.filter {self.data[$0] == "Kewarganegaraan"}
                if kewarganegaraanIndex.count > 0 && self.data.count > kewarganegaraanIndex[0]+1 {
                    self.kewarganegaraan.text = self.data[kewarganegaraanIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "Kewarganegaraan")
                    self.kewarganegaraan.text = metchingWord
                }
                let berlakuIndex = self.data.indices.filter {self.data[$0] == "Berlaku Hingga"}
                if berlakuIndex.count > 0 && self.data.count > berlakuIndex[0]+1 {
                    self.berlaku.text = self.data[berlakuIndex[0]+1]
                }else{
                    let metchingWord = self.matching(title: "Berlaku Hingga")
                    self.berlaku.text = metchingWord
                }
//                for y in self.data {
//                    print(y)
//                }
                self.scanButton.isEnabled = true
            }
        }
        
        ocrRequest.recognitionLevel = .accurate 
        ocrRequest.recognitionLanguages = ["en-US", "en-GB"]
        ocrRequest.usesLanguageCorrection = true
    }
    
    func matching(title: String) -> String{
        for x in self.data {
            let jr = title.distance(between: x)
            if jr > 0.7 {
                self.similarity.append(Similarity(name: x, value: jr))
            }
        }
        if self.similarity.count > 0 {
            let max = self.similarity.sorted(by: {$1.value < $0.value})
            let result = self.similarity.filter { $0.value == max[0].value }.first
            let similarWord = self.data.indices.filter {self.data[$0] == result?.name}
            if self.similarity.count > 0 {
                let result = self.data[similarWord[0]+1]
                self.similarity.removeAll()
                return(result)
            }
        }
        self.similarity.removeAll()
        return ""
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
