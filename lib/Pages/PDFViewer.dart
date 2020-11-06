import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';

final Color okBtn = Color(0xffE0F2FE);

// ignore: must_be_immutable
class PDFViewer extends StatefulWidget {
  String path, fileName,currentPage;
  List<String> paths = List<String>();

  PDFViewer({this.path, this.fileName,this.currentPage}) {
    paths.add(path);
  }

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  File file;

  @override
  void initState() {
    setState(() {
      file = File(widget.path);
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      path: widget.path,
      appBar: AppBar(
        title: Text(widget.fileName + ".pdf"),
        automaticallyImplyLeading: true,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if(widget.currentPage == "HomePage"){
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => HomePage()));
              }else{
                Navigator.pop(context);
              }
            }),
        actions: [
          FlatButton.icon(
            label: Text("Share",style: TextStyle(fontSize: 20),),
            icon: Icon(Icons.share,size: 20,),
            onPressed: () {
              try {
                Share.shareFiles(widget.paths);
              } catch (e) {
                print(e);
              }
            },
          )
        ],
      ),
    );
  }
}
