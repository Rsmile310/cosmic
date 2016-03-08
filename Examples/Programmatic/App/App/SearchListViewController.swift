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
*	*	Neither the name of Material nor the names of its
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

import UIKit
import Material

private struct Item {
	var text: String
	var detail: String
	var image: UIImage?
}

class SearchListViewController: UIViewController {
	/// TextField for search.
	private let textField: TextField = TextField()
	
	/// A tableView used to display Bond entries.
	private let tableView: UITableView = UITableView()
	
	/// A list of all the Author Bond types.
	private var items: Array<Item> = Array<Item>()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		prepareView()
		prepareItems()
		prepareTableView()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		textField.resignFirstResponder()
	}
	
	/**
	Handles the search button click, which opens the
	SideNavigationViewController.
	*/
	func handleSearchButton() {
		sideNavigationViewController?.openRightView()
	}
	
	/// Prepares view.
	private func prepareView() {
		view.backgroundColor = MaterialColor.white
		
		let image: UIImage? = MaterialIcon.close
		
		let clearButton: FlatButton = FlatButton()
		clearButton.pulseScale = false
		clearButton.pulseColor = MaterialColor.grey.darken4
		clearButton.tintColor = MaterialColor.grey.darken4
		clearButton.setImage(image, forState: .Normal)
		clearButton.setImage(image, forState: .Highlighted)
		
		textField.backgroundColor = nil
		textField.placeholder = "Search"
		textField.placeholderTextColor = MaterialColor.grey.darken4
		textField.font = RobotoFont.regularWithSize(20)
		textField.tintColor = MaterialColor.grey.darken4
		textField.clearButton = clearButton
		
		navigationItem.detailView = textField
		
		if let navigationbar: NavigationBar = navigationController?.navigationBar as? NavigationBar {
			navigationbar.statusBarStyle = .Default
			navigationbar.backgroundColor = MaterialColor.white
			navigationbar.backButton.tintColor = MaterialColor.grey.darken4
		}
	}
	
	/// Prepares the items Array.
	private func prepareItems() {
		items.append(Item(text: "Summer BBQ", detail: "Wish I could come, but I am out of town this weekend.", image: UIImage(named: "Profile1")))
		items.append(Item(text: "Birthday gift", detail: "Have any ideas about what we should get Heidi for her birthday?", image: UIImage(named: "Profile2")))
		items.append(Item(text: "Brunch this weekend?", detail: "I'll be in your neighborhood doing errands this weekend.", image: UIImage(named: "Profile3")))
	}
	
	/// Prepares the tableView.
	private func prepareTableView() {
		tableView.registerClass(MaterialTableViewCell.self, forCellReuseIdentifier: "MaterialTableViewCell")
		tableView.dataSource = self
		tableView.delegate = self
		
		// Use MaterialLayout to easily align the tableView.
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		MaterialLayout.alignToParent(view, child: tableView)
	}
}

/// TableViewDataSource methods.
extension SearchListViewController: UITableViewDataSource {
	/// Determines the number of rows in the tableView.
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count;
	}
	
	/// Returns the number of sections.
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	/// Prepares the cells within the tableView.
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: MaterialTableViewCell = MaterialTableViewCell(style: .Subtitle, reuseIdentifier: "MaterialTableViewCell")
		
		let item: Item = items[indexPath.row]
		cell.selectionStyle = .None
		cell.textLabel!.text = item.text
		cell.textLabel!.font = RobotoFont.regular
		cell.detailTextLabel!.text = item.detail
		cell.detailTextLabel!.font = RobotoFont.regular
		cell.detailTextLabel!.textColor = MaterialColor.grey.darken1
		cell.imageView!.image = item.image?.resize(toWidth: 40)
		cell.imageView!.layer.cornerRadius = 20
		
		return cell
	}
	
	/// Prepares the header within the tableView.
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = UIView(frame: CGRectMake(0, 0, view.bounds.width, 48))
		header.backgroundColor = MaterialColor.white
		
		let label: UILabel = UILabel()
		label.font = RobotoFont.medium
		label.textColor = MaterialColor.grey.darken1
		label.text = "Suggestions"
		
		header.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		MaterialLayout.alignToParent(header, child: label, left: 24)
		
		return header
	}
}

/// UITableViewDelegate methods.
extension SearchListViewController: UITableViewDelegate {
	/// Sets the tableView cell height.
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 80
	}
	
	/// Sets the tableView header height.
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 48
	}
}
