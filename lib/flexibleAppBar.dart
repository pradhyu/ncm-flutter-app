import 'package:flutter/material.dart';
import 'package:sliver_fab/sliver_fab.dart';

wrapWithSilverAppBar(title, List<dynamic> itemsList, backgroundImageUrl) {
  return new Builder(
    builder: (context) => new SliverFab(
          floatingActionButton: new FloatingActionButton(
            onPressed: () => Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text("You clicked FAB!"))),
            child: new Icon(Icons.add),
          ),
          expandedHeight: 256.0,
          slivers: <Widget>[
            new SliverAppBar(
              expandedHeight: 256.0,
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
