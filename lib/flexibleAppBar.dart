import 'package:flutter/material.dart';
import 'package:sliver_fab/sliver_fab.dart';

// the expanded height id defaulted to 200.0
// itemsList is the list of items you want to show inside the
// title is something you want to show as caption that stays when you scroll
wrapWithSilverAppBar(title, List<dynamic> itemsList, backgroundImageUrl,
    {expandedHeight: 200.0, showFabBar: false}) {
  return new Builder(
    builder: (context) => new SliverFab(
          floatingActionButton: new FloatingActionButton(
            onPressed: () => Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text("You clicked $title"))),
            child: new Icon(Icons.add),
          ),
          expandedHeight: expandedHeight,
          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: expandedHeight,
              pinned: true,
              flexibleSpace: new FlexibleSpaceBar(
                title: new Text(title),
                background: new Image.network(
                  backgroundImageUrl,
                  fit: BoxFit.fitWidth,
                ),
              ),
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
    gridAspectRatio: .90}) {
  return new Builder(
     builder: (context) => Container( 
        decoration: new BoxDecoration(color: Colors.white),
       child: new CustomScrollView(
            slivers: <Widget>[
              new SliverAppBar(
                expandedHeight: expandedHeight,
              //  pinned: true
                floating: true,
                backgroundColor: Colors.redAccent,
                flexibleSpace: new FlexibleSpaceBar(
                  title: new Text(title,  style: new TextStyle(fontSize: 14.0),),
                  background: new Image.network(
                    backgroundImageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              new SliverGrid(
                gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300.0,
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
