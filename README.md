A library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:zvm/zvm.dart';

main() {
  var awesome = new Awesome();
}
```

## What is an IFF file?
An IFF file is a universal file format created by Electronic Arts. It may contain image, text, or audio data and is used for interchanging different types of data across applications and platforms. IFF files are supported by many programs and are used as the basis for several other file formats, including AIFF.

IFF files are comprised of sections of data called "chunks," which are defined by four-letter IDs. There are three main chunk types, each of which may contain text, numerical data, or raw data:
- FORM: specifies the format of the file
- LIST: includes the properties of the file
- CAT: contains the rest of the data
The IFF format is also known as "EA IFF 1985" since Electronic Arts designed the file format in 1985.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
