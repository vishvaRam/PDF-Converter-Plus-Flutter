import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:pdfconverter/Pages/PDFViewer.dart';

class SavedPDF extends StatefulWidget {
  String dir;
  SavedPDF({this.dir});
  @override
  _SavedPDFState createState() => _SavedPDFState();
}

class _SavedPDFState extends State<SavedPDF> {

  List<FileSystemEntity> file = new List<FileSystemEntity>();


  void listOfFiles() async {
    try{
      Directory dirPath = Directory(widget.dir);
      if(await dirPath.exists()){
        setState(() {
          file = Directory(widget.dir).listSync();  //use your folder name insted of resume.
        });
      }
      else{
        setState(() {
          file = [];
        });
      }
    }catch(e){print(e);}

  }

  @override
  void initState() {
    listOfFiles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true,title: Text("Saved PDF"),),
      body: file.length == 0 ?Container(
        child: Center(child: Text("Empty",style:
        TextStyle(fontSize: 20.0, color: Colors.white70),
          textAlign: TextAlign.center,),),
      ): ListView.builder(
          itemCount: file.length,
          itemBuilder: (BuildContext context, int index) {
            print(file[index].toString());
            String baseName = basename(file[index].toString());
            return ListTile(
              title: Text(baseName),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => PDFViewer(fileName: baseName,path: file[index].path,),));
              },
            );
          }),
    ));
  }
}
