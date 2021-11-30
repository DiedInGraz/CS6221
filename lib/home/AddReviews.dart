import 'package:flutter/material.dart';
import 'package:csci6221/home/ToolBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:email_auth/email_auth.dart';
import 'package:csci6221/EmailAuth.dart';
import 'package:csci6221/home/ListReviews.dart';
import 'package:csci6221/rate/StarRating.dart';
import 'package:csci6221/auth.config.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AddReviews extends StatefulWidget {
  const AddReviews({Key? key}) : super(key: key);

  @override
  _AddReviewsState createState() => _AddReviewsState();
}

class _AddReviewsState extends State<AddReviews> {

  final firestoreInstance = FirebaseFirestore.instance;
  String department = "Academy for Classical Acting";
  String professor = "Not Found? Create Professor";
  String professorFinal = "";
  String classNumber = "";
  String comment = "";
  double rating = 0;
  String emailAccount = "";
  String emailVerifyCode = "";
  List departmentList = [];
  List professors = ["Not Found? Create Professor"];

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
    });
  }

  fetchProfessorList() {
    FirebaseFirestore.instance.collection("Reviews").where("department", isEqualTo: department).get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          if(!professors.contains(result.data()['professor'])) {
            professors.add(result.data()['professor']);
          }
        });
      });
    });
  }

  inputEmpty() {
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
            child: const Text("One of the input is empty", style: TextStyle(
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

  var acs = ActionCodeSettings(
    // URL you want to redirect back to. The domain (www.example.com) for this
    // URL must be whitelisted in the Firebase Console.
      url: 'https://csci6221.page.link',
      // This must be true
      handleCodeInApp: true,
      iOSBundleId: 'com.example.csci6221',
      androidPackageName: 'com.example.csci6221',
      // installIfNotAvailable
      androidInstallApp: true,
      // minimumVersion
      androidMinimumVersion: '12');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget> [
          ToolBar('Add Reviews'),
          Flexible(
            child: DropdownButton<String>(
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
                  professors.add("Not Found? Create Professor");
                  professor = "Not Found? Create Professor";
                });
                fetchProfessorList();
              },
            ),
          ),
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
          professor == "Not Found? Create Professor" ? Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child:  TextField( // or using TextFormField and change initialValue
                    controller: TextEditingController()..text = professorFinal,
                    decoration: const InputDecoration(hintText: "New Professor Name"),
                    keyboardType: TextInputType.name,
                    onChanged: (value){
                      professorFinal = value;
                    },
                  )
            )
          )
          : Container(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: TextField( // or using TextFormField and change initialValue
                controller: TextEditingController()..text = classNumber,
                decoration: const InputDecoration(hintText: "Class Number"),
                keyboardType: TextInputType.number,
                onChanged: (value){
                  classNumber = value;
                },
              )
            )
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: TextField( // or using TextFormField and change initialValue
                controller: TextEditingController()..text = comment,
                decoration: const InputDecoration(hintText: "Comment"),
                keyboardType: TextInputType.multiline,
                onChanged: (value){
                  comment = value;
                },
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              children: [
                const Text("Easy/Hard",
                    style: TextStyle(
                        color: Colors.red,
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
          ),
          Padding (
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
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
          ),
          submitValid ? Flexible(
            child: TextField( // or using TextFormField and change initialValue
              controller: TextEditingController()..text = emailVerifyCode,
              decoration: const InputDecoration(hintText: "Verify Code"),
              keyboardType: TextInputType.number,
              onChanged: (value){
                emailVerifyCode = value;
              },
            )
          )
          : Container(),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 5, 50, 5),
            child: MaterialButton(
              minWidth: double.infinity,
              color: Colors.teal,
              child: const Text('Submit Reviews', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if(department.trim() == "" || professor.trim() == "" || classNumber.trim() == "" || comment.trim() == "" || rating == 0.0) {
                  inputEmpty();
                } else if(!emailAuth.validateOtp(recipientMail: emailAccount, userOtp: emailVerifyCode)) {
                  validationError();
                } else {
                  firestoreInstance.collection("Reviews").add(
                      {
                        "creator" : "",
                        "class" : classNumber,
                        "source" : "GWU",
                        "easyHard" : rating,
                        "reported" : false,
                        "department" : department,
                        "professor" : professorFinal,
                        "comment" : comment
                      }).then((value){
                    print(value.id);
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
                      const ListReviews()
                    ));
                  });
                }
              },
            ),
          ),
        ]
      )
    );
  }
}