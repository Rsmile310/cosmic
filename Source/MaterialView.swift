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

public class MaterialView: UIView {
	
	/**
		:name:	image
	*/
	public var image: UIImage? {
		didSet {
			layer.contents = image?.CGImage
		}
	}
	
	/**
		:name:	contentsGravity
	*/
	public var contentsGravity: String! {
		didSet {
			layer.contentsGravity = contentsGravity
		}
	}
	
	/**
		:name:	contentsRect
	*/
	public var contentsRect: CGRect! {
		didSet {
			layer.contentsRect = contentsRect
		}
	}
	
	/**
		:name:	contentsScale
	*/
	public var contentsScale: CGFloat! {
		didSet {
			layer.contentsScale = contentsScale
		}
	}
	
	/**
		:name:	backgroundColor
	*/
	public override var backgroundColor: UIColor? {
		get {
			return nil == layer.backgroundColor ? nil : UIColor(CGColor: layer.backgroundColor!)
		}
		set(value) {
			layer.backgroundColor = value?.CGColor
		}
	}
	
	/**
		:name:	x
	*/
	public var x: CGFloat! {
		didSet {
			layer.bounds.origin.x = x
		}
	}
	
	/**
		:name:	y
	*/
	public var y: CGFloat! {
		didSet {
			layer.bounds.origin = CGPointMake(x, y)
		}
	}
	
	/**
		:name:	width
	*/
	public var width: CGFloat! {
		didSet {
			layer.bounds.size.width = width
		}
	}
	
	/**
		:name:	height
	*/
	public var height: CGFloat! {
		didSet {
			layer.bounds.size.height = height
		}
	}
	
	/**
		:name:	shadowColor
	*/
	public var shadowColor: UIColor! {
		didSet {
			layer.shadowColor = shadowColor.CGColor
		}
	}
	
	/**
		:name:	shadowOffset
	*/
	public var shadowOffset: CGSize! {
		didSet {
			layer.shadowOffset = shadowOffset
		}
	}
	
	/**
		:name:	shadowOpacity
	*/
	public var shadowOpacity: Float! {
		didSet {
			layer.shadowOpacity = shadowOpacity
		}
	}
	
	/**
		:name:	shadowRadius
	*/
	public var shadowRadius: CGFloat! {
		didSet {
			layer.shadowRadius = shadowRadius
		}
	}
	
	/**
		:name:	masksToBounds
	*/
	public var masksToBounds: Bool! {
		didSet {
			layer.masksToBounds = masksToBounds
		}
	}
	
	/**
		:name:	init
	*/
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	/**
		:name:	init
	*/
	public override init(frame: CGRect) {
		super.init(frame: frame)
		prepareView()
		prepareLayer()
		prepareBounds()
	}
	
	/**
		:name:	init
	*/
	public convenience init() {
		self.init(frame: CGRectMake(MaterialTheme.view.x, MaterialTheme.view.y, MaterialTheme.view.width, MaterialTheme.view.height))
		prepareView()
		prepareLayer()
		prepareBounds()
	}
	
	/**
		:name:	prepareView
	*/
	internal func prepareView() {
		userInteractionEnabled = MaterialTheme.view.userInteractionEnabled
		backgroundColor = MaterialTheme.view.backgroudColor
	}
	
	/**
		:name:	prepareBounds
	*/
	internal func prepareBounds() {
		self.x = frame.origin.x
		self.y = frame.origin.y
		self.width = frame.size.width
		self.height = frame.size.height
	}
	
	/**
		:name:	prepareLayer
	*/
	internal func prepareLayer() {
		contentsScale = MaterialTheme.view.contentsScale
		contentsGravity = MaterialTheme.view.contentsGravity
		contentsRect = MaterialTheme.view.contentsRect
		shadowColor = MaterialTheme.view.shadowColor
		shadowOffset = MaterialTheme.view.shadowOffset
		shadowOpacity = MaterialTheme.view.shadowOpacity
		shadowRadius = MaterialTheme.view.shadowRadius
		masksToBounds = MaterialTheme.view.masksToBounds
	}
}

