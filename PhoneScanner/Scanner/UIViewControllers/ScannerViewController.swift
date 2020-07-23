//
//  ScannerViewController.swift
//  MedicineTracker
//
//  Created by Mohamed Emad on 6/30/20.
//  Copyright © 2020 Medicine Tracker. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Vision

// don't couple with some frame work just make abstract interface and then inject it.

class ScannerViewController: TextRecongnizerViewController {

    private var boxLayer = [CAShapeLayer]()
    private var textDetectionRequest: VNDetectTextRectanglesRequest?
    private var textObservations = [VNTextObservation]()
    private let numberTracker = StringTracker()
    private var tesseract = G8Tesseract(language: "eng", engineMode: .tesseractOnly)
    private var count = 0

    override func viewDidLoad() {
        if isAuthorized() {
            configureTextDetection()
        }
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }

    private func configureTextDetection() {
        textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: handleDetection)
        textDetectionRequest!.reportCharacterBoxes = true
    }

    private func handleDetection(request: VNRequest, error: Error?) {
        var redBoxes = [CGRect]()
        guard let detectionResults = request.results else {
            return
        }
        guard let textResults = detectionResults as? [VNTextObservation], !textResults.isEmpty else {
            return
        }
        textObservations = textResults
        guard let rect = textResults.max(by: { ($0.boundingBox.width) < ($1.boundingBox.width) })?.boundingBox else {
            return
        }
        redBoxes.append(rect)
        self.show(boxes: redBoxes)
    }

    // Draws groups of colored boxes.
    private func show(boxes: [CGRect]) {
        DispatchQueue.main.async {
            self.removeBoxes()
            for box in boxes {
                self.draw(originalRect: box)
            }
        }
    }

    private func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }

    private func draw (originalRect: CGRect) {
        let viewWidth = self.view.frame.size.width
        let viewHeight = self.view.frame.size.height
        let layer = CAShapeLayer()
        var rect = originalRect
        rect.origin.x *= viewWidth
        rect.size.height *= viewHeight
        rect.origin.y = ((1 - rect.origin.y) * viewHeight) - rect.size.height
        rect.size.width *= viewWidth
        layer.frame = rect
        layer.borderWidth = 2
        layer.borderColor = UIColor.red.cgColor
        boxLayer.append(layer)
        self.preview.videoPreviewLayer.insertSublayer(layer, at: 1)
    }

    private func isAuthorized() -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            self.requestAccessForCamera()
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        default:
            return false
        }
    }

    private func requestAccessForCamera() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) -> Void in
            if granted {
                DispatchQueue.main.async {
                    self.setupCamera()
                    self.configureTextDetection()
                }
            }
        })
    }

}

extension ScannerViewController {
    // MARK: - Camera Delegate and Setup
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var numbers = [String]()
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        textDetectionRequest?.regionOfInterest = regionOfInterest
        var imageRequestOptions = [VNImageOption: Any]()
        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            imageRequestOptions[.cameraIntrinsics] = cameraData
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
        do {
            try imageRequestHandler.perform([textDetectionRequest!])
        }
        catch {
            print("Error occured \(error)")
        }
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size
        for textObservation in textObservations {
            guard let rects = textObservation.characterBoxes else {
                continue
            }
            var xMin = CGFloat.greatestFiniteMagnitude
            var xMax: CGFloat = 0
            var yMin = CGFloat.greatestFiniteMagnitude
            var yMax: CGFloat = 0
            for rect in rects {
                xMin = min(xMin, rect.bottomLeft.x)
                xMax = max(xMax, rect.bottomRight.x)
                yMin = min(yMin, rect.bottomRight.y)
                yMax = max(yMax, rect.topRight.y)
            }
            let imageRect = CGRect(x: xMin * size.width, y: yMin * size.height, width: (xMax - xMin) * size.width, height: (yMax - yMin) * size.height)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
                continue
            }
            let uiImage = UIImage(cgImage: cgImage)
            tesseract?.image = uiImage
            let blackListedString = "@!#$%^&*(),.?~{};:\"\'\\abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let whiteListedString = "+-.0123456789"
            tesseract?.charBlacklist = blackListedString
            tesseract?.charWhitelist = whiteListedString
            tesseract?.recognize()

            guard var text = tesseract?.recognizedText else {
                continue
            }
            text = text.trimmingCharacters(in: CharacterSet.newlines)
            if let result = text.extractPhoneNumber() {
                numbers.append(result.1)
            }
            count += 1
            print("here is the loging \(count)")
            numberTracker.logFrame(strings: numbers)
            if let sureNumber = numberTracker.getStableString() {
                numberTracker.reset(string: sureNumber)
                stopRunning()
                self.phoneNumber = sureNumber
                self.showResultView()
            }
        }
        textObservations.removeAll()
    }

}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
}

