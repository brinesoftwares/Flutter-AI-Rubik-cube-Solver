import 'package:scoped_model/scoped_model.dart';

class DataState extends Model {


  bool _processing = false;
  bool get processing => _processing;

  void setProcessing(value) {
    _processing = value;
    notifyListeners();
  }


  bool _error = false;
  bool get error => _error;


  void seterror(value) {
    _error = value;
    notifyListeners();
  }


  String _errorText = "";
  String get errorText => _errorText;


  void seterrorText(value) {
    _errorText = value;
    notifyListeners();
  }

  String _tempColorCode = "";
  String get tempColorCode => _tempColorCode;


  void settempColorCode(value) {
    _tempColorCode = value;
    notifyListeners();
  }



  List _tempRGB = [];
  List get tempRGB => _tempRGB;


  void settempRGB(value) {
    _tempRGB = value;
    notifyListeners();
  }


  List _rotations = [
        "L'",
        "F",
        "B2",
        "R'",
        "B",
        "R'",
        "L",
        "B",
        "D'",
        "F'",
        "U",
        "B2",
        "U",
        "F2",
        "D'",
        "R2",
        "L2",
        "U",
        "F2",
        "D'"
    ];

  List get rotations => _rotations;

  void setrotations(value) {
    _rotations = value;
    notifyListeners();
  }


  
  Map _sideColor = {
    "top":[],
    "right":[],
    "left":[],
    "front":[],
    "back":[],
    "bottom":[],
  };
  Map get sideColor => _sideColor;


  void setsideColor(String key,value) {
    _sideColor[key] = value;
    notifyListeners();
  }


  Map _sideColorCode = {
    "top":"bwrryoryr",
    "left":"oyywbrrog",
    "front":"bgwgrboyo",
    "right":"ggbygwbrg",
    "back":"wbygoryog",
    "bottom":"wowwwbybo",
  };
  Map get sideColorCode => _sideColorCode;


  void setsideColorCode(String key,value) {
    _sideColorCode[key] = value;
    notifyListeners();
  }

  
  
  

}


