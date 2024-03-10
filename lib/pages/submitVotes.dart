import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmitVotes extends StatefulWidget {
  const SubmitVotes({super.key});

  @override
  State<SubmitVotes> createState() => _SubmitVotesState();
}

class _SubmitVotesState extends State<SubmitVotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary', style: GoogleFonts.poppins(fontWeight: FontWeight.bold,),),
      ),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            // color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 50,
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SubmitVotes()),
                  // );
                },
                child: Center(
                  child: Text('Edit my votes', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SubmitVotes()),
                  // );
                },
                child: Center(
                  child: Text('Submit', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                ),
              ),
            ],
          ),
        ),

        body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text("You're about to submit your votes", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold),),
                SizedBox(height: 20),
                Text("Your vote is final and cannot be changed. Are you sure you want to submit it?", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
              SizedBox(height: 20),
              //   listTile with position and the candidate selected
                ListTile(
                  leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/student.jpeg')
                  ),
                  title: Text("School Presidency", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text('Clinton Njiru', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                ),

              ],
            ),
          )
        )
      )
    );
  }
}
