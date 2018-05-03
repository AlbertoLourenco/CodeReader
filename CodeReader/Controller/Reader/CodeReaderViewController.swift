//
//  CodeReaderViewController.swift
//  CodeReader
//
//  Created by Alberto Lourenço on 22/03/18.
//  Copyright © 2018 Alberto Lourenço. All rights reserved.
//

import UIKit
import MapKit
import Contacts
import MessageUI
import EventKitUI
import ContactsUI
import CoreLocation
import AVFoundation
import SafariServices

enum CodeReaderType {
	case url
	case sms
	case mail
	case vcard
	case event
	case undefined
	case geolocation
}

protocol CodeReaderDelegate {
	func codeReaderDidCancel()
	func codeReaderDidFail(controller: CodeReaderViewController)
	func codeReaderDidGetQRCode(controller: CodeReaderViewController, type: CodeReaderType, value: Any?)
	func codeReaderDidGetBarcode(controller: CodeReaderViewController, code: String)
}

class CodeReaderViewController: UIViewController,
								AVCaptureMetadataOutputObjectsDelegate,
								MFMailComposeViewControllerDelegate,
								MFMessageComposeViewControllerDelegate,
								SFSafariViewControllerDelegate,
								CNContactViewControllerDelegate,
								EKEventEditViewDelegate {
	
	private var delegate: CodeReaderDelegate!
	
	private var readerStoryboard = UIStoryboard(name: "CodeReader",
												bundle: Bundle(for: CodeReaderViewController.classForCoder()))
	
	private var isLoading: Bool = false
	private var cachedCameraSize: CGSize = .zero
	
	private var session: AVCaptureSession?
	private var camera = AVCaptureVideoPreviewLayer()
	private let device = AVCaptureDevice.default(for: AVMediaType.video)
	private var connection: AVCaptureConnection?
	
	//	UI elements
	
	@IBOutlet weak private var lblTitle: UILabel?
	@IBOutlet weak private var lblSubtitle: UILabel?
	
	@IBOutlet weak private var vwCamera: UIView?
	@IBOutlet weak private var vwTopbar: UIVisualEffectView?
	
	@IBOutlet weak private var imgCameraFrame: UIImageView?
	@IBOutlet weak private var constraintHeightNavbar: NSLayoutConstraint?
	
	//-----------------------------------------------------------------------
	//	MARK: - UIViewController
	//-----------------------------------------------------------------------
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.configUI()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if UIDevice().screenModel() == .iPhone_X {
			self.constraintHeightNavbar?.constant = 120
			self.view.layoutIfNeeded()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		isLoading = false
		
		self.startScanning()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.stopScanning()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if let connection = self.connection {
			
			let currentDevice: UIDevice = UIDevice.current
			let orientation: UIDeviceOrientation = currentDevice.orientation
			let previewLayerConnection : AVCaptureConnection = connection
			
			if previewLayerConnection.isVideoOrientationSupported {
				
				switch (orientation) {
					
				case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
					break
					
				case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
					break
					
				case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
					break
					
				case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
					break
					
				default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
					break
				}
			}
		}
	}
	
	private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
		layer.videoOrientation = orientation
		camera.frame = self.view.bounds
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - Custom methods
	//-----------------------------------------------------------------------
	
	public func instantiate(delegate: CodeReaderDelegate) -> CodeReaderViewController {
		let codeReaderVC = readerStoryboard.instantiateViewController(withIdentifier: "CodeReaderView") as! CodeReaderViewController
		codeReaderVC.delegate = delegate
		return codeReaderVC
	}
	
	private func configUI() {
		self.lblTitle?.text = CodeReaderConfig.title
		self.lblSubtitle?.text = CodeReaderConfig.subtitle
		self.navigationController?.navigationBar.isHidden = true
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
											   name: NSNotification.Name.init("ApplicationDidBecomeActive"),
											   object: nil)
	}
	
	private func stopScanning() {
		session?.stopRunning()
	}
	
	private func startScanning() {
		
		if let captureDevice = device, session == nil {
			
			session = AVCaptureSession()
			
			do {
				let input = try AVCaptureDeviceInput(device: captureDevice)
				session?.addInput(input)
			}catch{
				print(error)
			}
			
			let output = AVCaptureMetadataOutput()
			session?.addOutput(output)
			
			output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13,
										  AVMetadataObject.ObjectType.ean8,
										  AVMetadataObject.ObjectType.qr,
										  AVMetadataObject.ObjectType.aztec,
										  AVMetadataObject.ObjectType.code128,
										  AVMetadataObject.ObjectType.code39,
										  AVMetadataObject.ObjectType.code93,
										  AVMetadataObject.ObjectType.code39Mod43,
										  AVMetadataObject.ObjectType.dataMatrix,
										  AVMetadataObject.ObjectType.pdf417,
										  AVMetadataObject.ObjectType.upce,
										  AVMetadataObject.ObjectType.itf14,
										  AVMetadataObject.ObjectType.interleaved2of5]
			
			camera = AVCaptureVideoPreviewLayer(session: session!)
			camera.frame = UIScreen.main.bounds
			camera.videoGravity = AVLayerVideoGravity.resizeAspectFill
			
			connection = camera.connection
			
			self.vwCamera?.layer.addSublayer(camera)
		}
		
		session?.startRunning()
	}
	
	private func handleManually(_ stringValue: String) {
		
		//----------------------------
		//	VCard
		//----------------------------
		
		if let contact = Parser.parseContact(stringValue) {
			self.delegate.codeReaderDidGetQRCode(controller: self, type: .vcard, value: contact)
			return
		}
		
		//----------------------------
		//	SMS
		//----------------------------
		
		if let sms = Parser.parseSMS(stringValue) {
			self.delegate.codeReaderDidGetQRCode(controller: self, type: .sms, value: sms)
			return
		}
		
		//----------------------------
		//	Event
		//----------------------------
		
		if let tuple = Parser.parseEvent(stringValue), let event = tuple.event {
			self.delegate.codeReaderDidGetQRCode(controller: self, type: .event, value: event)
			return
		}
		
		//----------------------------
		//	Geolocation
		//----------------------------
		
		if let geolocation = Parser.parseLocation(stringValue) {
			self.delegate.codeReaderDidGetQRCode(controller: self, type: .geolocation, value: geolocation)
			return
		}
		
		//----------------------------
		//	Mail to
		//----------------------------
		
		if let mail = Parser.parseMail(stringValue) {
			self.delegate.codeReaderDidGetQRCode(controller: self, type: .mail, value: mail)
			return
		}
		
		//----------------------------
		//	URL
		//----------------------------
		
		if let url = Parser.parseURL(stringValue) {
			self.delegate.codeReaderDidGetQRCode(controller: self, type: .url, value: url)
			return
		}
		
		//----------------------------
		//	None of the above worked
		//----------------------------
		
		self.delegate.codeReaderDidGetQRCode(controller: self, type: .undefined, value: stringValue)
	}
	
	private func handleAutomatically(_ stringValue: String) {
		
		//----------------------------
		//	VCard
		//----------------------------
		
		if let contact = Parser.parseContact(stringValue) {
			guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { return }
			let contactVC = CNContactViewController(forNewContact: mutableContact)
			contactVC.contactStore = CNContactStore()
			contactVC.delegate = self
			let navVC = UINavigationController(rootViewController: contactVC)
			present(navVC, animated: true, completion: nil)
		}
		
		//----------------------------
		//	SMS
		//----------------------------
		
		if let sms = Parser.parseSMS(stringValue) {
			if MFMessageComposeViewController.canSendText() {
				let composeVC = MFMessageComposeViewController()
				composeVC.messageComposeDelegate = self
				composeVC.recipients = sms.phones
				composeVC.body = sms.message
				present(composeVC, animated: true, completion: nil)
			}
		}
		
		//----------------------------
		//	Event
		//----------------------------
		
		if let tuple = Parser.parseEvent(stringValue), let event = tuple.event, let store = tuple.store {
			store.requestAccess(to: EKEntityType.event) { (granted, error) in
				if granted && error == nil {
					let calendarVC = EKEventEditViewController()
					calendarVC.event = event
					calendarVC.eventStore = store
					calendarVC.editViewDelegate = self
					self.present(calendarVC, animated: true)
				}
			}
		}
		
		//----------------------------
		//	Geolocation
		//----------------------------
		
		if let geolocation = Parser.parseLocation(stringValue) {
			let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: geolocation.coordinate, addressDictionary: nil))
			mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
		}
		
		//----------------------------
		//	Mail to
		//----------------------------
		
		if let mail = Parser.parseMail(stringValue) {
			if MFMailComposeViewController.canSendMail() {
				let mailVC = MFMailComposeViewController()
				mailVC.mailComposeDelegate = self
				mailVC.setToRecipients(mail.recipients)
				mailVC.setSubject(mail.subject)
				mailVC.setMessageBody(mail.message, isHTML: mail.message.contains("<") && mail.message.contains(">"))
				present(mailVC, animated: true, completion: nil)
			}
		}
		
		//----------------------------
		//	URL
		//----------------------------
		
		if let url = Parser.parseURL(stringValue) {
			let safariVC = SFSafariViewController(url: url)
			safariVC.delegate = self
			present(safariVC, animated: true, completion: nil)
		}
		
		//----------------------------
		//	Handle string
		//----------------------------
		
		self.handleManually(stringValue)
	}
	
	@objc private func applicationDidBecomeActive() {
		isLoading = false
	}
	
	@IBAction private func dismiss(sender: UIButton?) {
		
		if sender != nil {
			self.delegate.codeReaderDidCancel()
		}
		self.dismiss(animated: true, completion: nil)
	}
}

extension CodeReaderViewController {
	
	//-----------------------------------------------------------------------
	//	MARK: - EKEventEditViewController Delegate
	//-----------------------------------------------------------------------
	
	func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
		controller.dismiss(animated: true)
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - CNContactViewController Delegate
	//-----------------------------------------------------------------------
	
	func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
		viewController.dismiss(animated: true, completion: nil)
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - SFSafariViewController Delegate
	//-----------------------------------------------------------------------
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true)
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - MFMessageComposeViewController Delegate
	//-----------------------------------------------------------------------
	
	func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
		controller.dismiss(animated: true)
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - MFMailComposeViewController Delegate
	//-----------------------------------------------------------------------
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - AVCaptureMetadataOutputObjects Delegate
	//-----------------------------------------------------------------------
	
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		
		if isLoading {
			return
		}
		
		isLoading = true
		
		if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
			
			//----------------------------
			//	QRCode
			//----------------------------
			
			if object.type == AVMetadataObject.ObjectType.qr {
				
				guard let stringValue = object.stringValue else {
					self.delegate.codeReaderDidFail(controller: self)
					return
				}
				
				print("CodeReader: \(stringValue)")
				
				if CodeReaderConfig.handleAutomatically {
					self.handleAutomatically(stringValue)
				}else{
					self.handleManually(stringValue)
				}
			}else{
				
				//----------------------------
				//	Barcode
				//----------------------------
				
				if let stringValue = object.stringValue {
					self.delegate.codeReaderDidGetBarcode(controller: self, code: stringValue)
				}else{
					self.delegate.codeReaderDidFail(controller: self)
				}
			}
		}else{
			isLoading = false
			self.delegate.codeReaderDidFail(controller: self)
		}
	}
}
