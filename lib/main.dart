import 'package:flutter/material.dart';

//import 'package:woocommerce_api/woocommerce_api.dart';
import './woocommerce_api.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
// for webview
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// html view
import 'package:flutter_html_view/flutter_html_view.dart';
import 'dart:io';
// services rootBundle for loading local file asset
import 'package:flutter/services.dart' show rootBundle;

// fo firebase
// https://pub.dartlang.org/packages/firebase_messaging#-readme-tab-
//import 'package:firebase_messaging/firebase_messaging.dart';
// for firebase ends here

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Nepal Construction Mart',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: 'www.NepalConstructionMart.com'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// This controller can be used to programmatically
  /// set the current displayed page
  PageController _pageController;
  int _page = 0;

  void _showMenu() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
        appBar: new AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: new Text(widget.title),
        ),
        body: new PageView(
          children: [
            new Categories(),
            new Products(),
            new Container(color: Colors.black38),
            new Blog(),
            new Container(color: Colors.lightBlue),
          ],

          /// Specify the page controller
          controller: _pageController,
          onPageChanged: onPageChanged,
        ),
        /*   floatingActionButton: new FloatingActionButton(
          onPressed: _showMenu,
          tooltip: 'Menu',
          child: new Icon(Icons.menu),
          
        ), // This trailing comma makes auto-formatting nicer for build methods.
        */
        bottomNavigationBar: new BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.shop), title: new Text("Category")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.shop_two), title: new Text("Product")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.remove_circle), title: new Text("Review")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.rate_review), title: new Text("Blog")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.contacts), title: new Text("Contact")),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
          type: BottomNavigationBarType.fixed,
        ));
  }

  /// Called when the user presses on of the
  /// [BottomNavigationBarItem] with corresponding
  /// page index
  void navigationTapped(int page) {
    // Animating to the page.
    // You can use whatever duration and curve you like
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}

// woo parameters
// for oauth1 authentication
WooCommerceAPI wc_api = new WooCommerceAPI(
    "http://www.nepalconstructionmart.com",
    "ck_b3b26bf14e1193829ec21ca2c8ae355be3855fc6",
    "cs_69ddf520c834a509c41557c4ab145b8c24e0754e");

// static category
//https://api.myjson.com/bins/hl6iu
class User {
  String name;
  int id;
  @override
  toString() {
    return this.name + " => " + this.id.toString();
  }

  User({this.name, this.id});
}

// Category State
//wc-api/v3/products/categories?fields=id,name,image,parent,count&filter[limit]=100
class Category {
  int id;
  String name;
  int parent;
  int count;
  String image;
  String description;

  Category.fromJson(Map json) {
    this.id = json['id'];
    this.name = json['name'];
    this.parent = json['parent'];
    this.count = json['count'];
    this.image = json['image'];
    this.description = json['description'];
    if (this.image == "") {
      //default image
      this.image =
          "http://www.nepalhardware.com/wp-content/uploads/2016/04/nepal-hardware-LOGO-01.jpg";
    }
  }
  @override
  String toString() {
    return id.toString() + ':' + name + ':' + image;
  }
}

// progress bar
var modalCircularProgressBar = new Stack(
  children: [
    new Opacity(
      opacity: 0.1,
      child: const ModalBarrier(dismissible: false, color: Colors.redAccent),
    ),
    new Center(
      child: new CircularProgressIndicator(),
    ),
  ],
);
var modalRectangularProgressBar = new Stack(
  children: [
    new Opacity(
      opacity: 0.1,
      child: const ModalBarrier(dismissible: false, color: Colors.redAccent),
    ),
    new Center(
      child: new LinearProgressIndicator(),
    ),
  ],
);

class Categories extends StatefulWidget {
  @override
  createState() => new CategoriesState();
}

class CategoriesState extends State<Categories> {
  Category selectedCat; // use to check tap on item.
  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<List>(
        future: _fetchStaticCategories(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return modalRectangularProgressBar;
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return _createListView(context, snapshot);
          }
        });
    return futureBuilder;
  }

  Future<List<Category>> _fetchStaticCategories() async {
    return _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() async {
    List<Category> _categoryList = await wc_api
        .getAsync(
            "products/categories?fields=id,name,image,parent,count,description&filter[limit]=100")
        .then((val) {
      List<Category> _categories = new List();
      Map parsedMap = JSON.decode(val.body);
      List categoryMap = parsedMap["product_categories"];
      categoryMap.forEach((f) {
        _categories.add(new Category.fromJson(f));
      });
      return _categories;
    });
    return _categoryList;
  }

// sample function to fet user from github
  Future<List<User>> _fetchStaticGithubUsers() async {
    final response = await http.get("https://api.github.com/users");
    print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<User> userList = _createUserList(responseJson);
    return userList;
  }

// Sample function to create userlist from the github
  List<User> _createUserList(List data) {
    List<User> list = new List();
    for (int i = 0; i < data.length; i++) {
      String title = data[i]["login"];
      int id = data[i]["id"];
      User movie = new User(name: title, id: id);
      list.add(movie);
    }
    return list;
  }

  Widget _createListView(BuildContext context, AsyncSnapshot snapshot) {
    var imageBoxDecoration = new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.redAccent,
          blurRadius: 2.0,
          offset: new Offset(0.0, 1.0),
        ),
      ],
    );

    RichText formatHeader(String headerText) {
      var text = new RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: new TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            new TextSpan(
                text: headerText[0],
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
            new TextSpan(text: headerText.substring(1, headerText.length)),
          ],
        ),
      );
      return text;
    }

    RichText formatDescription(String txt) {
      var text = new RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: new TextStyle(
            fontSize: 12.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            new TextSpan(text: txt),
          ],
        ),
      );
      return text;
    }

    var categoryCardDecoration = new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(20.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black,
          blurRadius: 2.0,
          offset: new Offset(0.0, 0.0),
        ),
      ],
    );
    if (snapshot.hasData) {
      List<Category> categoryList = snapshot.data;
      categoryList.sort((c1, c2) => (c2.count.compareTo(c1.count)));
      return ListView(
          children: categoryList
              .map<Widget>((Category category) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCat = category;
                    });
                    Scaffold.of(context).showSnackBar(new SnackBar(
                        content:
                            new Text("You clicked item number $selectedCat")));
                  },
                  child: Container(
                    decoration: categoryCardDecoration,
                    padding: const EdgeInsets.all(32.0),
                    child: new Column(children: [
                      new Container(
                          height: 300.0,
                          width: 300.0,
                          child: new Image.network(category.image),
                          decoration: imageBoxDecoration),
                      new Divider(
                        height: 20.0,
                      ),
                      formatHeader(category.name),
                      formatDescription(category.description),
                      /*   ListTile(
                        title: Text(category.name),
                        subtitle: Text(category.description),
                        //leading: Icon(Icons.done),
           /*             leading: CircleAvatar(
                          child: Text(category.count.toString()),
                        ),
                        */
                      ),
                      */
                      new Divider(
                        height: 2.0,
                      ),
                    ]),
                  )))
              .toList());
    }
  }
}

//////////////// Product starts here
class Products extends StatefulWidget {
  @override
  createState() => new ProductsState();
}

// Products state
class ProductsState extends State<Products> {
  Future<List> _fetchProducts() async {
    List _productsList = await wc_api
        .getAsync("products?fields=id,title&filter[limit]=100")
        .then((val) {
      List _products = new List();
      Map parsedMap = JSON.decode(val.body);
      List productmap = parsedMap["products"];
      productmap.forEach((f) {
        _products.add(f);
      });
      print(_products.length);
      return _products;
    });
    return _productsList;
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<List>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return modalCircularProgressBar;
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return _createListView(context, snapshot);
          }
        });
    return futureBuilder;
  }

  Widget _createListView(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      List productmap = snapshot.data;
      return ListView.builder(
        itemCount: productmap.length,
        itemBuilder: (context, index) {
          return new Column(children: <Widget>[
            new ListTile(
              title: Text('${productmap[index]}'),
            ),
            new Divider(
              height: 2.0,
            )
          ]);
        },
      );
    }
  }
}
// main app ends here

// Blog

class Blog extends StatefulWidget {
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
              return modalCircularProgressBar;
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
