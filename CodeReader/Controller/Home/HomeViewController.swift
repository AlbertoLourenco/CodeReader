//
//  HomeViewController.swift
//  CodeReader
//
//  Created by Alberto Lourenço on 23/03/18.
//  Copyright © 2018 Alberto Lourenço. All rights reserved.
//

import UIKit
import Contacts
import EventKit
import CoreLocation

class HomeViewController: UIViewController, CodeReaderDelegate {
	
	@IBOutlet private weak var lblCode: UILabel?
	
	//-----------------------------------------------------------------------
	//	MARK: - UIViewController
	//-----------------------------------------------------------------------
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.lblCode?.text = ""
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - CodeReader Delegate
	//-----------------------------------------------------------------------
	
	func codeReaderDidCancel() {
		// when user close CodeReader
	}
	
	func codeReaderDidFail(controller: CodeReaderViewController) {
		// when camera doesn't detect a QRCode or Barcode
	}
	
	func codeReaderDidGetQRCode(controller: CodeReaderViewController, type: CodeReaderType, value: Any?) {
		
		if !CodeReaderConfig.handleAutomatically {
			controller.dismiss(animated: true, completion: nil)
		}
		
		switch type {
			case .undefined:
				if let string = value as? String {
					self.lblCode?.text = string
				}
				break
			case .url:
				if let url = value as? URL {
					self.lblCode?.text = url.absoluteString
				}
				break
			case .sms:
				if let sms = value as? CodeReaderSMS {
					self.lblCode?.text = String(describing: sms)
				}
				break
			case .mail:
				if let mail = value as? CodeReaderMail {
					self.lblCode?.text = String(describing: mail)
				}
				break
			case .vcard:
				if let contact = value as? CNContact {
					self.lblCode?.text = String(describing: contact)
				}
				break
			case .event:
				if let event = value as? EKEvent {
					self.lblCode?.text = String(describing: event)
				}
				break
			case .geolocation:
				if let location = value as? CLLocation {
					self.lblCode?.text = String(describing: location)
				}
				break
		}
	}
	
	func codeReaderDidGetBarcode(controller: CodeReaderViewController, code: String) {
		controller.dismiss(animated: true, completion: nil)
		
		self.lblCode?.text = code
	}
	
	//-----------------------------------------------------------------------
	//	MARK: - Custom methods
	//-----------------------------------------------------------------------
	
	@IBAction func handleAutomatically() {
		CodeReaderConfig.handleAutomatically = true
		self.showCodeReader()
	}
	
	@IBAction func handleManually() {
		CodeReaderConfig.handleAutomatically = false
		self.showCodeReader()
	}
	
	private func showCodeReader() {
		let codeReaderVC = CodeReaderViewController().instantiate(delegate: self)
		self.present(codeReaderVC, animated: true, completion: nil)
	}
}
