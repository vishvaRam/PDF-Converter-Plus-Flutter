import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'PDFViewer.dart';
import 'package:pdf/widgets.dart' as pdfWidget;
import 'Files.dart';

final Color okBtn = Color(0xffE0F2FE);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final pdf = pw.Document();
  List<Asset> images = List<Asset>();
  List<File> files = List<File>();
  bool isLoading = false;
  bool pathIstrue = false;
  String dirPath = "/storage/emulated/0/PDF Converter Plus";


  snakBar(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget floatingActionBtn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: null,
          onPressed: () {
            loadImage(context);
          },
          child: Icon(Icons.add),
          elevation: 10.0,
        ),
        images.length == 0? Container(): SizedBox(
          height: 15.0,
        ),
        images.length == 0? Container(): FloatingActionButton.extended(
          heroTag: null,
          onPressed: () async {
            final _text = TextEditingController();

            if (images.length == 0) {
              snakBar(context, "No images selected!");
              return;
            }

            final Directory docDir = Directory(dirPath);
            String path ="";
            try{
              if(await docDir.exists()){
                print("Dir already exist");
                path = docDir.path;
              }else{
                final Directory newdocDir = await docDir.create(recursive: true);
                path = newdocDir.path;
                print("Created new Dir");
              }

            }catch(e){print(e);setState(() {
              isLoading=false;
            });}
            String tempString;

            showDialog(
                context: context,
                child: AlertDialog(
                  title: Text("File name"),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) =>
                        Container(
                      child: TextField(
                        controller: _text,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Enter file name",
                          errorText: pathIstrue ? "File already exist!" : null,
                        ),
                        onChanged: (value) async {
                          tempString = path + "/$value.pdf";
                          File(tempString).existsSync()
                              ? setState(() {
                                  pathIstrue = true;
                                })
                              : setState(() {
                                  pathIstrue = false;
                                });
                          print(tempString);
                          print(pathIstrue);
                        },
                      ),
                    ),
                  ),
                  actions: [
                    OutlineButton.icon(
                        borderSide: BorderSide(width: 1, color: Colors.white38),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.clear),
                        label: Text(
                          "Close",
                          style: TextStyle(fontSize: 18.0),
                        )),
                    isLoading
                        ? Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : FlatButton.icon(

                            onPressed: () {
                              if (_text.text != "") {
                                if (pathIstrue == false) {
                                  pdfConvertion(
                                      context, tempString, _text.text);
                                  Navigator.pop(context);
                                }
                              }
                            },
                            icon: Icon(
                              Icons.done,
                              color: Color(0xff004879),
                            ),
                            label: Text(
                              "Ok",
                              style: TextStyle(
                                  fontSize: 18.0, color: Color(0xff004879)),
                            ),
                            color: okBtn,
                          ),
                  ],
                ));
          },
          label: Text("Create PDF"),
          icon: Icon(Icons.create),
          elevation: 10.0,
        ),
        images.length == 0? Container():  SizedBox(
          height: 10.0,
        )
      ],
    );
  }

  pdfConvertion(context, String path, String fileName) async {
    setState(() {
      isLoading = true;
    });
    for (var i = 0; i < files.length; i++) {
      try {
        final image = PdfImage.file(
          pdf.document,
          bytes: File(files[i].path).readAsBytesSync(),
        );

        pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pdfWidget.EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 6, right: 6),
            build: (pw.Context context) {
              return pw.Center(
                  child: pw.Image(
                image,
                fit: pdfWidget.BoxFit.contain,
              ));
            }));
      } catch (e) {
        print(e);
      }
    }

    print(path);
    try {
      final file = File(path);
      file.writeAsBytes(pdf.save()).then((value) {
        print("Done" + value.toString());
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PDFViewer(
                      path: path,
                      fileName: fileName,
                    )));
        setState(() {
          images = [];
          files = [];
        });
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      snakBar(context, "Something went wrong!");
    }
  }

  Widget appBar() {
    return AppBar(
      centerTitle: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            "Assets/pdf.png",
            height: 35.0,
          ),
          SizedBox(
            width: 18.0,
          ),
          Text(
            "PDF Converter Plus",
            style: TextStyle(fontSize: 22.0),
          ),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.save_sharp), onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SavedPDF(dir: dirPath,),));
        })
      ],
    );
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 500,
          height: 500,
        );
      }),
    );
  }

  Future<void> loadImage(BuildContext context) async {
    List<Asset> resultImages = List<Asset>();
    List<File> tempfiles = List<File>();

    try {
      resultImages = await MultiImagePicker.pickImages(
        maxImages: 150,
        enableCamera: true,
        materialOptions: MaterialOptions(
          statusBarColor: "#000000",
          actionBarColor: "#202020",
          actionBarTitle: "Image selector",
          allViewTitle: "All Photos",
          useDetailsView: true,
        ),
      );

      if (!mounted) {
        snakBar(context, "Select image!");
        return;
      }
      setState(() {
        images = resultImages;
      });

      for (Asset asset in images) {
        final filePath =
            await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
        tempfiles.add(File(filePath));
      }
      setState(() {
        files = tempfiles;
      });
      for (File file in files) {
        print(file);
      }
      for (File file in files) {
        print(file);
      }
    } catch (E) {
      print(E);
      snakBar(context, "Select image!");
    }
  }

  @override
  void dispose() {
    print("disposed!");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: appBar(),
          floatingActionButton:
              Builder(builder: (context) => floatingActionBtn(context)),
          body: Stack(
            alignment: Alignment.center,
            children: [
              images.length == 0
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text(
                          "Select images from gallery and press Create PDF button \n\n Saved PDF will be in Internal Storage/PDF Converter Plus Folder",
                          style:
                              TextStyle(fontSize: 20.0, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : buildGridView(),
              isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black26,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(),
            ],
          )),
    );
  }
}
