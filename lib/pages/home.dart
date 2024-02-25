import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voter/pages/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  final FirebaseAuth auth = FirebaseAuth.instance;

  // widget for candidate positions
  Widget _positionCard(){
    return(
    Container(
      child: Row(
        children: [

        Text("Undergraduate Student Government(USG)")

        ]
      ),
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    // if no user is signed in, push replacement to login page
    if(user == null){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }



    return Scaffold(
appBar: AppBar(
        title: Text('Students Elections', style: GoogleFonts.lato(fontWeight: FontWeight.w500),),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {
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
      body: SafeArea(
        child: Column(
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
              child: Text('Welcome, Clinton', style: GoogleFonts.lato(fontSize: 25, fontWeight: FontWeight.bold),),
            ),
            Text("Its time to vote, here's what on the ballot", style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w500),),

          //   container with position eg Undergraduate Student Government (USG) then a subtitle for voting ends in 3 days then an image at the right side



          ],
        ),
        )
      );
  }
}
