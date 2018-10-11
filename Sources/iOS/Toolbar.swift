/*
 * Copyright (C) 2015 - 2018, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
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
 *	*	Neither the name of CosmicMind nor the names of its
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

open class Toolbar: Bar, Themeable {
  /// A convenience property to set the titleLabel.text.
  @IBInspectable
  open var title: String? {
    get {
      return titleLabel.text
    }
    set(value) {
      titleLabel.text = value
      layoutSubviews()
    }
  }
  
  /// Title label.
  @IBInspectable
  public let titleLabel = UILabel()
  
  /// A convenience property to set the detailLabel.text.
  @IBInspectable
  open var detail: String? {
    get {
      return detailLabel.text
    }
    set(value) {
      detailLabel.text = value
      layoutSubviews()
    }
  }
  
  /// Detail label.
  @IBInspectable
  public let detailLabel = UILabel()
  
  open override var leftViews: [UIView] {
    didSet {
      prepareIconButtons(leftViews)
    }
  }
  
  open override var centerViews: [UIView] {
    didSet {
      prepareIconButtons(centerViews)
    }
  }
  
  open override var rightViews: [UIView] {
    didSet {
      prepareIconButtons(rightViews)
    }
  }
  
  /**
   An initializer that initializes the object with a NSCoder object.
   - Parameter aDecoder: A NSCoder instance.
   */
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  /**
   An initializer that initializes the object with a CGRect object.
   If AutoLayout is used, it is better to initilize the instance
   using the init() initializer.
   - Parameter frame: A CGRect instance.
   */
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    guard willLayout else {
      return
    }
    
    if 0 < titleLabel.text?.utf16.count ?? 0 {
      if nil == titleLabel.superview {
        contentView.addSubview(titleLabel)
      }
      titleLabel.frame = contentView.bounds
    } else {
      titleLabel.removeFromSuperview()
    }
    
    if 0 < detailLabel.text?.utf16.count ?? 0 {
      if nil == detailLabel.superview {
        contentView.addSubview(detailLabel)
      }
      
      if nil == titleLabel.superview {
        detailLabel.frame = contentView.bounds
      } else {
        titleLabel.sizeToFit()
        detailLabel.sizeToFit()
        
        let diff: CGFloat = (contentView.bounds.height - titleLabel.bounds.height - detailLabel.bounds.height) / 2
        
        titleLabel.frame.size.height += diff
        titleLabel.frame.size.width = contentView.bounds.width
        
        detailLabel.frame.size.height += diff
        detailLabel.frame.size.width = contentView.bounds.width
        detailLabel.frame.origin.y = titleLabel.bounds.height
      }
    } else {
      detailLabel.removeFromSuperview()
    }
  }
  
  open override func prepare() {
    super.prepare()
    contentViewAlignment = .center
    
    prepareTitleLabel()
    prepareDetailLabel()
  }
  
  open func apply(theme: Theme) {
    backgroundColor = theme.primary
    (leftViews + rightViews + centerViews).forEach {
      guard let v = $0 as? IconButton, v.isThemingEnabled else {
        return
      }
      
     v.apply(theme: theme)
    }
    
    if !((titleLabel as? Themeable)?.isThemingEnabled == false) {
      titleLabel.textColor = theme.onPrimary
    }
    
    if !((detailLabel as? Themeable)?.isThemingEnabled == false) {
      detailLabel.textColor = theme.onPrimary
    }
  }
  
  /// A reference to titleLabel.textAlignment observation.
  private var titleLabelTextAlignmentObserver: NSKeyValueObservation!
}

private extension Toolbar {
  /// Prepares the titleLabel.
  func prepareTitleLabel() {
    titleLabel.textAlignment = .center
    titleLabel.contentScaleFactor = Screen.scale
    titleLabel.font = RobotoFont.medium(with: 17)
    titleLabel.textColor = Color.darkText.primary
    titleLabelTextAlignmentObserver = titleLabel.observe(\.textAlignment) { [weak self] titleLabel, _ in
      self?.contentViewAlignment = .center == titleLabel.textAlignment ? .center : .full
    }
  }
  
  /// Prepares the detailLabel.
  func prepareDetailLabel() {
    detailLabel.textAlignment = .center
    detailLabel.contentScaleFactor = Screen.scale
    detailLabel.font = RobotoFont.regular(with: 12)
    detailLabel.textColor = Color.darkText.secondary
  }
  
  func prepareIconButtons(_ views: [UIView]) {
    views.forEach {
      ($0 as? IconButton)?.themingStyle = .onPrimary
    }
    
    applyCurrentTheme()
  }
}
