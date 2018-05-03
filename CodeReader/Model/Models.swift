//
//  Models.swift
//  CodeReader
//
//  Created by Alberto Lourenço on 28/03/18.
//  Copyright © 2018 Alberto Lourenço. All rights reserved.
//

import Foundation
import MessageUI

//--------------------------------
//	Mail
//--------------------------------

struct CodeReaderMail {
	
	let recipients: Array<String>
	let subject: String
	let message: String
	
	init(recipients: Array<String>, subject: String, message: String) {
		self.recipients = recipients
		self.subject = subject
		self.message = message
	}
}

//--------------------------------
//	SMS
//--------------------------------

struct CodeReaderSMS {
	
	let phones: Array<String>
	let message: String
	
	init(phones: Array<String>, message: String) {
		self.phones = phones
		self.message = message
	}
}

//--------------------------------
//	Config
//--------------------------------

struct CodeReaderConfig {
	
	static var viewRadius: CGFloat = 5
	static var buttonRadius: CGFloat = 22.5
	
	static var handleAutomatically: Bool = false
	static var tintColor: UIColor = UIColor(red:0.19, green:0.20, blue:0.42, alpha:1.0)
	
	static var title: String = "Code Reader"
	static var subtitle: String = "Align your code into the camera frame"
}
