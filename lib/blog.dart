import 'package:flutter/material.dart';
// for webview
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// html view
import 'package:flutter_html_view/flutter_html_view.dart';
// services rootBundle for loading local file asset
import 'package:flutter/services.dart' show rootBundle;
import "./flexibleAppBar.dart";
import 'dart:async';

// Blog

class Blog extends StatefulWidget {
  final pageAppBarBackground =
      "http://www.nepalconstructionmart.com/wp-content/uploads/2016/11/WAL-PAPER-SCROL.jpg";
  @override
  State<StatefulWidget> createState() {
    return new BlogState();
  }
}

Future<String> readFileAsString(_localFilePath) async {
  try {
    // Read the file
    Future<String> contents = rootBundle.loadString(_localFilePath);

    return contents;
  } catch (e) {
    // If we encounter an error, return 0
    return "<b>Bold</b>";
  }
}

class BlogState extends State<Blog> {
  var webview = new WebviewScaffold(
    url: "http://www.nepalconstructionmart.com/blog/",
    withZoom: true,
    withLocalStorage: true,
    appBar: new AppBar(
      title: new Text("Widget webview"),
    ),
  );
  Future<String> htmlContent = readFileAsString("res/about.html");

  HtmlView htmlView(context, snapshot) {
    var data = snapshot.data.toString();
    return HtmlView(
      data: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<String>(
        future: htmlContent,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return htmlView(context, snapshot);
          }
        });
    return futureBuilder;
  }
}

class BlogState extends State<Blog> {
  var webview = new WebviewScaffold(
    url: "http://www.nepalconstructionmart.com/blog/",
    withZoom: true,
    withLocalStorage: true,
    appBar: new AppBar(
      title: new Text("Widget webview"),
    ),
  );
  Future<String> htmlContent = readFileAsString("res/about.html");

  HtmlView htmlView(context, snapshot) {
    var data = snapshot.data.toString();
    return HtmlView(
      data: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<String>(
        future: htmlContent,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return wrapWithSilverAppBar("Blog",[Container(child: htmlView(context, snapshot))],widget.pageAppBarBackground);
          }
        });
    return futureBuilder;
  }
}