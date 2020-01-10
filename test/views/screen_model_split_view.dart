import 'package:zvm/src/windowing/buffered_screen_model.dart';
import 'package:zvm/zvm.dart';

abstract class ScreenModelSplitView extends ScreenModelListener  {
  BufferedScreenModel getScreenModel();
}
