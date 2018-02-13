Pod::Spec.new do |s|
  s.name					        = "THPDFKit"
  s.version					      = "0.1.0"
  s.summary					      = "PDF viewer component on top of Apples PDFKit"
  s.description				    = <<-DESC
PDF viewer component on top of Apples PDFKit. 
As a fallback for older iOS versions this library is using QuickLook
DESC
  s.homepage				      = "https://github.com/hons82/THPDFKit"
  s.license					      = { :type => "MIT", :file => "LICENSE.md" }
  s.author					      = { "Hannes Tribus" => "hons82@gmail.com" }
  s.ios.deployment_target	= "9.0"
  s.requires_arc		    	= true
  s.source					      = { :git => "https://github.com/hons82/THPDFKit.git", :tag => "#{s.version}" }
  s.source_files			    = "THPDFKit/THPDFKit/**/*.{swift}"
  s.resources 	 		      = "THPDFKit/THPDFKit/Assets.xcassets"
  s.framework			        = 'PDFKit'
  s.framework			        = 'QuickLook'
  s.framework			        = 'UIKit'
  s.swift_version         = '4.0'
#  s.dependency				    "CocoaLumberjack", "~> 3"
end
