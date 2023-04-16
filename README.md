![cover](https://raw.githubusercontent.com/AlbertoLourenco/CodeReader/master/github-assets/cover.png)

This is a simple view controller wich you can call to read Barcodes or QRCodes for iOS developed with Swift 4.

## How to use

```swift
let codeReaderVC = CodeReaderViewController().instantiate(delegate: self)
self.present(codeReaderVC, animated: true, completion: nil)
```

Implementing the `CodeReaderDelegate` you will receive objects thats reflect what camera read.

```swift
func codeReaderDidCancel()
func codeReaderDidFail(controller: CodeReaderViewController)
func codeReaderDidGetQRCode(controller: CodeReaderViewController, type: CodeReaderType, value: Any?)
func codeReaderDidGetBarcode(controller: CodeReaderViewController, code: String)
```

## Possible responses

- String
- URL
- EKEvent
- CNContact
- CLLocation
- CodeReaderSMS
- CodeReaderMail

Or you can handle this automatically with `CodeReaderConfig.handleAutomatically = true`

## In action

![cover](https://raw.githubusercontent.com/AlbertoLourenco/CodeReader/master/github-assets/preview-1.gif) &nbsp;&nbsp;&nbsp;
![cover](https://raw.githubusercontent.com/AlbertoLourenco/CodeReader/master/github-assets/preview-2.gif)
