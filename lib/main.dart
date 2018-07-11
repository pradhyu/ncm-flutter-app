import 'package:flutter/material.dart';

//import 'package:woocommerce_api/woocommerce_api.dart';
import './woocommerce_api.dart';
import "./contacts.dart";
import "./blog.dart";
import "./flexibleAppBar.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


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
        primaryColor: Colors.red[700],
        secondaryHeaderColor: Colors.red[300],
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

  String title;
  final tabTitles = ["Category", "Product", "Review", "Blog", "Contact"];

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
        body: new PageView(
          children: [
            new Categories(),
            new Products(),
            new Container(color: Colors.black),
            new Blog(),
            new ContactsWidget(),
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
      widget.title = widget.tabTitles[page];
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
  final pageAppBarBackground =
      "http://www.nepalhardware.com/wp-content/uploads/2016/04/nepal-hardware-LOGO-01.jpg";
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

    formatHeader(String headerText) {
      var text = new RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: new TextStyle(
            fontSize: 13.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            new TextSpan(
                text: headerText[0],
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0,color: Colors.black87)),
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
      var categoriesList = categoryList
          .map<Widget>((Category category) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedCat = category;
                });
                Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text("You clicked item number $selectedCat")));
              },
              child: Container(
                decoration: categoryCardDecoration,
                padding: const EdgeInsets.all(32.0),
                child: new Column(children: [
                  new Container(
                      height: 250.0,
                      width: 250.0,
                      child: new Image.network(category.image),
                      decoration: imageBoxDecoration),
                  new Divider(
                    height: 20.0,
                  ),
                  formatHeader(category.name),
                  formatDescription(category.description),
                  new Divider(
                    height: 2.0,
                  ),
                ]),
              )))
          .toList();
      return wrapWithSilverAppBar(
          "Categories", categoriesList, widget.pageAppBarBackground);
    }
  }
}

class ProductImage {
  int id;
  String src;
  int position;
  ProductImage.fromJson(Map json) {
    this.id = json['id'];
    this.src = json['src'];
    this.position = json['position'];
  }
}

class Product {
  int id;
  String title;
  int price;
  int regularPrice;
  String priceHtml;
  List<ProductImage> images = new List();
  List<String> categories =
      new List(); // for some reason category object is not used here

  Product.fromJson(Map json) {
    this.id = json['id'];
    this.title = json['title'];
    if (json['price'] != null && json['price'] != "") {
      this.price = int.parse(json['price']);
    }
    if (json['regular_price'] != null && json['regular_price'] != "") {
      this.regularPrice = int.parse(json['regular_price']);
    }
    this.priceHtml = json['price_html'];

    json['categories']?.forEach((categoryName) {
      this.categories.add(categoryName);
    });

    json['images']?.forEach((imageJson) {
      this.images.add(new ProductImage.fromJson(imageJson));
    });
  }
}

class ProductDetail {
  Product product;
  String description;
  String attributes; //??
  ProductDetail.fromJson(Map json) {
    this.description = json['description'];
  }
}

//////////////// Product starts here
class Products extends StatefulWidget {
  final pageAppBarBackground =
      "http://www.nepalconstructionmart.com/wp-content/uploads/2016/11/WAL-PAPER-SCROL.jpg";
  var productStateCache = new ProductsState();

  @override
  createState() => productStateCache;
}

// Products state
class ProductsState extends State<Products> {
  var selectedItem;
  int limitItems = 50;
  Future<List<Product>> _fetchProducts() async {
    List<Product> _productsList = await wc_api
        .getAsync(
            "products?fields=id,title,images,regular_price,price&filter[limit]=$limitItems")
        .then((val) {
      List<Product> _products = new List();
      print("length:$_products.length");
      Map parsedMap = JSON.decode(val.body);
      List productmap = parsedMap[
          "products"]; // when using products/id you will get product as key otherwise products
      productmap?.forEach((f) {
        var prod = new Product.fromJson(f);
        _products.add(prod);
      });
      // if id passed , only one item is returned and with key product
      if (parsedMap["product"] != null) {
        _products.add(new Product.fromJson(parsedMap["product"]));
      }
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
    var imageBoxDecoration = new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.red,
          blurRadius: 10.0,
          offset: new Offset(0.0, 0.0),
        ),
      ],
    );

    formatTitle(String headerText) {
      var textContainer = Container(
          padding: const EdgeInsets.all(10.0),
          child: new RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                fontSize: 13.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                new TextSpan(
                    text: headerText[0],
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20.0,color: Colors.black87)),
                new TextSpan(text: headerText.substring(1, headerText.length)),
              ],
            ),
          ));

      return textContainer;
    }

    var productCardDecoration = new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(2.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black,
          blurRadius: 2.0,
          offset: new Offset(0.0, 0.0),
        ),
      ],
    );
    if (snapshot.hasData) {
      List<Product> productList = snapshot.data;
      // may sort with id ?
      // TODO fix this
      // productList.sort((c1, c2) => (c2.title.compareTo(c1.title)));
      var productsList = productList
          .map<Widget>((Product product) => GestureDetector(
              onTap: () {
                setState(() {
                  selectedItem = product;
                });
                Scaffold.of(context).showSnackBar(new SnackBar(
                    content:
                        new Text("You clicked item number $selectedItem")));
              },
              child: Container(
                decoration: productCardDecoration,
                child: new Row(children: [
                  new Container(
                      height: 100.0,
                      width: 100.0,
                      // just pick first picture for now
                      child: new Image.network(product.images.first.src),
                      decoration: imageBoxDecoration),
                  Expanded(child: formatTitle(product.title)),
                ]),
              )))
          .toList();
      return wrapWithSilverAppBar(
          "Product", productsList, widget.pageAppBarBackground);
    }
  }
}
// main app ends here

