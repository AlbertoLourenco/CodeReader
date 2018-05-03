//
//  Parser.swift
//  CodeReader
//
//  Created by Alberto Lourenço on 28/03/18.
//  Copyright © 2018 Alberto Lourenço. All rights reserved.
//

import Foundation
import Contacts
import EventKit
import CoreLocation

internal struct Parser {
	
	//-------------------------
	//	Mail
	//-------------------------
	
	static func parseMail(_ stringValue: String) -> CodeReaderMail? {
		
		if stringValue.contains("MATMSG:TO:") {
			
			var aux = stringValue.replacingOccurrences(of: "MATMSG:TO:", with: "")
			aux = aux.replacingOccurrences(of: ";SUB:", with: "-*-")
			aux = aux.replacingOccurrences(of: ";BODY:", with: "-*-")
			aux = aux.replacingOccurrences(of: ";", with: "")
			
			let array = aux.components(separatedBy: "-*-")
			
			if array.count == 3 {
				
				var mailTo: Array<String> = []
				
				let subject: String = array[1]
				let message: String = array[2]
				
				if let emails = array.first {
					
					let emailsTrimSpace = emails.replacingOccurrences(of: " ", with: "")
					
					if emailsTrimSpace.contains(",") {
						mailTo = emailsTrimSpace.components(separatedBy: ",")
					}else{
						mailTo = [array[0]]
					}
					
					return CodeReaderMail(recipients: mailTo, subject: subject, message: message)
				}
			}
		}
		
		return nil
	}
	
	//-------------------------
	//	URL
	//-------------------------
	
	static func parseURL(_ stringValue: String) -> URL? {
		if stringValue.contains("http"), let url = URL(string: stringValue) {
			return url
		}
		return nil
	}
	
	//-------------------------
	//	SMS
	//-------------------------
	
	static func parseSMS(_ stringValue: String) -> CodeReaderSMS? {
		
		if stringValue.contains("SMSTO:") || stringValue.contains("sms:") {
			
			var aux = stringValue.replacingOccurrences(of: "SMSTO:", with: "")
			aux = aux.replacingOccurrences(of: "sms:", with: "")
			let array = aux.components(separatedBy: ":")
			
			var smsTo: Array<String> = []
			
			let phones: String = array[0]
			let message: String = (array.count == 2) ? array[1] : ""
			
			let phonesTrimSpace = phones.replacingOccurrences(of: " ", with: "")
			
			if phonesTrimSpace.contains(",") {
				smsTo = phonesTrimSpace.components(separatedBy: ",")
			}else{
				smsTo = [array[0]]
			}
			
			return CodeReaderSMS(phones: smsTo, message: message)
		}
		
		return nil
	}
	
	//-------------------------
	//	Event
	//-------------------------
	
	static func parseEvent(_ stringValue: String) -> (event: EKEvent?, store: EKEventStore?)? {
		
		if stringValue.contains("BEGIN:VEVENT") && stringValue.contains("END:VEVENT") {
			
			let array = stringValue.components(separatedBy: "\n")
			
			var summary: String = ""
			var endString: String = ""
			var startString: String = ""
			
			for value in array {
				if value.contains("SUMMARY:") {
					summary = value.replacingOccurrences(of: "SUMMARY:", with: "")
				}else
					if value.contains("DTEND:") {
						endString = value.replacingOccurrences(of: "DTEND:", with: "")
						endString = endString.replacingOccurrences(of: "T", with: " ")
						endString = endString.replacingOccurrences(of: "Z", with: "")
					}else
						if value.contains("DTSTART:") {
							startString = value.replacingOccurrences(of: "DTSTART:", with: "")
							startString = startString.replacingOccurrences(of: "T", with: " ")
							startString = startString.replacingOccurrences(of: "Z", with: "")
				}
			}
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyyMMdd HHmmss"
			
			if let startDate = dateFormatter.date(from: startString),
				let endDate = dateFormatter.date(from: endString) {
				
				let store = EKEventStore()
				let event = EKEvent(eventStore: store)
				
				event.title = summary
				event.startDate = startDate
				event.endDate = endDate
				
				return (event, store)
			}
		}
		
		return nil
	}
	
	//-------------------------
	//	VCard
	//-------------------------
	
	static func parseContact(_ stringValue: String) -> CNContact? {
		if stringValue.contains("VCARD"), let data = stringValue.data(using: .utf8) {
			let contacts = try? CNContactVCardSerialization.contacts(with: data)
			if let array = contacts, let contact = array.first {
				return contact
			}
		}
		return nil
	}
	
	//-------------------------
	//	Geolocation
	//-------------------------
	
	static func parseLocation(_ stringValue: String) -> CLLocation? {
		
		if stringValue.contains("GEO:") || stringValue.contains("geo:") {
			
			var aux = stringValue.replacingOccurrences(of: "GEO:", with: "")
			aux = aux.replacingOccurrences(of: "geo:", with: "")
			
			let array = aux.components(separatedBy: ",")
			
			if array.count == 2, let latitude = Double(array[0]), let longitude = Double(array[1]) {
				return CLLocation.init(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
			}
		}
		
		return nil
	}
}
