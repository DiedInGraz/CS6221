import 'package:flutter/material.dart';
import 'package:csci6221/home/ToolBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ListReviews extends StatefulWidget {
  const ListReviews({Key? key}) : super(key: key);

  @override
  _ListReviewsState createState() => _ListReviewsState();
}

class _ListReviewsState extends State<ListReviews> {

  List departmentList = [];
  String department = "Department";
  List professors = ["Professor"];
  String professor = "Professor";
  List classList = ["Class"];
  String classNumber = "Class";

  @override
  void initState() {
    readJson();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Fetch content from the json file
  Future<void> readJson() async {

    final String response = await rootBundle.loadString('assets/department.json');
    setState(() {
      departmentList = json.decode(response);
      departmentList.insert(0, {
        "code": "ACA",
        "description": "Department"
      });
    });
  }

  showDetail() {
    return StreamBuilder<QuerySnapshot>(
      stream: department == "Department" ? FirebaseFirestore.instance.collection("Reviews").snapshots()
                : professor == "Professor" && classNumber == "Class" ? FirebaseFirestore.instance.collection("Reviews").where("department", isEqualTo: department).snapshots()
                : professor != "Professor" && classNumber == "Class" ? FirebaseFirestore.instance.collection("Reviews").where("department", isEqualTo: department).where("professor", isEqualTo: professor).snapshots()
                : professor == "Professor" && classNumber != "Class" ? FirebaseFirestore.instance.collection("Reviews").where("department", isEqualTo: department).where("class", isEqualTo: classNumber).snapshots()
                : FirebaseFirestore.instance.collection("Reviews").where("department", isEqualTo: department).where("professor", isEqualTo: professor).where("class", isEqualTo: classNumber).snapshots(),
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
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                DocumentSnapshot ds = (snapshot.data!).docs[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 17.0, 5.0, 0.0),
                          child: Row(
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
                                        child: RichText(
                                          text: TextSpan(
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400
                                              ),
                                              children: [
                                                const TextSpan(text: "Submitted Time: "),
                                                TextSpan(
                                                    text: DateFormat('yyyy-MM-dd').format(ds['submitTime'].toDate()).toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w700
                                                    )
                                                )
                                              ]
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w400
                                            ),
                                              children: [
                                                const TextSpan(text: "Department: "),
                                                TextSpan(
                                                    text: ds['department'].toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w700
                                                    )
                                                )
                                              ]
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: RichText(
                                          text: TextSpan(
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400
                                              ),
                                              children: [
                                                const TextSpan(text: "Class: "),
                                                TextSpan(
                                                    text: ds['class'].toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w700
                                                    )
                                                )
                                              ]
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: RichText(
                                          text: TextSpan(
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400
                                              ),
                                              children: [
                                                const TextSpan(text: "Professor: "),
                                                TextSpan(
                                                    text: ds['professor'].toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w700
                                                    )
                                                )
                                              ]
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: RichText(
                                          text: TextSpan(
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400
                                              ),
                                              children: [
                                                const TextSpan(text: "Comments: "),
                                                TextSpan(
                                                    text: ds['comment'].toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w700
                                                    )
                                                )
                                              ]
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: RichText(
                                          text: TextSpan(
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: Colors.black,
                                                  fontSize: 15.0,
                                                  fontWeight: FontWeight.w400
                                              ),
                                              children: [
                                                const TextSpan(text: "Rating: "),
                                                TextSpan(
                                                    text: ds['easyHard'].toString(),
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color: Colors.red,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w700
                                                    )
                                                )
                                              ]
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                        Container(height: 16.0),
                      ],
                    )
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

  fetchProfessorList() {
    FirebaseFirestore.instance.collection("Reviews").where("department", isEqualTo: department).get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          if(!professors.contains(result.data()['professor'])) {
            professors.add(result.data()['professor']);
          }
          if(!classList.contains(result.data()['class'])) {
            classList.add(result.data()['class']);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //fetchProfessorList();
    return Scaffold(
      body: Column(
        children: <Widget> [
          ToolBar('GWBooks'),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: department,
                items: departmentList.map((item) {
                  return DropdownMenuItem<String>(
                    child: Text(item['description']),
                    value: item['description'],
                  );
                }).toList(),
                onChanged: (String? newVal) async {
                  setState(() {
                    department = newVal!;
                    professors.clear();
                    professors.add("Professor");
                    professor = "Professor";
                    classList.clear();
                    classList.add("Class");
                    classNumber = "Class";
                  });
                  fetchProfessorList();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<String>(
                    value: professor,
                    items: professors.map((item) {
                      return DropdownMenuItem<String>(
                        child: Text(item),
                        value: item,
                      );
                    }).toList(),
                    onChanged: (String? newVal) {
                      setState(() {
                        professor = newVal!;
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: classNumber,
                    items: classList.map((item) {
                      return DropdownMenuItem<String>(
                        child: Text(item),
                        value: item,
                      );
                    }).toList(),
                    onChanged: (String? newVal) {
                      setState(() {
                        classNumber = newVal!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Expanded(
              child: showDetail()
          )
        ]
      )
    );
  }
}