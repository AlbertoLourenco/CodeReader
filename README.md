## CodeReader
![CodeReader v1.0.0](http://albertolourenco.com.br/github/code-reader.png)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FAlbertoLourenco%2FCodeReader.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FAlbertoLourenco%2FCodeReader?ref=badge_shield)

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


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FAlbertoLourenco%2FCodeReader.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FAlbertoLourenco%2FCodeReader?ref=badge_large)