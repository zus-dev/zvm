import 'dart:typed_data';
import 'package:zvm/z_header.dart';

class ZHeader5 extends ZHeader
{
		static final int INTERP_NUMBER = 0x1E;
		static final int INTERP_VERSION = 0x1F; 
		static final int SCREEN_HEIGHT_LINES = 0x20;
		static final int SCREEN_WIDTH_CHARACTERS = 0x21;
		static final int SCREEN_WIDTH_UNITS = 0x22;
		static final int SCREEN_HEIGHT_UNITS = 0x24; 
		static final int FONT_HEIGHT_UNITS = 0x26;
		static final int FONT_WIDTH_UNITS = 0x27;
		static final int DEFAULT_BACKGROUND_COLOR = 0x2C;
		static final int DEFAULT_FOREGROUND_COLOR = 0x2D;

		static final int FILE_LENGTH_FACTOR = 4;

		/* interpreter numbers */

		static final int INTERP_DEC 		=  1;
		static final int INTERP_APPLEIIE	=  2;
		static final int INTERP_MAC			=  3;
		static final int INTERP_AMIGA		=  4;
		static final int INTERP_ATARIST		=  5;
		static final int INTERP_MSDOS		=  6;
		static final int INTERP_C128		=  7;
		static final int INTERP_C64 		=  8;
		static final int INTERP_APPLEIIC	=  9;
		static final int INTERP_APPLEIIGS	= 10;
		static final int INTERP_COCO		= 11;

		ZHeader5 (Uint8List memory_image)
		{
				this.memory_image = memory_image;
		}

		void set_colors_available(bool avail) {
				if (avail)
						memory_image[ZHeader.FLAGS1] |= 0x01;
				else {
						memory_image[ZHeader.FLAGS1] &= 0xFE;
				}
		}

		void set_bold_available(bool avail) {
				if (avail)
						memory_image[ZHeader.FLAGS1] |= 0x04;
				else
						memory_image[ZHeader.FLAGS1] &= 0xFB;
		}

		void set_italic_available(bool avail) {
				if (avail)
						memory_image[ZHeader.FLAGS1] |= 0x08;
				else
						memory_image[ZHeader.FLAGS1] &= 0xF7;
		}

		void set_fixed_font_available(bool avail) {
				if (avail)
						memory_image[ZHeader.FLAGS1] |= 0x10;
				else
						memory_image[ZHeader.FLAGS1] &= 0xEF;
		}

		void set_timed_input_available(bool avail) {
				if (avail)
						memory_image[ZHeader.FLAGS1] |= 0x80;
				else
						memory_image[ZHeader.FLAGS1] &= 0x7F;
		}

		bool graphics_font_wanted() { /* Called pictures in spec */
				return (memory_image[ZHeader.FLAGS2+1] & 0x08) != 0;
		}

		void set_graphics_font_available(bool avail) {
				if (!avail)
						memory_image[ZHeader.FLAGS2+1] &= 0xF7;
		}

		bool undo_wanted() {
				return (memory_image[ZHeader.FLAGS2+1] & 0x10) != 0;
		}

		void set_undo_available(bool avail) {
				if (!avail)
						memory_image[ZHeader.FLAGS2+1] &= 0xEF;
		}

		bool mouse_wanted() {
				return (memory_image[ZHeader.FLAGS2+1] & 0x20) != 0;
		}

		void set_mouse_available(bool avail) {
				if (!avail)
						memory_image[ZHeader.FLAGS2+1] &= 0xDF;
		}

		bool colors_wanted() {
				return (memory_image[ZHeader.FLAGS2+1] & 0x40) != 0;
		}

		bool sound_wanted() {
				return (memory_image[ZHeader.FLAGS2+1] & 0x80) != 0;
		}

		void set_sound_available(bool avail) {
				if (!avail)
						memory_image[ZHeader.FLAGS2+1] &= 0x7F;
		}

		void set_interpreter_number(int number)
		{
				memory_image[INTERP_NUMBER] = number;
		}

		void set_interpreter_version(int version)
		{
				memory_image[INTERP_VERSION] = version;
		}

		void set_screen_height_lines(int lines)
		{
				memory_image[SCREEN_HEIGHT_LINES] = lines;
		}

		void set_screen_width_characters(int characters)
		{
				memory_image[SCREEN_WIDTH_CHARACTERS] = characters;
		}

		void set_screen_height_units(int units)
		{
        //TODO: needs careful test!
				memory_image[SCREEN_HEIGHT_UNITS  ] = (units>>8);
				memory_image[SCREEN_HEIGHT_UNITS+1] = (units&0xFF);
		}

		void set_screen_width_units(int units)
		{
      //TODO: needs careful test!
				memory_image[SCREEN_WIDTH_UNITS  ] = (units>>8);
				memory_image[SCREEN_WIDTH_UNITS+1] = (units&0xFF);
		}

		void set_font_height_units(int units)
		{
				memory_image[FONT_HEIGHT_UNITS] = units;
		}

		void set_font_width_units(int units)
		{
				memory_image[FONT_WIDTH_UNITS] = units;
		}

		int default_background_color()
		{
				return memory_image[DEFAULT_BACKGROUND_COLOR];
		}

		int default_foreground_color()
		{
				return memory_image[DEFAULT_FOREGROUND_COLOR];
		}

		void set_default_background_color(int color)
		{
				memory_image[DEFAULT_BACKGROUND_COLOR] = color;
		}

		void set_default_foreground_color(int color)
		{
				memory_image[DEFAULT_FOREGROUND_COLOR] = color;
		}

		int file_length() {
				int packed_length;
				
				packed_length = (((memory_image[ZHeader.FILE_LENGTH]&0xFF)<<8) |
										   (memory_image[ZHeader.FILE_LENGTH+1]&0xFF));
				return packed_length * FILE_LENGTH_FACTOR;
		}
}