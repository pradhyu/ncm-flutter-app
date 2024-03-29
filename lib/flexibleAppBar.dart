import 'package:flutter/material.dart';
import 'package:sliver_fab/sliver_fab.dart';
import "package:polygon_clipper/polygon_clipper.dart";

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 70);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// the expanded height id defaulted to 200.0
// itemsList is the list of items you want to show inside the
// title is something you want to show as caption that stays when you scroll
wrapWithSilverAppBar(title, List<dynamic> itemsList, backgroundImageUrl,
    {expandedHeight: 200.0, showFabBar: false}) {
  return new Builder(
    builder: (context) => new SliverFab(
          floatingActionButton: new FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            onPressed: () => Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text("You clicked Floating menu in : $title"))),
            isExtended: true,
            elevation: 2.0,
            child: new Icon(Icons.add),
          ),
          expandedHeight: expandedHeight,
          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: expandedHeight,
              floating: true,
              flexibleSpace: new FlexibleSpaceBar(
                  title: new Text(title),
                  background: new ClipPath(
                      child: new Image.network(
                        backgroundImageUrl,
                        fit: BoxFit.fitWidth,
                      ),
                      clipper: BottomWaveClipper())),
            ),
            new SliverList(
              delegate: new SliverChildListDelegate(
                itemsList,
              ),
            ),
          ],
        ),
  );
}

wrapGridViewWithSilverAppBar(title, List<dynamic> itemsList, backgroundImageUrl,
    {expandedHeight: 175.0,
    showFabBar: false,
    gridSpacing: 20.0,
    gridAspectRatio: .90,
    maxCrossAxisExtent: 300.0}) {
  return new Builder(
      builder: (context) => Container(
          decoration: new BoxDecoration(color: Colors.white),
          child: new CustomScrollView(
            slivers: <Widget>[
              new SliverAppBar(
                expandedHeight: expandedHeight,
                pinned: true,
                //floating: true,
                backgroundColor: Colors.redAccent,
                flexibleSpace: new FlexibleSpaceBar(
                  title: new Text(
                    title,
                    style: new TextStyle(fontSize: 14.0),
                  ),
                  background: new ClipPath(
                      child: new Image.network(
                        backgroundImageUrl,
                        fit: BoxFit.scaleDown,
                        //color: Colors.white,
                        //colorBlendMode: BlendMode.difference,
                      ),
                      clipper: BottomWaveClipper()),
                ),
              ),
              new SliverGrid(
                gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                  mainAxisSpacing: gridSpacing,
                  crossAxisSpacing: 1.0,
                  childAspectRatio:
                      gridAspectRatio, // grid width / height aspect ratio
                ),
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return itemsList[
                        index]; // pass the list it will call it with index
                  },
                  childCount: itemsList.length,
                ),
              ),
            ],
          )));
}

wrapGridViewWithSilverAppBarForProductDetail(
    title, List<dynamic> itemsList, backgroundImageUrl,
    {expandedHeight: 250.0,
    showFabBar: false,
    gridSpacing: 1.0,
    gridAspectRatio: 1.0,
    maxCrossAxisExtent: 300.0}) {
  return new Builder(
      builder: (context) => Container(
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: new CustomScrollView(
            slivers: <Widget>[
              new SliverAppBar(
                  primary: true,
                  iconTheme: new IconThemeData(
                    color: Colors.red,
                  ), // arrow color
                  expandedHeight: expandedHeight,
                  pinned: true,
                  // title: Text(title, style: new TextStyle(color: Colors.red),),
                  //floating: true,
                  backgroundColor: Colors.white,
                  flexibleSpace: new FlexibleSpaceBar(
                    title: Text(
                      title,
                      maxLines: 1,
                      style: TextStyle(color: Colors.black45,fontSize: 16),
                      textScaleFactor:1 , 
                      softWrap: true,
                    ),
                    background: new Image.network(
                      backgroundImageUrl,
                      fit:BoxFit.scaleDown,
                      colorBlendMode: BlendMode.difference,
                    ),
                  )),
              new SliverList(
                delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  if (index == 0)
                    return itemsList[index]; // error handling index > 1
                }),
              ),
            ],
          )));
}
