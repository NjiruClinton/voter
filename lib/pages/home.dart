import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter/pages/apply_candidate.dart';
import 'package:voter/pages/electiondetails.dart';
import 'package:voter/pages/login.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  final FirebaseAuth auth = FirebaseAuth.instance;
  // final _messageStreamController = BehaviorSubject<RemoteMessage>();
  // String ?_lastMessage = "";
  //
  // _HomeState() {
  //   _messageStreamController.listen((message) {
  //     setState(() {
  //       if (message.notification != null) {
  //         _lastMessage = 'Received a notification message:'
  //             '\nTitle=${message.notification?.title},'
  //             '\nBody=${message.notification?.body},'
  //             '\nData=${message.data}';
  //       } else {
  //         _lastMessage = 'Received a data message: ${message.data}';
  //       }
  //     });
  //   });
  // }


  final User? user = FirebaseAuth.instance.currentUser;
  String? _name;

  @override
  void initState() {
    super.initState();
    _getName();
  }

  Future<void> _getName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _name = snapshot.docs.first.data()['name'];
        });
      }
    }
  }


@override
  Widget build(BuildContext context) {

    if(user == null){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }

    Future<void> removeData() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('votes');
    }


    return Scaffold(
        appBar: AppBar(
          title: Text('Students Elections', style: GoogleFonts.poppins(fontWeight: FontWeight.bold),),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              // notification snackbar

              ListTile(
                title: Text('Home', style: GoogleFonts.poppins(),),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
              ListTile(
                title: Text('About', style: GoogleFonts.poppins(),),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => About()),
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text('Sign Out', style: GoogleFonts.poppins(color: Colors.red.shade600),),
                onTap: () {
                  removeData();
                  auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/uni.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(height: 20,),

                Center(
                  child:
                  Text( _name != null ? 'Welcome, ${_name}' : 'Welcome',
                    style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                ),
                SizedBox(height: 20,),
                SizedBox(height: 20,),

                AvailableElections(),
              ],
            ),
          ),
        )
    );
  }
}


class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: GoogleFonts.poppins(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/uni.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Center(
                child:
                Text('About', style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
              ),
              SizedBox(height: 20,),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Students Deck is a platform that allows students to vote for their preferred candidates in the student government elections. The platform is secure and confidential. Your vote will not be tied to your name or email address. Please only vote once.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
              ),
              SizedBox(height: 20,),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Rules & Regulations", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold),)),
              SizedBox(height: 10,),

              Container( margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text("• The voting platform is secure and confidential. Your vote will not be tied to your name or email address. Please only vote once.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• You must be a registered student to vote. If you are not a registered student, you will not be able to vote.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• You can only submit your votes once, so make sure you vote for all the candidates you want.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• You must be an approved voter for you to apply for candidacy. After applying for candidacy you must wait approval before you are listed.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• You can only vote for one candidate per position.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 20,),

                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("How to vote", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10,),
                    Text("• Click on Vote now button below that takes you to see all positions", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• Click on each position to see the available candidates", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• Click on a candidate's more details to see all his/her details, then vote for your preferred candidate.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• Once you've voted in all positions, click submit your vote to submit it.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 10,),
                    Text("• Review all the candidates you chose and have a chance to edit incase you need to. Once everything is correct click submit.", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),),
                    SizedBox(height: 80,),
                    Divider()
                  ],
                ),
              ),
],
          ),
        ),
      ),
    );
  }
}
