import 'package:flutter/material.dart';
import 'package:csci6221/home/ListReviews.dart';
import 'package:csci6221/home/AddReviews.dart';

class ToolBar extends StatelessWidget {
  final String title;
  final double barHeight = 80.0;

  getTitle() {
    return title;
  }

  ToolBar(this.title);

  // cuisine.dart is not using this; need to modify that if Toolbar changed somewhere
  Container _getToolBar(BuildContext context) { // return button
    if(title == "Add Reviews") {
      return Container(
        margin: const EdgeInsets.only(right: 16.0),
        //child: new BackButton(color: Colors.white),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (BuildContext context) =>
                const ListReviews()
            ));
          },
          // size: 30.0,  // in case need to change size
        ),
      );
    } else {
      return Container(
        child: const Visibility(
          child: Text("          "),
          visible: true,
        ),
      );
    }
  }

  Container _getFilterButton(BuildContext context) {
    if(title == "GWBooks") { // filter button
      return Container(
        //margin: new EdgeInsets.only(right: 16.0),
        child: IconButton(
          icon: const Icon(Icons.add),
          color: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
                const AddReviews()
            ));
          },
          // size: 30.0,  // in case need to change size
        ),
      );
    } else {
      return Container(
        child: const Visibility(
          child: Text("              "),
          visible: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print("bar name height: "+ statusBarHeight.toString());
    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight / 2 + barHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
          colors: [
            Color(0xFF3366FF), // blue: 0xFF3366FF; purple: 0xFF9400D3; green: 0xFF3CB371
            Color(0xFF00CCFF), // blue: 0xFF00CCFF; purple: 0xFFEE82EE; green: 0xFF00FF00
          ],
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // check spacer maybe in the future
        children: <Widget>[
          _getToolBar(context),
          Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 30.0
            )
          ),
          _getFilterButton(context)
        ],
      )
    );
  }
}