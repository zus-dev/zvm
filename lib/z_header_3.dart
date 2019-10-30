import 'dart:typed_data';

import 'package:zvm/z_header.dart';

class ZHeader3 extends ZHeader
{
	static final int FILE_LENGTH_FACTOR = 2;

	ZHeader3 (Uint8List memory_image)
	{
		this.memory_image = memory_image;
	}

	bool time_game() /* as opposed to score game */
	{
		return ((memory_image[ZHeader.FLAGS1]&0x02) == 2);
	}
	
	void set_status_unavailable(bool unavail) 
	{
		if (unavail) {
			memory_image[ZHeader.FLAGS1] |= 0x10;
		}
		else {
			memory_image[ZHeader.FLAGS1] &= 0xEF;
		}
	}

	void set_splitting_available(bool avail)
	{
		if (avail) {
			memory_image[ZHeader.FLAGS1] |= 0x20;
		}
		else {
			memory_image[ZHeader.FLAGS1] &= 0xDF;
		}
	}

	void set_variable_default(bool variable)
	{
		if (variable) {
			memory_image[ZHeader.FLAGS1] |= 0x40;
		}
		else {
			memory_image[ZHeader.FLAGS1] &= 0xBF;
		}
	}

	int file_length() {
		int packed_length;
		
		packed_length = (((memory_image[ZHeader.FILE_LENGTH]&0xFF)<<8) |
					   (memory_image[ZHeader.FILE_LENGTH+1]&0xFF));
		return packed_length * ZHeader3.FILE_LENGTH_FACTOR;
	}
}