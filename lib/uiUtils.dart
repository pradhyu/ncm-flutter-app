import 'package:flutter/material.dart';
//https://api.myjson.com/bins/hl6iu
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
