## CodeReader
![CodeReader v1.0.0](http://albertolourenco.com.br/github/codereader.png)

This is a simple view controller wich you can call to read Barcodes or QRCodes for iOS developed with Swift 4.

Calling the CodeReader:

```markdown
let codeReaderVC = CodeReaderViewController().instantiate(delegate: self)
self.present(codeReaderVC, animated: true, completion: nil)
```

Implementing the `CodeReaderDelegate` you will receive objects thats reflect what camera read.

```markdown
func codeReaderDidCancel()
func codeReaderDidFail(controller: CodeReaderViewController)
func codeReaderDidGetQRCode(controller: CodeReaderViewController, type: CodeReaderType, value: Any?)
func codeReaderDidGetBarcode(controller: CodeReaderViewController, code: String)
```

**Possible responses**

- String
- URL
- EKEvent
- CNContact
- CLLocation
- CodeReaderSMS
- CodeReaderMail

Or you can handle this automatically with `CodeReaderConfig.handleAutomatically = true`

**CodeReaderConfig**

```markdown
viewRadius
buttonRadius
handleAutomatically
tintColor
title
subtitle
```

Thanks!
