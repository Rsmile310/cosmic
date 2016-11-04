/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
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

public enum CharacterAttribute: String {
    case font = "NSFontAttributeName"
    case paragraphStyle = "NSParagraphStyleAttributeName"
    case forgroundColor = "NSForegroundColorAttributeName"
    case backgroundColor = "NSBackgroundColorAttributeName"
    case ligature = "NSLigatureAttributeName"
    case kern = "NSKernAttributeName"
    case strikethroughStyle = "NSStrikethroughStyleAttributeName"
    case underlineStyle = "NSUnderlineStyleAttributeName"
    case strokeColor = "NSStrokeColorAttributeName"
    case strokeWidth = "NSStrokeWidthAttributeName"
    case shadow = "NSShadowAttributeName"
    case textEffect = "NSTextEffectAttributeName"
    case attachment = "NSAttachmentAttributeName"
    case link = "NSLinkAttributeName"
    case baselineOffset = "NSBaselineOffsetAttributeName"
    case underlineColor = "NSUnderlineColorAttributeName"
    case strikethroughColor = "NSStrikethroughColorAttributeName"
    case obliqueness = "NSObliquenessAttributeName"
    case expansion = "NSExpansionAttributeName"
    case writingDirection = "NSWritingDirectionAttributeName"
    case verticalGlyphForm = "NSVerticalGlyphFormAttributeName"
}

public func CharacterAttributeToValue(attribute: CharacterAttribute) -> String {
    switch attribute {
    case .font:
        return NSFontAttributeName
    case .paragraphStyle:
        return NSParagraphStyleAttributeName
    case .forgroundColor:
        return NSForegroundColorAttributeName
    case .backgroundColor:
        return NSBackgroundColorAttributeName
    case .ligature:
        return NSLigatureAttributeName
    case .kern:
        return NSKernAttributeName
    case .strikethroughStyle:
        return NSStrikethroughStyleAttributeName
    case .underlineStyle:
        return NSUnderlineStyleAttributeName
    case .strokeColor:
        return NSStrokeColorAttributeName
    case .strokeWidth:
        return NSStrokeWidthAttributeName
    case .shadow:
        return NSShadowAttributeName
    case .textEffect:
        return NSTextEffectAttributeName
    case .attachment:
        return NSAttachmentAttributeName
    case .link:
        return NSLinkAttributeName
    case .baselineOffset:
        return NSBaselineOffsetAttributeName
    case .underlineColor:
        return NSUnderlineColorAttributeName
    case .strikethroughColor:
        return NSStrikethroughColorAttributeName
    case .obliqueness:
        return NSObliquenessAttributeName
    case .expansion:
        return NSExpansionAttributeName
    case .writingDirection:
        return NSWritingDirectionAttributeName
    case .verticalGlyphForm:
        return NSVerticalGlyphFormAttributeName
    }
}

/// A memory reference to the CharacterAttribute instance for String extensions.
//private var CharacterAttributeKey: UInt8 = 0

//public struct CharacterAttribute {
//}

//extension String {
    /// characterAttribute reference.
//    public private(set) var characterAttribute: CharacterAttribute {
//        get {
//            return AssociatedObject(base: self, key: &CharacterAttributeKey) {
//                return CharacterAttribute()
//            }
//        }
//        set(value) {
//            AssociateObject(base: self, key: &CharacterAttributeKey, value: value)
//        }
//    }
//}

extension NSAttributedString {
    open func characterAttributes(at index: Int, effectiveRange: NSRangePointer?) -> [CharacterAttribute: Any] {
        var ca = [CharacterAttribute: Any]()
        attributes(at: index, effectiveRange: effectiveRange).forEach { (key, value) in
            guard let attribute = CharacterAttribute.init(rawValue: key) else {
                return
            }
            
            ca[attribute] = value
        }
        
        
        return ca
    }
}

public enum ParagraphAttribute {
    
}

public enum DocumentAttribute {
    
}

@objc(EditorDelegate)
public protocol EditorDelegate {
    
    
}

open class Editor: View {
    /// A reference to the Text.
    open internal(set) var text: Text!
    
    /// A reference to the NSTextContainer.
    open internal(set) var textContainer: NSTextContainer!
    
    /// A reference to the NSLayoutManager.
    open internal(set) var layoutManager: NSLayoutManager!
    
    /// Reference to the TextView.
    open internal(set) var textView: TextView!
    
    /// A reference to an EditorDelegate.
    open weak var delegate: EditorDelegate?
    
    /**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepare method
     to initialize property values and other setup operations.
     The super.prepare method should always be called immediately
     when subclassing.
     */
    open override func prepare() {
        super.prepare()
        prepareTextContainer()
        prepareLayoutManager()
        prepareText()
        prepareTextView()
    }
}

extension Editor {
    /// Prepares the textContainer.
    fileprivate func prepareTextContainer() {
        textContainer = NSTextContainer(size: bounds.size)
    }
    
    /// Prepares the layoutManager.
    fileprivate func prepareLayoutManager() {
        layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
    }
    
    /// PRepares the text.
    fileprivate func prepareText() {
        text = Text()
        text.delegate = self
        text.textStorage.addLayoutManager(layoutManager)
    }
    
    /// Prepares the textView.
    fileprivate func prepareTextView() {
        textView = TextView(textContainer: textContainer)
        layout(textView).edges()
    }
}

extension Editor: TextDelegate {
    /**
     When changes in the textView text are made, this delegation method
     is executed with the added text string and range.
     */
    public func textWillProcessEdit(text: Text, textStorage: TextStorage, string: String, range: NSRange) {
        textStorage.removeAttribute(CharacterAttribute.font.rawValue, range: range)
        textStorage.addAttribute(CharacterAttribute.font.rawValue, value: RobotoFont.regular, range: range)
    }
    
    /**
     When a match is detected within the textView text, this delegation
     method is executed with the added text string and range.
     */
    public func textDidProcessEdit(text: Text, textStorage: TextStorage, string: String, result: NSTextCheckingResult?, flags: NSRegularExpression.MatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) {
        textStorage.addAttribute(CharacterAttribute.font.rawValue, value: RobotoFont.bold, range: result!.range)
    }
}
