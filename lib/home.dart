import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rubikSolver/solve.dart';
import 'package:rubikSolver/state/data_state.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();
  bool loading = false;
  final server_url = "http://192.168.43.75:5000/";  //change your URL or local IP

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<DataState>(builder: (context, child, model) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Rubik's Cube Solver"),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GreyContainer(checkSide("top"), "Top", Colors.yellow[600]),
                    GreyContainer(checkSide("left"), "Left", Colors.blue),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GreyContainer(checkSide("front"), "Front", Colors.red),
                    GreyContainer(checkSide("right"), "Right", Colors.green),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GreyContainer(checkSide("back"), "Back", Colors.orange),
                    GreyContainer(
                        checkSide("bottom"), "Bottom", Colors.grey[300]),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: new Builder(builder: (BuildContext _context) {
            return ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              height: 50,
              child: RaisedButton(
                onPressed: model.sideColorCode.containsValue("")
                    ? null
                    : () {
                        setState(() {
                          loading = true;
                        });
                        solveCube(_context);
                      },
                color: Colors.indigo[800],
                textColor: Colors.white,
                child: loading
                    ? Container(
                        height: 40,
                        child: SpinKitThreeBounce(
                          size: 18,
                          color: Colors.white,
                        ))
                    : Text("Solve", style: TextStyle(fontSize: 14)),
              ),
            );
          }));
    });
  }

  void _alertBox(path, side) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ScopedModelDescendant<DataState>(
              builder: (context, child, model) {
            return Dialog(
                insetPadding: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: model.processing
                    ? Container(
                        margin: EdgeInsets.all(15),
                        height: 300.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          //  color: Colors.red,
                          image: DecorationImage(
                            image: FileImage(File(path)),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black45),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitCubeGrid(
                                color: Colors.white,
                                size: 40.0,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text("Image Was Processing...",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white))
                            ],
                          ),
                        ))
                    : Container(
                        margin: EdgeInsets.all(15),
                        height: 300.0,
                        width: 300.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: model.error
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    model.errorText,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Try Again",
                                        style: TextStyle(color: Colors.blue),
                                      ))
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Colors are matched?",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  GreyContainer(BoxColors(model.tempRGB), "",
                                      Colors.transparent),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Try Again",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          )),
                                      FlatButton(
                                          onPressed: () {
                                            model.setsideColor(
                                                side, model.tempRGB);
                                            model.setsideColorCode(
                                                side, model.tempColorCode);
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Done",
                                            style:
                                                TextStyle(color: Colors.green),
                                          ))
                                    ],
                                  )
                                ],
                              )));
          });
        });
  }

  void solveCube(_context) async {
    DataState _dataState = ScopedModel.of(this.context);
    String _colorCode = _dataState.sideColorCode["top"] +
        _dataState.sideColorCode["left"] +
        _dataState.sideColorCode["front"] +
        _dataState.sideColorCode["right"] +
        _dataState.sideColorCode["back"] +
        _dataState.sideColorCode["bottom"];
    print(_colorCode);
    try {
      Response response = await Dio()
          .get(server_url + "solve?colors=" + _colorCode);

      setState(() {
        loading = false;
      });
      if (response.data["status"] == false) {
        Scaffold.of(_context).showSnackBar(new SnackBar(
          content: new Text('Wrong color pattern, Try again...'),
        ));
      } else {
        _dataState.setrotations(response.data["rotations"]);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SolveCube()));
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      Scaffold.of(_context).showSnackBar(new SnackBar(
        content: new Text('Server error, Try again...'),
      ));
    }
  }

  Future getImage(String side) async {
    DataState _dataState = ScopedModel.of(this.context);
    _dataState.setProcessing(false);
    _dataState.seterror(false);
    _dataState.settempRGB([]);
    _dataState.settempColorCode("");

    final pickedFile = await picker.getImage(
        source: ImageSource.camera, maxHeight: 1600, maxWidth: 1000);

    _dataState.setProcessing(true);
    _alertBox(pickedFile.path, side);

    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(pickedFile.path,
          filename: "upload.jpeg"),
    });

    try {
      Response response =
          await Dio().post(server_url, data: formData); 
      _dataState.setProcessing(false);
      _dataState.settempRGB(response.data["color_rgb"]);
      _dataState.settempColorCode(response.data["color_name"]);

      if (response.data["status"] == false) {
        _dataState.seterror(true);
        _dataState.seterrorText("Unable to detect colors, try again...");
      }

      print(response.data);
    } catch (e) {
      _dataState.setProcessing(false);
      _dataState.seterror(true);
      _dataState.seterrorText("Server Error");
    }
  }

  Widget checkSide(String side) {
    DataState _dataState = ScopedModel.of(this.context);
    return _dataState.sideColor[side.toLowerCase()].length > 1
        ? BoxColors(_dataState.sideColor[side])
        : getImageButton(side);
  }

  Widget getImageButton(String side) {
    return InkWell(
      onTap: () {
        getImage(side);
      },
      child: Icon(
        Icons.add,
        size: 40,
      ),
    );
  }

  Widget GreyContainer(Widget widget, String side, Color color) {
    return ScopedModelDescendant<DataState>(builder: (context, child, model) {
      return Container(
        width: 160,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  side,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                side != ""
                    ? model.sideColor[side.toLowerCase()].length > 1
                        ? InkWell(
                            onTap: () {
                              model.setsideColor(side.toLowerCase(), []);
                            },
                            child: Icon(
                              Icons.replay,
                              size: 20,
                              color: Colors.green[700],
                            ),
                          )
                        : Container()
                    : Container(),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              width: 160,
              height: 160,
              child: widget,
            ),
            SizedBox(
              height: 3,
            ),
            side != ""
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "***Center must:  ",
                        style: TextStyle(fontSize: 12),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            color: color),
                        width: 12,
                        height: 12,
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      );
    });
  }

  Widget ColorContainer(List rgb) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color.fromRGBO(rgb[0], rgb[1], rgb[2], 1.0),
      ),
      width: 40,
      height: 40,
    );
  }

  Widget BoxColors(List rgb) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ColorContainer(rgb[0]),
            ColorContainer(rgb[1]),
            ColorContainer(rgb[2]),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ColorContainer(rgb[3]),
            ColorContainer(rgb[4]),
            ColorContainer(rgb[5]),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ColorContainer(rgb[6]),
            ColorContainer(rgb[7]),
            ColorContainer(rgb[8]),
          ],
        ),
      ],
    );
  }
}
