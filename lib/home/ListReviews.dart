import 'package:flutter/material.dart';
import 'package:csci6221/home/ToolBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListReviews extends StatefulWidget {
  const ListReviews({Key? key}) : super(key: key);

  @override
  _ListReviewsState createState() => _ListReviewsState();
}

class _ListReviewsState extends State<ListReviews> {

  @override
  void dispose() {
    super.dispose();
  }

  checkLogin() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Reviews").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData) {
          return Container(
            child: const Center(
              child: Text("Loading", style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.blue,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500
              ))
            )
          );
        } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                DocumentSnapshot ds = (snapshot.data!).docs[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 12.0, 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text("Department: " + ds['department'].toString(), style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.blue,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500
                                    )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text("Class: " + ds['class'].toString(), style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.blue,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500
                                    )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text("Professor: " + ds['professor'].toString(), style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.blue,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500
                                    )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text("Comments: " + ds['comment'].toString(), style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.blue,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500
                                    )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text("Rating: " + ds['easyHard'].toString(), style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.blue,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500
                                    )),
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                      Container(height: 16.0),
                    ],
                  )
                );
              },
              itemCount: (snapshot.data!).docs.length,
              //padding: new EdgeInsets.symmetric(vertical: 4.0) // distance from bar to the first one
            );
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget> [
          ToolBar('GWBooks'),
          Expanded(
            child: checkLogin()
          ),
        ]
      )
    );
  }
}