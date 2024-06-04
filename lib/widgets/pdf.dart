import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get_storage/get_storage.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/back.dart';
import 'package:path_provider/path_provider.dart';
import '../model/news.dart';
import 'package:http/http.dart' as http;

class PdfViewWidget extends StatefulWidget {
  const PdfViewWidget({super.key,this.model});

  final ENews? model;

  @override
  State<PdfViewWidget> createState() => _PdfViewWidgetState();
}

class _PdfViewWidgetState extends State<PdfViewWidget> {

  
  int? pages;
   String remotePDFpath = "";
  bool isReady=false;
  bool isLoading=true;
  

Future<String> createFileOfPdfUrl() async {
   final Directory tempDir = await getTemporaryDirectory();
  final String tempPath = tempDir.path;
  final String pdfPath = '$tempPath/sample.pdf';
  final response = await http.get(Uri.parse(widget.model!.pdf));
  
  final file = File(pdfPath);
  await file.writeAsBytes(response.bodyBytes);

  return pdfPath;
}
  // print(widget.model!.pdf);
  //   Completer<File> completer = Completer();
  //   try {
  //     final url = widget.model!.pdf;
  //     final filename = url.substring(url.lastIndexOf("/") + 1);
  //     var request = await HttpClient().getUrl(Uri.parse(url));
  //     var response = await request.close();
  //     var bytes = await consolidateHttpClientResponseBytes(response);
  //     var dir = await getApplicationDocumentsDirectory();
  //     debugPrint("${dir.path}/$filename");
  //     File file = File("${dir.path}/$filename");
    
  //     await file.writeAsBytes(bytes, flush: true);
  //     completer.complete(file);
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     throw Exception('Error parsing asset file!');
  //   }

  //   return completer.future;
  // }


   final Completer<PDFViewController> _controller =Completer<PDFViewController>();
     PDFViewController? pdfViewController;

 @override
  void initState() {
    createFileOfPdfUrl().then((value) {
  
      setState(() {
        remotePDFpath = value;
      });
  
    });
    super.initState();
  }

  int curr =0;

  @override
  Widget build(BuildContext context) {
        debugPrint(widget.model!.pdf);

    return remotePDFpath == '' ? Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ) : Scaffold(
      body: Column(
        children: [
          Container(
              width: size(context).width,
              padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: SafeArea(child:Row(
                children: [
                 const Backbut(),
                 const SizedBox(width: 16),
                Text(widget.model!.name.toString(),
                 style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  fontWeight:FontWeight.w700
                 )
                )
                ],
              ),
            )),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                PDFView(
                  key: ValueKey(_controller),
                  filePath:remotePDFpath,
                   enableSwipe: true,
                  nightMode: false,
                  swipeHorizontal: true,
                  defaultPage: curr,
                  autoSpacing: false,
                  pageFling: true,
                  onRender: (pages) {
                  setState(() {
                    pages = pages;
                    isReady = true;
                  });
                  },
                  onError: (error) {
                  debugPrint(error.toString());
                  },
                  onPageError: (page, error) {
                  debugPrint('$page: ${error.toString()}');
                  },
                  
                  onViewCreated: (PDFViewController pdfViewController) {
                  _controller.complete(pdfViewController);
                  pdfViewController = pdfViewController;
                  setState(() { });
                  },
                  
                  pageSnap: false,
                  onPageChanged: (int? page, int? total) {
                   curr =page!.toInt();
                   pages = total!.toInt();
                   setState(() {});
                  debugPrint('page change: $page/$total');
                  },
                ),
              ],
            ),
          ),
           FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return Container(
              color: Theme.of(context).cardColor,
              padding:const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () async{
                      if (curr >= 0) {
                       curr--;
                        snapshot.data!.setPage(curr);
                      setState(() {   });
                      }
                    //  setState(() {   });
                  }, icon: const Icon(Icons.chevron_left)),
                   SizedBox(
                    width: 100,
                    height: 30,
                     child: Row(
                       children: [
                        Text('Go To :  ',
                        style: Theme.of(context).textTheme.titleLarge!),
                         Expanded(
                           child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 1,color: Colors.grey.shade500)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1,color: Theme.of(context).primaryColor)
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4)
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && value.contains(RegExp(r'[0-9]')) && curr < pages!.toInt() && curr >= 0) {
                                curr = int.parse(value)-1;
                                snapshot.data!.setPage(curr);
                                setState(() {   });
                              }
                            },
                           ),
                         ),
                       ],
                     ),
                   ),
                   Text('${curr+1} / $pages',
                    style: Theme.of(context).textTheme.titleLarge),
                   IconButton(onPressed: ()async{
                     if (curr < pages!.toInt()) {
                        curr++;
                        snapshot.data!.setPage(curr);
                        setState(() {   });
                     }
                    // setState(() {   });
                  }, icon: const Icon(Icons.chevron_right))
                ],
              ),
             
            );
          }
          return Container();
        },
      ),
        ],
      ),
    );
  }
}