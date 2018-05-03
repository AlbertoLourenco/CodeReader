//
//  Extensions.swift
//  CodeReader
//
//  Created by Alberto Lourenço on 22/03/18.
//  Copyright © 2018 Alberto Lourenço. All rights reserved.
//

import UIKit

extension UIDevice {
	
	enum ScreenModel {
		
		case unknown
		case iPhone_4 		// iPhone 4 and 4S
		case iPhone_5 		// iPod Touch, iPhone 5, 5C, 5S and SE
		case iPhone_8 		// iPhone 6, 6S, 7 and 8
		case iPhone_Plus 	// iPhone 6 Plus, 7 Plus and 8 Plus
		case iPhone_X
		case iPad
	}
	
	func screenModel() -> ScreenModel {
		
		let w: Double = Double(UIScreen.main.bounds.width)
		let h: Double = Double(UIScreen.main.bounds.height)
		let screenHeight: Double = max(w, h)
		
		switch screenHeight {
			
		case 480:
			return .iPhone_4
			
		case 568:
			return .iPhone_5
			
		case 667:
			return UIScreen.main.scale == 3.0 ? .iPhone_Plus : .iPhone_8
			
		case 736:
			return .iPhone_Plus
			
		case 812:
			return .iPhone_X
			
		default:
			return .iPad
		}
	}
}
