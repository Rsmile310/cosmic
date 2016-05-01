/*
* Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*	*	Redistributions of source code must retain the above copyright notice, this
*		list of conditions and the following disclaimer.
*
*	*	Redistributions in binary form must reproduce the above copyright notice,
*		this list of conditions and the following disclaimer in the documentation
*		and/or other materials provided with the distribution.
*
*	*	Neither the name of GraphKit nor the names of its
*		contributors may be used to endorse or promote products derived from
*		this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
The following is an example of using a SearchBarController to control the
flow of your application.
*/

import UIKit
import Material

class AppSearchBarController: SearchBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		prepareView()
		prepareSearchBar()
	}
	
	/// Loads the BlueViewController into the searchBarControllers rootViewController.
	func handleBlueButton() {
		if rootViewController is BlueViewController {
			return
		}
		transitionFromRootViewController(BlueViewController(), options: [.TransitionCrossDissolve])
	}
	
	/// Loads the GreenViewController into the searchBarControllers rootViewController.
	func handleGreenButton() {
		if rootViewController is GreenViewController {
			return
		}
		transitionFromRootViewController(GreenViewController(), options: [.TransitionCrossDissolve])
	}
	
	/// Loads the YellowViewController into the searchBarControllers rootViewController.
	func handleYellowButton() {
		if (rootViewController as? ToolbarController)?.rootViewController is YellowViewController {
			return
		}
		transitionFromRootViewController(YellowViewController(), options: [.TransitionCrossDissolve])
		searchBar.textField.resignFirstResponder()
	}
	
	/// Prepares view.
	override func prepareView() {
		super.prepareView()
		view.backgroundColor = MaterialColor.black
	}
	
	/// Prepares the searchBar.
	private func prepareSearchBar() {
		var image: UIImage? = MaterialIcon.cm.arrowBack
		
		// Back button.
		let backButton: FlatButton = FlatButton()
		backButton.pulseColor = nil
		backButton.tintColor = MaterialColor.blueGrey.darken4
		backButton.setImage(image, forState: .Normal)
		backButton.setImage(image, forState: .Highlighted)
		backButton.addTarget(self, action: #selector(handleBlueButton), forControlEvents: .TouchUpInside)
		
		// More button.
		image = MaterialIcon.cm.moreHorizontal
		let moreButton: FlatButton = FlatButton()
		moreButton.pulseColor = nil
		moreButton.tintColor = MaterialColor.blueGrey.darken4
		moreButton.setImage(image, forState: .Normal)
		moreButton.setImage(image, forState: .Highlighted)
		moreButton.addTarget(self, action: #selector(handleGreenButton), forControlEvents: .TouchUpInside)
		
		/*
		To lighten the status bar - add the
		"View controller-based status bar appearance = NO"
		to your info.plist file and set the following property.
		*/
		searchBar.statusBarStyle = .Default
		searchBar.textField.delegate = self
		searchBar.leftControls = [backButton]
		searchBar.rightControls = [moreButton]
	}
}

extension AppSearchBarController: TextFieldDelegate {
	func textFieldDidBeginEditing(textField: UITextField) {
		rootViewController.view.alpha = 0.5
		rootViewController.view.userInteractionEnabled = false
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		rootViewController.view.alpha = 1
		rootViewController.view.userInteractionEnabled = true
	}
}
