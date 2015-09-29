//
// Copyright (C) 2015 GraphKit, Inc. <http://graphkit.io> and other GraphKit contributors.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program located at the root of the software package
// in a file called LICENSE.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

public struct MaterialLayout {
	/**
		:name:	width
	*/
	public static func width(parent: UIView, child: UIView, width: CGFloat = 0) {
		let metrics: Dictionary<String, AnyObject> = ["width" : width]
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("H:[child(width)]", options: [], metrics: metrics, views: views))
	}
	
	/**
		:name:	height
	*/
	public static func height(parent: UIView, child: UIView, height: CGFloat = 0) {
		let metrics: Dictionary<String, AnyObject> = ["height" : height]
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("V:[child(height)]", options: [], metrics: metrics, views: views))
	}
	
	/**
		:name:	size
	*/
	public static func size(parent: UIView, child: UIView, width: CGFloat = 0, height: CGFloat = 0) {
		MaterialLayout.width(parent, child: child, width: width)
		MaterialLayout.height(parent, child: child, height: height)
	}
	
	/**
		:name:	alignToParent
	*/
	public static func alignToParent(parent: UIView, child: UIView) {
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("H:|[child]|", options: [], metrics: nil, views: views))
		parent.addConstraints(constraint("V:|[child]|", options: [], metrics: nil, views: views))
	}
	
	/**
		:name:	alignToParentHorizontally
	*/
	public static func alignToParentHorizontally(parent: UIView, child: UIView) {
		alignToParentHorizontallyWithPad(parent, child: child, left: 0, right: 0)
	}
	
	/**
		:name:	alignToParentHorizontallyWithPad
	*/
	public static func alignToParentHorizontallyWithPad(parent: UIView, child: UIView, left: CGFloat = 0, right: CGFloat = 0) {
		parent.addConstraints(constraint("H:|-(left)-[child]-(right)-|", options: [], metrics: ["left": left, "right": right], views: ["child" : child]))
	}
	
	/**
		:name:	alignToParentVertically
	*/
	public static func alignToParentVertically(parent: UIView, child: UIView) {
		alignToParentVerticallyWithPad(parent, child: child, top: 0, bottom: 0)
	}
	
	/**
		:name:	alignToParentVerticallyWithPad
	*/
	public static func alignToParentVerticallyWithPad(parent: UIView, child: UIView, top: CGFloat = 0, bottom: CGFloat = 0) {
		parent.addConstraints(constraint("V:|-(top)-[child]-(bottom)-|", options: [], metrics: ["bottom": bottom, "top": top], views: ["child" : child]))
	}
	
	/**
		:name:	alignToParentWithPad
	*/
	public static func alignToParentWithPad(parent: UIView, child: UIView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("H:|-(left)-[child]-(right)-|", options: [], metrics: ["left": left, "right": right], views: views))
		parent.addConstraints(constraint("V:|-(top)-[child]-(bottom)-|", options: [], metrics: ["bottom": bottom, "top": top], views: views))
	}
	
	/**
		:name:	alignFromTopLeft
	*/
	public static func alignFromTopLeft(parent: UIView, child: UIView, top: CGFloat = 0, left: CGFloat = 0) {
		let metrics: Dictionary<String, AnyObject> = ["top" : top, "left" : left]
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("H:|-(left)-[child]", options: [], metrics: metrics, views: views))
		parent.addConstraints(constraint("V:|-(top)-[child]", options: [], metrics: metrics, views: views))
	}
	
	/**
		:name:	alignFromTopRight
	*/
	public static func alignFromTopRight(parent: UIView, child: UIView, top: CGFloat = 0, right: CGFloat = 0) {
		let metrics: Dictionary<String, AnyObject> = ["top" : top, "right" : right]
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("H:[child]-(right)-|", options: [], metrics: metrics, views: views))
		parent.addConstraints(constraint("V:|-(top)-[child]", options: [], metrics: metrics, views: views))
	}
	
	/**
		:name:	alignFromBottomLeft
	*/
	public static func alignFromBottomLeft(parent: UIView, child: UIView, bottom: CGFloat = 0, left: CGFloat = 0) {
		let metrics: Dictionary<String, AnyObject> = ["bottom" : bottom, "left" : left]
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("H:|-(left)-[child]", options: [], metrics: metrics, views: views))
		parent.addConstraints(constraint("V:[child]-(bottom)-|", options: [], metrics: metrics, views: views))
	}
	
	/**
		:name:	alignFromBottomRight
	*/
	public static func alignFromBottomRight(parent: UIView, child: UIView, bottom: CGFloat = 0, right: CGFloat = 0) {
		let metrics: Dictionary<String, AnyObject> = ["bottom" : bottom, "right" : right]
		let views: Dictionary<String, AnyObject> = ["child" : child]
		parent.addConstraints(constraint("H:[child]-(right)-|", options: [], metrics: metrics, views: views))
		parent.addConstraints(constraint("V:[child]-(bottom)-|", options: [], metrics: metrics, views: views))
	}
	
	/**
		:name:	alignFromTop
	*/
	public static func alignFromTop(parent: UIView, child: UIView, top: CGFloat = 0) {
		parent.addConstraints(constraint("V:|-(top)-[child]", options: [], metrics: ["top" : top], views: ["child" : child]))
	}
	
	/**
		:name:	alignFromLeft
	*/
	public static func alignFromLeft(parent: UIView, child: UIView, left: CGFloat = 0) {
		parent.addConstraints(constraint("H:|-(left)-[child]", options: [], metrics: ["left" : left], views: ["child" : child]))
	}
	
	/**
		:name:	alignFromBottom
	*/
	public static func alignFromBottom(parent: UIView, child: UIView, bottom: CGFloat = 0) {
		parent.addConstraints(constraint("V:[child]-(bottom)-|", options: [], metrics: ["bottom" : bottom], views: ["child" : child]))
	}
	
	/**
		:name:	alignFromRight
	*/
	public static func alignFromRight(parent: UIView, child: UIView, right: CGFloat = 0) {
		parent.addConstraints(constraint("H:[child]-(right)-|", options: [], metrics: ["right" : right], views: ["child" : child]))
	}
	
	/**
		:name:	constraint
	*/
	public static func constraint(format: String, options: NSLayoutFormatOptions, metrics: Dictionary<String, AnyObject>?, views: Dictionary<String, AnyObject>) -> Array<NSLayoutConstraint> {
		return NSLayoutConstraint.constraintsWithVisualFormat(
			format,
			options: options,
			metrics: metrics,
			views: views
		)
	}
}