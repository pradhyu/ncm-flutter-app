import 'package:flutter/material.dart';

//import 'package:woocommerce_api/woocommerce_api.dart';
import "./contacts.dart";
import "./blog.dart";
import "./dataModel.dart";
import "./uiUtils.dart";
import "./flexibleAppBar.dart";
import "./productDetail.dart";
import "./restCalls.dart";
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
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
    var textTheme = TextTheme(
      headline: TextStyle(fontSize: 14.0),
      body1: TextStyle(fontSize: 12.0),
      body2: TextStyle(fontSize: 9.0),
      caption: TextStyle(fontSize: 12.0),
      button: TextStyle(fontSize: 9.0),
      title: TextStyle(fontSize: 9.0),
      subhead: TextStyle(fontSize: 10.0),
      display1: TextStyle(fontSize: 12.0),
      display2: TextStyle(fontSize: 9.0),
      display3: TextStyle(fontSize: 9.0),
      display4: TextStyle(fontSize: 9.0),
    );
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
        accentTextTheme: textTheme,
        primaryTextTheme: textTheme,
        textTheme: textTheme,
      ),
      home: new MyHomePage(title: 'www.NepalConstructionMart.com'),
    );
  }
}

initForceCache() {
  forceCacheCategories(0);
  forceCacheFeaturedProducts(1, 100);
  forceCacheProducts(1, 100);
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
            new FeaturedProducts(),
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

class Categories extends StatefulWidget {
  // constructo
  Categories(this.pageId, this.title);
  final int pageId;
  final String title;
  final pageAppBarBackground =
      "http://www.nepalconstructionmart.com/wp-content/uploads/2016/04/nepal-hardware-LOGO-01.jpg";
  final categoryState = CategoriesState();
  @override
  createState() => categoryState;
}

class CategoriesState extends State<Categories> {
  Category selectedCat; // use to check tap on item.

  @override
  Widget build(BuildContext context) {
    var cacheP = categoryCacheRepo.get(widget.pageId);
    if (cacheP != null) {
      return _createListView(context, cacheP);
    } else {
      var futureBuilder = new FutureBuilder<List>(
          future: forceCacheCategories(widget.pageId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return modalRectangularProgressBar;
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else if (snapshot.hasData) {
                  return _createListView(context, snapshot.data);
                }
            }
          });
      return futureBuilder;
    }
  }

  Widget _createListView(BuildContext context, List<Category> categoryList) {
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

    if (categoryList.length > 0) {
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
  @override
  createState() => new ProductsState();
}

// Products state
class ProductsState extends State<Products>
    with SingleTickerProviderStateMixin {
  var selectedItem;
  var selectedPageId = 1;
  int limitItems = 100;

  @override
  Widget build(BuildContext context) {
    var cacheP = productCacheRepo.get(selectedPageId);
    if (cacheP != null) {
      return _createListView(context, cacheP);
    } else {
      var futureBuilder = new FutureBuilder<List>(
          future: forceCacheProducts(selectedPageId, limitItems),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return modalCircularProgressBar;
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else if (snapshot.hasData) {
                  return _createListView(context, snapshot.data);
                }
            }
          });
      return futureBuilder;
    }
  }

  Widget _createListView(BuildContext context, List<Product> productList) {
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
          padding: const EdgeInsets.all(0.0),
          child: new RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                fontSize: 12.0,
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

    formatCurrency(Product product) {
      double number = product.price;
      final formatCurrency = new NumberFormat("#,##0.00");
      return Text("Rs " + '${formatCurrency.format(number)}',
          style: new TextStyle(
              color: Colors.red, fontSize: 12.0, fontWeight: FontWeight.w800));
    }

    strikeOutPrice(double number) {
      final formatCurrency = new NumberFormat("#,##0.00");
      return new Text("(" + '${formatCurrency.format(number)}' + ")",
          style: new TextStyle(
            color: Colors.black45,
            fontSize: 10.0,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.lineThrough,
          ));
    }

    formatShortDescription(Product product) {
      if (product.shortDescription != "NA" &&
          product.shortDescription != null) {
        return Text(
          " per " +
              product.shortDescription
                  .replaceAll("<p>", "")
                  .replaceAll("</p>", "")
                  .replaceAll("&nbsp;", ""),
          style: TextStyle(
            color: Colors.black45,
            fontStyle: FontStyle.italic,
          ),
        );
      } else {
        return Text("");
      }
    }

    formatDiscount(Product product) {
      if (product.discount > 0) {
        String discountString =
            "  " + product.discount.toStringAsFixed(2) + "%";
        return new Text(discountString,
            style: new TextStyle(
              color: Colors.green[900],
              fontSize: 10.0,
            ));
      } else {
        return Text("");
      }
    }

    productSubTitle(Product product) {
      var saleFormat = Container(
          padding: EdgeInsets.only(top: 5.0),
          child: Row(children: <Widget>[
            formatCurrency(product),
            strikeOutPrice(product.regularPrice),
            formatShortDescription(product),
          ]));

      var regularFormat = Container(
          padding: EdgeInsets.only(top: 5.0),
          child: Row(children: <Widget>[
            formatCurrency(product),
            formatShortDescription(product),
          ]));

      if (product.regularPrice == product.price) {
        return regularFormat;
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
    if (productList.length > 0) {
      // may sort with id ?
      // TODO fix this
      // productList.sort((c1, c2) => (c2.title.compareTo(c1.title)));
      var productWidgetList = productList
          .map<Widget>((Product product) => GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetails(product.id)));
              },
              child: Container(
                decoration: productCardDecoration,
                child: new Row(children: [
                  new Container(
                      height: 90.0,
                      width: 90.0,
                      child: new Image.network(product.images.first.src),
                      decoration: imageBoxDecoration),
                  Expanded(
                      child: ListTile(
                          title: formatTitle(product.name),
                          subtitle: productSubTitle(product), // format currency
                          isThreeLine: false)),
                  formatDiscount(product),
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
  final pageAppBarBackground =
      "http://www.nepalconstructionmart.com/wp-content/uploads/2017/06/logo-NCM.jpg";
  @override
  createState() {
    return new FeaturedProductsState();
  }
}

class FeaturedProductsState extends State<FeaturedProducts> {
  var selectedItem;
  var selectedPageId = 1;
  int limitItems = 100;

  @override
  Widget build(BuildContext context) {
    var cacheP = featuredProductCacheRepo.get(selectedPageId);
    if (cacheP != null) {
      return _createListView(context, cacheP);
    } else {
      var futureBuilder = new FutureBuilder<List>(
          future: forceCacheFeaturedProducts(selectedPageId, 100),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return modalCircularProgressBar;
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else if (snapshot.hasData) {
                  return _createListView(context, snapshot.data);
                }
            }
          });
      return futureBuilder;
    }
  }

  Widget _createListView(
      BuildContext context, List<FeaturedProduct> productList) {
    var imageBoxDecoration = new BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      // borderRadius: new BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black45,
          blurRadius: 1.0,
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

    formatCurrency(FeaturedProduct product) {
      double number = product.price;
      final formatCurrency = new NumberFormat("#,##0.00");
      return Text(" Rs " + '${formatCurrency.format(number)}',
          style: new TextStyle(
              color: Colors.red, fontSize: 16.0, fontWeight: FontWeight.w800));
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

    formatDiscount(FeaturedProduct product) {
      if (product.discount > 0) {
        String discountString =
            "  " + product.discount.toStringAsFixed(2) + "%";
        return new Text(discountString,
            style: new TextStyle(
              color: Colors.green[900],
              fontSize: 14.0,
            ));
      }
      ;
    }

    formatShortDescription(FeaturedProduct product) {
      if (product.shortDescription != "NA" &&
          product.shortDescription != null) {
        return Text(
          " per " +
              product.shortDescription
                  .replaceAll("<p>", "")
                  .replaceAll("</p>", "")
                  .replaceAll("&nbsp;", ""),
          style: TextStyle(
            color: Colors.black45,
            fontStyle: FontStyle.italic,
          ),
        );
      }
    }

    productSubTitle(FeaturedProduct product) {
      var saleFormat = Container(
          child: Row(children: <Widget>[
        formatCurrency(product),
        strikeOutPrice(product.regularPrice),
        formatShortDescription(product),
      ]));

      var regularFromat = Container(
          child: Row(children: <Widget>[
        formatCurrency(product),
        formatShortDescription(product),
      ]));

      if (product.regularPrice == product.price) {
        return regularFromat;
      } else {
        return saleFormat;
      }
    }

    var productCardDecoration = new BoxDecoration(
      //color: Color.fromRGBO(255, 10, 10, 10.0),
      shape: BoxShape.circle,
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black26,
          blurRadius: 20.0,
          offset: new Offset(0.0, 0.0),
        ),
      ],
    );
    // TODO fix this
    // productList.sort((c1, c2) => (c2.title.compareTo(c1.title)));
    var productWidgetList = productList
        .map<Widget>((product) => GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetails(product.id)));
              },
              child: Container(
                margin: EdgeInsets.all(1.0),
                decoration: productCardDecoration,
                child: new Container(
                transform: Matrix4.skewY(-0.03),
                  // just pick first picture for now
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.all(1.0),
                  child: Column(children: <Widget>[
                    Expanded(
                        child: new Image.network(
                      product.images.first.src,
                      fit: BoxFit.fill,
                    )),
                    Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top:20.0,left: 20.0),
                          padding: EdgeInsets.all(10.0),
                            transform: Matrix4.skewY(-0.20),
                            child: new ListTile(
                              title: formatTitle(product.name),
                              subtitle: productSubTitle(product),
                              trailing: formatDiscount(product),
                              isThreeLine: true,
                            ))),
                  ]),
                  decoration: imageBoxDecoration,
                ),
              ),
            ))
        .toList();

    productCacheRepo.set(selectedPageId, productList);
    return wrapGridViewWithSilverAppBar(
        "Featured", productWidgetList, widget.pageAppBarBackground,
        maxCrossAxisExtent: 400.0, expandedHeight: 460.0);
  }
}
