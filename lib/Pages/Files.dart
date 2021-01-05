import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:pdfconverter/Pages/PDFViewer.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:share/share.dart';

class SavedPDF extends StatefulWidget {
  String currentPage;
  String dir;
  SavedPDF({this.dir, this.currentPage});
  @override
  _SavedPDFState createState() => _SavedPDFState();
}

class _SavedPDFState extends State<SavedPDF> {
  List<FileSystemEntity> file = new List<FileSystemEntity>();

  void listOfFiles() async {
    try {
      Directory dirPath = Directory(widget.dir);
      if (await dirPath.exists()) {
        setState(() {
          file = Directory(widget.dir)
              .listSync(); //use your folder name insted of resume.
        });
      } else {
        setState(() {
          file = [];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    listOfFiles();
    setState(() {
      widget.currentPage = "Saved Page";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Saved PDF"),
      ),
      body: file.length == 0
          ?  Padding(
            padding: const EdgeInsets.symmetric(vertical:8.0,horizontal: 20.0),
            child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: SvgPicture.asset("Assets/empty.svg",placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator()))),
              Flexible(child: Text("You haven't saved any PDF file.",style: TextStyle(fontSize: 16.0,color:Theme.of(context).accentColor, ),))
            ],
        ),
      ),
          )
          : ListView.separated(
              itemCount: file.length,
              itemBuilder: (BuildContext context, int index) {
                print(file[index].toString());
                String baseName = basename(file[index].toString());

                // clear name;
                String cleareName = baseName.split("'").first.toString();
                String fileTitle = cleareName.split(".").first.toString();

                // File Size
                File normalFile = File(file[index].path);

                var sizer = normalFile.lengthSync();
                print(sizer);

                return ListTile(
                  title: Text(cleareName),
                  subtitle: Text(filesize(sizer)),
                  onTap: () {
                    print("From :" + widget.currentPage);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFViewer(
                            fileName: fileTitle,
                            path: file[index].path,
                            currentPage: widget.currentPage,
                          ),
                        ));
                  },
                  leading: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Center(
                        child: Text(
                          "PDF",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  trailing: GestureDetector(
                    child: PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Text("Share"),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text("Delete"),
                        ),
                      ],
                      onSelected: (value){
                        if(value == 1){
                          List<String> paths = List<String>();
                          paths.add(file[index].path);
                          try {
                            Share.shareFiles(paths);
                          } catch (e) {
                            print(e);
                          }
                        }
                        else if(value == 2){
                          Future<void> deleteFile() async {
                            try {
                             File fileToDelete = File(file[index].path);
                              if (await fileToDelete.exists()) {
                                file.removeAt(index);
                                await fileToDelete.delete();
                                setState(() {
                                  file = Directory(widget.dir)
                                      .listSync();
                                });
                                print("Deleted");
                              }
                            } catch (e) {
                              print(e);
                            }
                          }
                          deleteFile();
                        }
                      },
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(height: 10,color: Colors.white30,);
              },
            ),
    ));
  }
}
