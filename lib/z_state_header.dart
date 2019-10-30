import 'dart:typed_data';
import 'package:zvm/z_header.dart';

class ZStateHeader extends ZHeader
{
	ZStateHeader (Uint8List memory_image)
	{
		this.memory_image = memory_image;
	}

	/* yes, a kludge */
	int file_length() {
		return 0;
	}
}