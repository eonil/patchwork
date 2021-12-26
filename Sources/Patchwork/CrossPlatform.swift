#if canImport(UIKit)
import UIKit
public typealias OSView = UIView
public typealias OSImage = UIImage
public typealias OSImageView = UIImageView
public typealias OSColor = UIColor
#endif

#if canImport(AppKit)
import AppKit
public typealias OSView = NSView
public typealias OSImage = NSImage
public typealias OSImageView = NSImageView
public typealias OSColor = NSColor
#endif