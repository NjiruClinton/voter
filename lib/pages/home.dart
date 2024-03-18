import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Widget _positionCard(){
    return(

        //   listtile with position eg Undergraduate Student Government (USG) then a subtitle for voting ends in 3 days then an image at the right side

        ListTile(
          title: Text('Undergraduate Student Government (USG)', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),),
          subtitle: Text('Voting ends in 3 days', style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w500),),
          trailing: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('assets/images/uni.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          onTap: () {
            // navigate to the voting page
          },
        )
    );
  }


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
          _name = snapshot.docs.first.data()['name']; // Assuming 'name' is the field in your Firestore document
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

    // remove shared preferences 'votes' data
    Future<void> removeData() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('votes');
    }


    return Scaffold(
        appBar: AppBar(
          title: Text('Students Elections', style: GoogleFonts.poppins(fontWeight: FontWeight.bold),),
        ),
        // floatingActionButtonLocation:
        // FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: Container(
        //   decoration: BoxDecoration(
        //     color: Colors.deepPurple,
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   height: 50,
        //   margin: EdgeInsets.all(10),
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       primary: Colors.blueAccent,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //     ),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => AvailableElections()),
        //       );
        //     },
        //     child: Center(
        //       child: Text('Vote now', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
        //     ),
        //   ),
        // ),

        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text('Home', style: GoogleFonts.poppins(),),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
              ),
              // ListTile(
              //   title: Text('Elections', style: GoogleFonts.poppins(),),
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => ApplyCandidate()),
              //     );
              //   },
              // ),
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

                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 20),
                //     child: Text("Date & Time", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w600),)),
                // ListTile(
                //   leading: Container(
                //     // margin: EdgeInsets.all(20),
                //     height: 60,
                //     width: 60,
                //     decoration: BoxDecoration(
                //       color: Colors.grey.shade200,
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Icon(Icons.calendar_today, size: 40),
                //   ),
                //   title: Text("Starts on March 2, 2024 at 08:00AM", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                //   subtitle: Text('Ends on March 5, 2024 at 11:59PM', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                // ),
                // SizedBox(height: 20,),
                // Text("Voting ends in 3 days", style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),),
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
