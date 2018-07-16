
import 'package:flutter/material.dart';
import "./dataModel.dart";
import "./restCalls.dart";
import 'dart:async';
import "./uiUtils.dart";
import 'package:intl/intl.dart';

class FeaturedProducts extends StatefulWidget {
  final pageAppBarBackground =
      "http://www.nepalconstructionmart.com/wp-content/uploads/2016/07/BEKO-Banner.jpg";

  @override
  createState() {
    return new FeaturedProductsState();
  }
}

class FeaturedProductsState extends State<FeaturedProducts> {
  var selectedItem;
  var selectedPageId = 1;
  int limitItems = 100;
  Future<List<FeaturedProduct>> _fetchProductsFromRepo(int pageId) {
    var cacheP = featuredProductCacheRepo.get(pageId);
    if (cacheP == null) return forceCacheFeaturedProducts(pageId, limitItems);
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
      shape: BoxShape.circle,
      // borderRadius: new BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black45,
          blurRadius: 2.0,
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
      color: Color.fromRGBO(255, 10, 10, 10.0),
      shape: BoxShape.circle,
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black45,
          blurRadius: 20.0,
          offset: new Offset(0.0, 0.0),
        ),
      ],
    );
    if (snapshot.hasData) {
      List<FeaturedProduct> productList = snapshot.data;
      // may sort with id ?
      // TODO fix this
      // productList.sort((c1, c2) => (c2.title.compareTo(c1.title)));
      var productWidgetList = productList
          .map<Widget>((product) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItem = product;
                  });
                  Scaffold.of(context).showSnackBar(new SnackBar(
                      content:
                          new Text("You clicked item number $selectedItem")));
                },
                child: Container(
                  margin: EdgeInsets.all(50.0),
                  decoration: productCardDecoration,
                  child: new Container(
                    // just pick first picture for now
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.all(1.0),
                    child: Column(children: <Widget>[
                      Expanded(
                          child: new Image.network(
                        product.images.first.src,
                        fit: BoxFit.scaleDown,
                      )),
                      Expanded(
                          child: new ListTile(
                        title: new Text(product.name),
                        subtitle: new Text(product.description),
                      ))
                    ]),
                    decoration: imageBoxDecoration,
                  ),
                ),
              ))
          .toList();

      productCacheRepo.set(selectedPageId, productList);

     // return wrapGridViewHorizontalSBWithSilverAppBar(
      //    "Featured Product", productWidgetList, widget.pageAppBarBackground,
     //     maxCrossAxisExtent: 500.0);
    }
  }
}
