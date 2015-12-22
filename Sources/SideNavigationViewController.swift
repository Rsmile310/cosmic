//
// Copyright (C) 2015 CosmicMind, Inc. <http://cosmicmind.io> 
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

public extension UIViewController {
	/**
	:name:	sideNavigationViewController
	*/
	public var sideNavigationViewController: SideNavigationViewController? {
		var viewController: UIViewController? = self
		while nil != viewController {
			if viewController is SideNavigationViewController {
				return viewController as? SideNavigationViewController
			}
			viewController = viewController?.parentViewController
		}
		return nil
	}
}

@objc(SideNavigationViewDelegate)
public protocol SideNavigationViewDelegate {
	/**
	:name: sideNavigationViewWillOpen
	*/
	optional func sideNavigationViewWillOpen(sideNavigationViewController: SideNavigationViewController)
	
	/**
	:name: sideNavigationViewDidOpen
	*/
	optional func sideNavigationViewDidOpen(sideNavigationViewController: SideNavigationViewController)
	
	/**
	:name: sideNavigationViewWillClose
	*/
	optional func sideNavigationViewWillClose(sideNavigationViewController: SideNavigationViewController)
	
	/**
	:name: sideNavigationViewDidClose
	*/
	optional func sideNavigationViewDidClose(sideNavigationViewController: SideNavigationViewController)
	
	/**
	:name: sideNavigationViewPanDidBegin
	*/
	optional func sideNavigationViewPanDidBegin(sideNavigationViewController: SideNavigationViewController, point: CGPoint)
	
	/**
	:name: sideNavigationViewPanDidChange
	*/
	optional func sideNavigationViewPanDidChange(sideNavigationViewController: SideNavigationViewController, point: CGPoint)
	
	/**
	:name: sideNavigationViewPanDidEnd
	*/
	optional func sideNavigationViewPanDidEnd(sideNavigationViewController: SideNavigationViewController, point: CGPoint)
	
	/**
	:name: sideNavigationViewDidTap
	*/
	optional func sideNavigationViewDidTap(sideNavigationViewController: SideNavigationViewController, point: CGPoint)
}

@objc(SideNavigationViewController)
public class SideNavigationViewController: UIViewController, UIGestureRecognizerDelegate {
	/**
	:name:	originalPosition
	*/
	private lazy var originalPosition: CGPoint = CGPointZero
	
	/**
	:name:	sidePanGesture
	*/
	private var sidePanGesture: UIPanGestureRecognizer?
	
	/**
	:name:	sideTapGesture
	*/
	private var sideTapGesture: UITapGestureRecognizer?
	
	/**
	:name:	delegate
	*/
	public weak var delegate: SideNavigationViewDelegate?
	
	/**
	:name:	userInteractionEnabled
	*/
	public var userInteractionEnabled: Bool {
		get {
			return mainViewController.view.userInteractionEnabled
		}
		set(value) {
			mainViewController.view.userInteractionEnabled = value
		}
	}
	
	/**
	:name:	horizontalThreshold
	*/
	public lazy var horizontalThreshold: CGFloat = 0
	
	/**
	:name:	animationDuration
	*/
	public lazy var animationDuration: CGFloat = 0.25
	
	/**
	:name:	enabled
	*/
	public lazy var enabled: Bool = true
	
	/**
	:name:	hideStatusBar
	*/
	public lazy var hideStatusBar: Bool = true
	
	/**
	:name:	depthEnabled
	*/
	public var depthEnabled: Bool = true {
		didSet {
			if !depthEnabled {
				sideView.depth = .None
			}
		}
	}
	
	/**
	:name:	depth
	*/
	public var depth: MaterialDepth = .Depth2 {
		didSet {
			if !depthEnabled && .None != sideView.depth {
				sideView.depth = depth
			}
		}
	}
	
	/**
	:name:	backdropLayer
	*/
	public private(set) lazy var backdropLayer: CAShapeLayer = CAShapeLayer()
	
	/**
	:name:	sideView
	*/
	public private(set) var sideView: MaterialView!
	
	/**
	:name:	backdropOpacity
	*/
	public var backdropOpacity: CGFloat = 0.5 {
		didSet {
			backdropLayer.backgroundColor = backdropColor?.colorWithAlphaComponent(backdropOpacity).CGColor
		}
	}
	
	/**
	:name:	backdropColor
	*/
	public var backdropColor: UIColor? {
		didSet {
			backdropLayer.backgroundColor = backdropColor?.colorWithAlphaComponent(backdropOpacity).CGColor
		}
	}
	
	/**
	:name:	opened
	*/
	public var opened: Bool {
		return sideView.x != -sideViewControllerWidth
	}
	
	/**
	:name:	mainViewController
	*/
	public private(set) var mainViewController: UIViewController!
	
	/**
	:name:	sideViewController
	*/
	public private(set) var sideViewController: UIViewController!
	
	/**
	:name:	sideViewControllerWidth
	*/
	public private(set) var sideViewControllerWidth: CGFloat = 240
	
	/**
	:name:	init
	*/
	public convenience init(mainViewController: UIViewController, sideViewController: UIViewController) {
		self.init()
		self.mainViewController = mainViewController
		self.sideViewController = sideViewController
		prepareView()
		prepareMainViewController()
		prepareSideView()
	}
	
	/**
	:name:	viewWillLayoutSubviews
	*/
	public override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		layoutBackdropLayer()
		horizontalThreshold = sideViewControllerWidth / 2
		sideView.width = sideViewControllerWidth
		sideView.height = view.bounds.height
		sideViewController.view.frame.size.width = sideView.width
		sideViewController.view.frame.size.height = sideView.height
		sideViewController.view.center = CGPointMake(sideView.width / 2, sideView.height / 2)
	}
	
	/**
	:name:	transitionFromMainViewController
	*/
	public func transitionFromMainViewController(toViewController: UIViewController, duration: NSTimeInterval, options: UIViewAnimationOptions, animations: (() -> Void)?, completion: ((Bool) -> Void)?) {
		mainViewController.willMoveToParentViewController(nil)
		addChildViewController(toViewController)
		toViewController.view.frame = view.bounds
		transitionFromViewController(mainViewController,
			toViewController: toViewController,
			duration: duration,
			options: options,
			animations: animations,
			completion: { [unowned self, mainViewController = self.mainViewController] (result: Bool) in
				mainViewController.removeFromParentViewController()
				toViewController.didMoveToParentViewController(self)
				self.mainViewController = toViewController
				self.userInteractionEnabled = !self.opened
				completion?(result)
		})
	}
	
	/**
	:name:	setSideViewControllerWidth
	*/
	public func setSideViewControllerWidth(width: CGFloat, hidden: Bool, animated: Bool) {
		sideViewControllerWidth = width
		
		let w: CGFloat = (hidden ? -width : width) / 2
		
		if animated {
			MaterialAnimation.animateWithDuration(0.25, animations: { [unowned self] in
				self.sideView.width = width
				self.sideView.position.x = w
			}) { [unowned self] in
				self.userInteractionEnabled = false
			}
		} else {
			MaterialAnimation.animationDisabled { [unowned self] in
				self.sideView.width = width
				self.sideView.position.x = w
			}
		}
	}
	
	/**
	:name:	toggle
	*/
	public func toggle(velocity: CGFloat = 0) {
		opened ? close(velocity) : open(velocity)
	}
	
	/**
	:name:	open
	*/
	public func open(velocity: CGFloat = 0) {
		toggleStatusBar(true)
		backdropLayer.hidden = false
		
		delegate?.sideNavigationViewWillOpen?(self)
		
		MaterialAnimation.animateWithDuration(Double(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(sideView.x / velocity)))),
		animations: { [unowned self] in
			self.sideView.position = CGPointMake(self.sideView.width / 2, self.sideView.height / 2)
		}) { [unowned self] in
			self.userInteractionEnabled = false
			
			if self.depthEnabled {
				MaterialAnimation.animationDisabled { [unowned self] in
					self.sideView.depth = self.depth
				}
			}
			
			self.delegate?.sideNavigationViewDidOpen?(self)
		}
	}
	
	/**
	:name:	close
	*/
	public func close(velocity: CGFloat = 0) {
		toggleStatusBar(false)
		backdropLayer.hidden = true
		
		delegate?.sideNavigationViewWillClose?(self)
		
		MaterialAnimation.animateWithDuration(Double(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(sideView.x / velocity)))),
		animations: { [unowned self] in
			self.sideView.position = CGPointMake(-self.sideView.width / 2, self.sideView.height / 2)
		}) { [unowned self] in
			self.userInteractionEnabled = true
			
			if self.depthEnabled {
				MaterialAnimation.animationDisabled { [unowned self] in
					self.sideView.depth = .None
				}
			}
			
			self.delegate?.sideNavigationViewDidClose?(self)
		}
	}
	
	/**
	:name:	gestureRecognizer
	*/
	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		if enabled {
			if gestureRecognizer == sidePanGesture {
				return gesturePanSideViewController(gestureRecognizer, withTouchPoint: touch.locationInView(view))
			}
			if opened && gestureRecognizer == sideTapGesture {
				let point: CGPoint = touch.locationInView(view)
				delegate?.sideNavigationViewDidTap?(self, point: point)
				return !isPointContainedWithinViewController(sideView, point: point)
			}
		}
		return false
	}
	
	/**
	:name:	prepareView
	*/
	public func prepareView() {
		prepareBackdropLayer()
	}
	
	/**
	:name:	prepareMainViewController
	*/
	internal func prepareMainViewController() {
		prepareViewControllerWithinContainer(mainViewController, container: view)
		mainViewController.view.frame = view.bounds
	}
	
	/**
	:name:	prepareSideViewController
	*/
	internal func prepareSideViewController() {
		sideViewController.view.clipsToBounds = true
		prepareViewControllerWithinContainer(sideViewController, container: sideView)
	}
	
	/**
	:name:	prepareSideView
	*/
	internal func prepareSideView() {
		sideView = MaterialView()
		sideView.frame = CGRectMake(0, 0, sideViewControllerWidth, view.frame.height)
		sideView.backgroundColor = MaterialColor.clear
		view.addSubview(sideView)
		
		MaterialAnimation.animationDisabled { [unowned self] in
			self.sideView.position.x = -self.sideViewControllerWidth / 2
			self.sideView.zPosition = 1000
		}
		
		prepareSideViewController()
		prepareGestures()
	}
	
	/**
	:name:	handlePanGesture
	*/
	internal func handlePanGesture(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .Began:
			backdropLayer.hidden = false
			originalPosition = sideView.position
			toggleStatusBar(true)
			if depthEnabled {
				MaterialAnimation.animationDisabled { [unowned self, sideView = self.sideView] in
					sideView.depth = self.depth
				}
			}
			delegate?.sideNavigationViewPanDidBegin?(self, point: sideView.position)
		case .Changed:
			let translation: CGPoint = recognizer.translationInView(sideView)
			let w: CGFloat = sideView.width
			
			MaterialAnimation.animationDisabled { [unowned self] in
				self.sideView.position.x = self.originalPosition.x + translation.x > (w / 2) ? (w / 2) : self.originalPosition.x + translation.x
				self.delegate?.sideNavigationViewPanDidChange?(self, point: self.sideView.position)
			}
		case .Ended, .Cancelled, .Failed:
			let point: CGPoint = recognizer.velocityInView(recognizer.view)
			let x: CGFloat = point.x >= 1000 || point.x <= -1000 ? point.x : 0
			
			delegate?.sideNavigationViewPanDidEnd?(self, point: sideView.position)
			
			if sideView.x <= CGFloat(floor(-sideViewControllerWidth)) + horizontalThreshold || point.x <= -1000 {
				close(x)
			} else {
				open(x)
			}
		case .Possible:break
		}
	}
	
	/**
	:name:	handleTapGesture
	*/
	internal func handleTapGesture(recognizer: UIPanGestureRecognizer) {
		if opened {
			close()
		}
	}
	
	/**
	:name:	prepareGestures
	*/
	private func prepareGestures(inout pan: UIPanGestureRecognizer?, panSelector: Selector, inout tap: UITapGestureRecognizer?, tapSelector: Selector) {
		if nil == pan {
			pan = UIPanGestureRecognizer(target: self, action: panSelector)
			pan!.delegate = self
			view.addGestureRecognizer(pan!)
		}
		if nil == tap {
			tap = UITapGestureRecognizer(target: self, action: tapSelector)
			tap!.delegate = self
			view.addGestureRecognizer(tap!)
		}
	}
	
	/**
	:name:	removeGestures
	*/
	private func removeGestures(inout pan: UIPanGestureRecognizer?, inout tap: UITapGestureRecognizer?) {
		if let v: UIPanGestureRecognizer = pan {
			view.removeGestureRecognizer(v)
			pan = nil
		}
		if let v: UITapGestureRecognizer = tap {
			view.removeGestureRecognizer(v)
			tap = nil
		}
	}
	
	/**
	:name:	toggleStatusBar
	*/
	private func toggleStatusBar(hide: Bool = false) {
		if hideStatusBar {
			UIApplication.sharedApplication().statusBarHidden = hide
		}
	}
	
	/**
	:name:	removeViewController
	*/
	private func removeViewController(controller: UIViewController) {
		controller.willMoveToParentViewController(nil)
		controller.view.removeFromSuperview()
		controller.removeFromParentViewController()
	}
	
	/**
	:name:	gesturePanSideViewController
	*/
	private func gesturePanSideViewController(gesture: UIGestureRecognizer, withTouchPoint point: CGPoint) -> Bool {
		return opened || enabled && isLeftPointContainedWithinRect(point)
	}
	
	/**
	:name:	isLeftPointContainedWithinRect
	*/
	private func isLeftPointContainedWithinRect(point: CGPoint) -> Bool {
		return CGRectContainsPoint(CGRectMake(0, 0, horizontalThreshold, view.frame.height), point)
	}
	
	/**
	:name:	isPointContainedWithinViewController
	*/
	private func isPointContainedWithinViewController(container: UIView, point: CGPoint) -> Bool {
		return CGRectContainsPoint(container.frame, point)
	}
	
	/**
	:name:	prepareBackdropLayer
	*/
	private func prepareBackdropLayer() {
		backdropColor = MaterialColor.black
		backdropLayer.zPosition = 900
		backdropLayer.hidden = true
		view.layer.addSublayer(backdropLayer)
	}
	
	/**
	:name:	layoutBackdropLayer
	*/
	private func layoutBackdropLayer() {
		MaterialAnimation.animationDisabled { [unowned self] in
			self.backdropLayer.frame = self.view.bounds
		}
	}
	
	/**
	:name:	prepareViewControllerWithinContainer
	*/
	private func prepareViewControllerWithinContainer(controller: UIViewController, container: UIView) {
		addChildViewController(controller)
		container.addSubview(controller.view)
		controller.didMoveToParentViewController(self)
	}
	
	/**
	:name:	prepareGestures
	*/
	private func prepareGestures() {
		removeGestures(&sidePanGesture, tap: &sideTapGesture)
		prepareGestures(&sidePanGesture, panSelector: "handlePanGesture:", tap: &sideTapGesture, tapSelector: "handleTapGesture:")
	}
}