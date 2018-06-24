import 'package:flutter/material.dart';

//import 'package:woocommerce_api/woocommerce_api.dart';
import './woocommerce_api.dart';
import 'package:english_words/english_words.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  int _counter = 0;

  /// This controller can be used to programmatically
  /// set the current displayed page
  PageController _pageController;
  int _page = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
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
            new Container(color: Colors.black38)
          ],

          /// Specify the page controller
          controller: _pageController,
          onPageChanged: onPageChanged,
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: new Icon(Icons.menu),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: new BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.shop), title: new Text("Categories")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.shop_two), title: new Text("Products")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.rate_review), title: new Text("Product Reviews"))
          ],
          onTap: navigationTapped,
          currentIndex: _page,
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
    return this.name + " -> " + this.id.toString();
  }
  User({this.name, this.id});
}


// Category State
class Categories extends StatefulWidget {
  @override
  createState() => new CategoriesState();
}
class CategoriesState extends State<Categories> {

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<List>(
        future: _fetchStaticCategories(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return _createListView(context, snapshot);
          }
        });
    return futureBuilder;
  }

Future<List<User>> _fetchStaticCategories() async {
  final response = await http.get("https://api.github.com/users");
  print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<User> userList = _createUserList(responseJson);
  return userList;
}

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
              return CircularProgressIndicator();
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



// Examples on how to use stateful widget or state 
class RandomWords extends StatefulWidget {
  @override
  createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  @override
  Widget build(BuildContext context) {
    final wordPair = new WordPair.random();

    return Column(

        // Column is also layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Invoke "debug paint" (press "p" in the console where you ran
        // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
        // window in IntelliJ) to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(wordPair.asPascalCase),
          new Text(wordPair.asLowerCase),
          new Text(wordPair.asUpperCase),
        ]);
  }
}
