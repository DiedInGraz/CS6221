import 'package:flutter/material.dart';
import 'package:csci6221/home/ToolBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csci6221/home/ListReviews.dart';
import 'package:csci6221/rate/StarRating.dart';

class AddReviews extends StatefulWidget {
  const AddReviews({Key? key}) : super(key: key);

  @override
  _AddReviewsState createState() => _AddReviewsState();
}

class _AddReviewsState extends State<AddReviews> {

  final firestoreInstance = FirebaseFirestore.instance;
  String department = "";
  String professor = "";
  String classNumber = "";
  String comment = "";
  double rating = 0;

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget> [
          ToolBar('Add Reviews'),
          Flexible(
            child: TextField( // or using TextFormField and change initialValue
              controller: TextEditingController()..text = department,
              decoration: const InputDecoration(hintText: "Department"),
              onChanged: (value){
                department = value;
              },
            )
          ),
          Flexible(
            child: TextField( // or using TextFormField and change initialValue
              controller: TextEditingController()..text = professor,
              decoration: const InputDecoration(hintText: "professor"),
              onChanged: (value){
                professor = value;
              },
            )
          ),
          Flexible(
            child: TextField( // or using TextFormField and change initialValue
              controller: TextEditingController()..text = classNumber,
              decoration: const InputDecoration(hintText: "Class Number"),
              onChanged: (value){
                classNumber = value;
              },
            )
          ),
          Flexible(
            child: TextField( // or using TextFormField and change initialValue
              controller: TextEditingController()..text = comment,
              decoration: const InputDecoration(hintText: "Comment"),
              onChanged: (value){
                comment = value;
              },
            )
          ),
          Row(
            children: [
              const Text("Easy/Hard",
                  style: TextStyle(
                    color: Color(0xFF00FF00),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 30.0
                  )
              ),
              StarRating(
                rating: rating,
                onRatingChanged: (rating) => setState(() => this.rating = rating),
              )
            ],
          ),

          MaterialButton(
            minWidth: double.infinity,
            color: Colors.teal,
            child: const Text('Submit Reviews', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              firestoreInstance.collection("Reviews").add(
                  {
                    "creator" : "",
                    "class" : classNumber,
                    "source" : "GWU",
                    "easyHard" : rating,
                    "reported" : false,
                    "department" : department,
                    "professor" : professor,
                    "comment" : comment
                  }).then((value){
                    print(value.id);
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
                        ListReviews()
                    ));
              });
            },
          ),
        ]
      )
    );
  }
}