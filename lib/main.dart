import 'package:flutter/material.dart';

//import 'package:woocommerce_api/woocommerce_api.dart';
import './woocommerce_api.dart';
import './cacheManager.dart';
import "./contacts.dart";
import "./blog.dart";
import "./dataModel.dart";
import "./uiUtils.dart";
import "./flexibleAppBar.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:intl/intl.dart';
// fo firebase
// https://pub.dartlang.org/packages/firebase_messaging#-readme-tab-
//import 'package:firebase_messaging/firebase_messaging.dart';
// for firebase ends here

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     initForceCache();
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

final Map<int, List<Category>> categoryCacheHolder = {};
CategoryCachingRepository categoryCacheRepo =
    new CategoryCachingRepository(categoryCacheHolder);

final Map<int, List<Product>> productCacheHolder = {};
ProductCachingRepository productCacheRepo =
    new ProductCachingRepository(productCacheHolder);

initForceCache() {
  forceCacheCategories(0);
  forceCacheProducts(1, 100);
  forceCacheProducts(2, 100);
}

// cache calls
Future<List<Product>> forceCacheProducts(int pageId, int itemsLimit) async {
  var _productsList = await wc_api
      .getAsync("/wp-json/wc/v2/products/?per_page=" +
          itemsLimit.toString() +
          "&page=" +
          pageId.toString() +
          "&_fields=name,id,categories,price,regular_price,sale_price,on_sale,featured,images")
      .then((val) {
    List<Product> _products = new List();
    List productMapList = JSON.decode(val.body);
    productMapList?.forEach((f) {
      var prod = new Product.fromJson(f);
      _products.add(prod);
    });
    productCacheRepo.set(pageId, _products);
    return _products;
  });
  return _productsList;
}

Future<List<Category>> forceCacheCategories(int parentId) async {
  var restUrl = "/wp-json/wc/v2/products/categories?parent=" +
      parentId.toString() +
      "&_fields=id,name,image,parent,count,description&per_page=100";
  List<Category> _categoryList = await wc_api
      // only show parent=0 that's major category
      // then drill down to sub-categories
      .getAsync(restUrl)
      .then((val) {
    //v2 rest api woo /wordpress returns list of maps with category
    List categoriesMapList = JSON.decode(val.body);
    List<Category> _categories = new List();
    categoriesMapList.forEach((f) {
      _categories.add(new Category.fromJson(f));
    });
    categoryCacheRepo.set(parentId, _categories);
    return _categories;
  });
  return _categoryList;
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
            new Container(color: Colors.black),
            new Categories(0, "Categories"), // pageId =0
            new Products(1),
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
                icon: new Icon(Icons.remove_circle),
                title: new Text("Featured")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.shop), title: new Text("Category")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.shop_two), title: new Text("Product")),
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

class Categories extends StatefulWidget {
  // constructo
  Categories(this.pageId, this.title);
  final int pageId;
  final String title;
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
        future: _fetchCategoriesFromRepo(widget.pageId),
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

  Future<List<Category>> _fetchCategoriesFromRepo(int parentId) {
    var cacheP = categoryCacheRepo.get(parentId);
    if (cacheP == null) return forceCacheCategories(parentId);
    // future wrapper
    return Future.value(cacheP);
  }

  Widget _createListView(BuildContext context, AsyncSnapshot snapshot) {
    var imageBoxDecoration = new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(18.0),
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
            fontSize: 10.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            new TextSpan(
                text: headerText[0],
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black87)),
            new TextSpan(
                text:
                    headerText.substring(1, min(25, headerText.length)) + ".."),
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

    List<Widget> _buildCategoryTileList(categoryList) {
      var categoryCardDecoration = new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black,
            blurRadius: 2.0,
            offset: new Offset(2.0, 0.0),
          ),
        ],
      );
      var categoryTileList = categoryList
          .map<Widget>(
            (Category category) => GestureDetector(
                onTap: () {
                  // go to another screen on tap if the category has sub categories
                  if (category.parent == 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Categories(category.id, category.name)));
                  }
                },
                child: Container(
                    decoration: categoryCardDecoration,
                    padding: const EdgeInsets.only(top: 5.0),
                    margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: new Column(children: [
                      new Container(
                        height: 165.0,
                        width: 200.0,
                        child:
                            new Image.network(category.image, fit: BoxFit.fill),
                        // decoration: imageBoxDecoration,
                      ),
                      formatHeader(category.name),
                      // formatDescription(category.description),
                    ]))),
          )
          .toList();
      return categoryTileList;
    }

    if (snapshot.hasData) {
      List<Category> categoryList = snapshot.data;
      categoryList.sort((c1, c2) => (c2.count.compareTo(c1.count)));
      categoryCacheRepo.set(widget.pageId, categoryList);
      //return categoriesGridView;
      // figure how how to use silverFab??
      // todo
      return wrapGridViewWithSilverAppBar(widget.title,
          _buildCategoryTileList(categoryList), widget.pageAppBarBackground);
    }
  }
}

//////////////// Product starts here
class Products extends StatefulWidget {
  final int pageId;
  Products(this.pageId);
  final pageAppBarBackground =
      "http://www.nepalconstructionmart.com/wp-content/uploads/2016/11/WAL-PAPER-SCROL.jpg";
  var productStateCache = new ProductsState();

  @override
  createState() => new ProductsState();
}

// Products state
class ProductsState extends State<Products>
    with SingleTickerProviderStateMixin {
  var selectedItem;
  var selectedPageId = 1;
  int limitItems = 100;

  Future<List<Product>> _fetchProductsFromRepo(int pageId) {
    var cacheP = productCacheRepo.get(pageId);
    if (cacheP == null) return forceCacheProducts(pageId, limitItems);
    // future wrapper
    return Future.value(cacheP);
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<List>(
        future: _fetchProductsFromRepo(selectedPageId),
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
          padding: const EdgeInsets.all(2.0),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black87)),
                new TextSpan(text: headerText.substring(1, headerText.length)),
              ],
            ),
          ));

      return textContainer;
    }

    formatCurrency(double number) {
      final formatCurrency = new NumberFormat("#,##0.00");
      return new Text(" Rs" + '${formatCurrency.format(number)}',
          style: new TextStyle(
              color: Colors.red, fontSize: 13.0, fontWeight: FontWeight.w800));
    }

    strikeOutPrice(double number) {
      final formatCurrency = new NumberFormat("#,##0.00");
      return new Text("(" + '${formatCurrency.format(number)}' + ")",
          style: new TextStyle(
            color: Colors.black45,
            fontSize: 11.0,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.lineThrough,
          ));
    }

    productSubTitle(Product product) {
      String discountString = "  " + product.discount.toStringAsFixed(2) + "%";
      var saleFormat = Container(
          child: Row(children: <Widget>[
        formatCurrency(product.price),
        strikeOutPrice(product.regularPrice),
        new Text(
          discountString,
          style: new TextStyle(
            color: Colors.green[900],
            fontSize: 14.0,
          ),
        ),
      ]));

      var regularFromat = Container(
          child: Row(children: <Widget>[
        formatCurrency(product.price),
      ]));

      if (product.regularPrice == product.price) {
        return regularFromat;
      } else {
        return saleFormat;
      }
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
      var productWidgetList = productList
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
                  Expanded(
                      child: ListTile(
                    title: formatTitle(product.name),
                    subtitle: productSubTitle(product), // format currency
                  )),
                ]),
              )))
          .toList();

      var paginationWidget = new Container(
        height: 70.0,
        width: 70.0,
        child: new ListView(
          addRepaintBoundaries: true,
          scrollDirection: Axis.horizontal,
          children: new List.generate(10, (int index) {
            var label = index + 1;
            return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPageId = label;
                  });
                },
                child: Card(
                  margin: EdgeInsets.only(top: 20.0),
                  color: Colors.white,
                  shape: CircleBorder(
                      side: BorderSide(width: 2.0, color: Colors.redAccent)),
                  child: new Container(
                    padding: EdgeInsets.all(16.0),
                    child: new Text("$label",
                        style: new TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Roboto',
                          color: Colors.red[label * 10],
                        )),
                  ),
                ));
          }),
        ),
      );

      productCacheRepo.set(selectedPageId, productList);
      var productWidgetListWithPagination = List<Widget>();
      productWidgetListWithPagination.add(paginationWidget);
      productWidgetListWithPagination.addAll(productWidgetList);
      return wrapWithSilverAppBar("Product", productWidgetListWithPagination,
          widget.pageAppBarBackground);
    }
  }
}
// main app ends here

class FeaturedProducts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new FeaturedProductsState();
  }
}

class FeaturedProductsState extends State<Products> {
  var selectedItem;
  var selectedPageId = 1;
  int limitItems = 100;
  Future<List<Product>> _fetchProductsFromRepo(int pageId) {
    var cacheP = productCacheRepo.get(pageId);
    if (cacheP == null) return forceCacheProducts(pageId, limitItems);
    // future wrapper
    return Future.value(cacheP);
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<List>(
        future: _fetchProductsFromRepo(selectedPageId),
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
          padding: const EdgeInsets.all(2.0),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black87)),
                new TextSpan(text: headerText.substring(1, headerText.length)),
              ],
            ),
          ));

      return textContainer;
    }

    formatCurrency(double number) {
      final formatCurrency = new NumberFormat("#,##0.00");
      return new Text(" Rs" + '${formatCurrency.format(number)}',
          style: new TextStyle(
              color: Colors.red, fontSize: 13.0, fontWeight: FontWeight.w800));
    }

    strikeOutPrice(double number) {
      final formatCurrency = new NumberFormat("#,##0.00");
      return new Text("(" + '${formatCurrency.format(number)}' + ")",
          style: new TextStyle(
            color: Colors.black45,
            fontSize: 11.0,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.lineThrough,
          ));
    }

    productSubTitle(Product product) {
      String discountString = "  " + product.discount.toStringAsFixed(2) + "%";
      var saleFormat = Container(
          child: Row(children: <Widget>[
        formatCurrency(product.price),
        strikeOutPrice(product.regularPrice),
        new Text(
          discountString,
          style: new TextStyle(
            color: Colors.green[900],
            fontSize: 14.0,
          ),
        ),
      ]));

      var regularFromat = Container(
          child: Row(children: <Widget>[
        formatCurrency(product.price),
      ]));

      if (product.regularPrice == product.price) {
        return regularFromat;
      } else {
        return saleFormat;
      }
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
      var productWidgetList = productList
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
                  Expanded(
                      child: ListTile(
                    title: formatTitle(product.name),
                    subtitle: productSubTitle(product), // format currency
                  )),
                ]),
              )))
          .toList();

      var paginationWidget = new Container(
        height: 70.0,
        width: 70.0,
        child: new ListView(
          addRepaintBoundaries: true,
          scrollDirection: Axis.horizontal,
          children: new List.generate(10, (int index) {
            var label = index + 1;
            return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPageId = label;
                  });
                },
                child: Card(
                  margin: EdgeInsets.only(top: 20.0),
                  color: Colors.white,
                  shape: CircleBorder(
                      side: BorderSide(width: 2.0, color: Colors.redAccent)),
                  child: new Container(
                    padding: EdgeInsets.all(16.0),
                    child: new Text("$label",
                        style: new TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Roboto',
                          color: Colors.red[label * 10],
                        )),
                  ),
                ));
          }),
        ),
      );

      productCacheRepo.set(selectedPageId, productList);
      var productWidgetListWithPagination = List<Widget>();
      productWidgetListWithPagination.add(paginationWidget);
      productWidgetListWithPagination.addAll(productWidgetList);
      return wrapWithSilverAppBar("Product", productWidgetListWithPagination,
          widget.pageAppBarBackground);
    }
  }
}
