import 'package:flutter/material.dart';
import 'package:sliver_fab/sliver_fab.dart';

// the expanded height id defaulted to 200.0
// itemsList is the list of items you want to show inside the 
// title is something you want to show as caption that stays when you scroll
wrapWithSilverAppBar(title, List<dynamic> itemsList, backgroundImageUrl, {expandedHeight:200.0}) {
  return new Builder(
    builder: (context) => new SliverFab(
          floatingActionButton: new FloatingActionButton(
            onPressed: () => Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text("You clicked FAB!"))),
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
