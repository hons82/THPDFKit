THPDFKit
===

[![Build Status](https://travis-ci.org/hons82/THPDFKit.png)](https://travis-ci.org/hons82/THPDFKit)
[![Pod Version](http://img.shields.io/cocoapods/v/THPDFKit.svg?style=flat)](http://cocoadocs.org/docsets/THPDFKit/)
[![Pod Platform](http://img.shields.io/cocoapods/p/THPDFKit.svg?style=flat)](http://cocoadocs.org/docsets/THPDFKit/)
[![Pod License](http://img.shields.io/cocoapods/l/THPDFKit.svg?style=flat)](http://opensource.org/licenses/MIT)
[![Coverage Status](https://coveralls.io/repos/hons82/THPDFKit/badge.svg)](https://coveralls.io/r/hons82/THPDFKit)

PDF viewer component on top of Apples PDFKit

# Screenshots

![iPhone Portrait](/Screenshots/Screenshot1.png?raw=true)
![iPhone Landscape](/Screenshots/Screenshot2.png?raw=true)

# Installation

### CocoaPods

Install with [CocoaPods](http://cocoapods.org) by adding the following to your Podfile:

``` ruby
platform :ios, '9.0'
use_frameworks!
pod 'THPDFKit', '~> 0.3.1'
```

**Note**: We follow http://semver.org for versioning the public API.

# Usage

This is a sample initialization taken from the sample project which uses storyboards to define viewcontrollers and navigation.

However the only thing that is really needed is passing the URL to the PDF file to the Wrapper (If you wanna use the Quicklook fallback) or directly to the `PDFKitViewController` if you're not targeting platforms below iOS11.

```swift
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedRow = indexPath.row
            let detailVC = segue.destination as! PDFViewControllerWrapper
            detailVC.url = self.samplePDFs[selectedRow]

        }
    }
```
# TODOs

- Finally fix the broken TravisCI integration
- Support for annotations
- Improve podspec for iOS11 only version without Quicklook
- Extend customizability (colors, sizes, fonts, ...)
- Support for CocoaLumberjack (for logging)

# Contributions

...are really welcome. If you have an idea just fork the library change it and if its useful for others and not affecting the functionality of the library for other users I'll insert it

# License

Source code of this project is available under the standard MIT license. Please see [the license file](LICENSE.md).