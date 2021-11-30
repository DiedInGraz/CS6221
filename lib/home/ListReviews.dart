import 'package:flutter/material.dart';
import 'package:csci6221/home/ToolBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:csci6221/EmailAuth.dart';
import 'package:csci6221/auth.config.dart';

class ListReviews extends StatefulWidget {
  const ListReviews({Key? key}) : super(key: key);

  @override
  _ListReviewsState createState() => _ListReviewsState();
}

class _ListReviewsState extends State<ListReviews> {

  final firestoreInstance = FirebaseFirestore.instance;
  List departmentList = [];
  String department = "Department";
  List professors = ["Professor"];
  String professor = "Professor";
  List classList = ["Class"];
  String classNumber = "Class";
  String emailAccount = "";
  String emailVerifyCode = "";

  var emailAuth;
  bool submitValid = false;

  @override
  void initState() {
    readJson();
    super.initState();
    emailAuth = EmailAuth(
      sessionName: "GWBooks",
    );
    emailAuth.config(remoteServerConfiguration);
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

  emailEmpty() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF), // dark blue: 0xFF333366
                    shape: BoxShape.rectangle,
                  ),
                  child: const Text("The email account is incorrect", style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.blue,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500
                  ))
              )
          );
        }
    );
  }

  validationError() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF), // dark blue: 0xFF333366
                    shape: BoxShape.rectangle,
                  ),
                  child: const Text("The email account is not verified", style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.blue,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500
                  ))
              )
          );
        }
    );
  }

  reportReviews(BuildContext context, String target, String documentId) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Container(
                  width: 100.0,
                  height: 140.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF), // dark blue: 0xFF333366
                    shape: BoxShape.rectangle,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: TextField( // or using TextFormField and change initialValue
                                controller: TextEditingController()..text = emailAccount,
                                decoration: const InputDecoration(hintText: "Please verify your gwu email account"),
                                onChanged: (value){
                                  emailAccount = value;
                                },
                              )
                          ),
                          SizedBox(width: 10),
                          MaterialButton(
                              minWidth: 50,
                              color: Colors.teal,
                              child: const Text('Verify', style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                bool checkValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@gwu.edu").hasMatch(emailAccount);
                                if(emailAccount.trim() == "" || !checkValid) {
                                  emailEmpty();
                                } else {
                                  print(emailAccount);
                                  bool result = await emailAuth.sendOtp(recipientMail: emailAccount, otpLength: 5);
                                  if (result) {
                                    setState(() {
                                      submitValid = true;
                                    });
                                  }
                                }
                              }
                          )
                        ],
                      ),
                      Flexible(
                          child: TextField( // or using TextFormField and change initialValue
                            controller: TextEditingController()..text = emailVerifyCode,
                            decoration: const InputDecoration(hintText: "Verify Code"),
                            keyboardType: TextInputType.number,
                            onChanged: (value){
                              emailVerifyCode = value;
                            },
                          )
                      ),
                      MaterialButton(
                        minWidth: double.infinity,
                        color: Colors.teal,
                        child: const Text('Report', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          if(!emailAuth.validateOtp(recipientMail: emailAccount, userOtp: emailVerifyCode)) {
                            validationError();
                          } else {
                            firestoreInstance.collection("Reports").add(
                            {
                              "creator" : emailAccount,
                              "source" : "GWU",
                              "target" : target,
                              "submitTime" : Timestamp.now()
                            }).then((value){
                              print(value.id);
                              firestoreInstance.collection("Reviews").doc(documentId).update(
                                  {"reported" : true});
                              emailAccount = "";
                              emailVerifyCode = "";
                              Navigator.pop(context);
                            });
                          }
                        },
                      ),
                    ],
                  )
              )
          );
        }
    );
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
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      dismissible: DismissiblePane(onDismissed: () {}),
                      children: [
                        SlidableAction(
                          // An action can be bigger than the others.
                          flex: 2,
                          onPressed: (_) {
                            reportReviews(context, ds['creator'].toString(), ds.id);
                          },
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.report_problem,
                          label: 'Report',
                        ),
                      ],
                    ),
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
                                          ds['reported'].toString() == "true" ? const Padding(
                                            padding: EdgeInsets.only(left: 12.0),
                                            child: Text("This review has been reported", style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: Colors.red,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w900
                                            ))
                                          ) : Container(),
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
                    ),
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