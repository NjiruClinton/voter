import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voter/pages/candidates.dart';
import 'package:voter/pages/submitVotes.dart';

class ElectionDetails extends StatefulWidget {
  const ElectionDetails({super.key});

  @override
  State<ElectionDetails> createState() => _ElectionDetailsState();
}

class _ElectionDetailsState extends State<ElectionDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Election Details', style: GoogleFonts.poppins(fontWeight: FontWeight.bold,),),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 50,
        margin: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubmitVotes()),
            );
          },
          child: Center(
            child: Text('Submit your votes', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Students General Elections 2024', style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w600),),
                SizedBox(height: 10),
                Text("Choose the candicates who will best represent you and your interests in the university. Voting is open from March 2nd to March 5th", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),),

                SizedBox(height: 20),
                Text("Positions", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 25),),

                ListTile(
                  leading: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person, size: 40),
                  ),
                  title: Text("School President", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text('2 Candidates', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Candidates()));
                  },
                ),
                Divider(),

                ListTile(
                  leading: Container(
                    // margin: EdgeInsets.all(20),
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person_2, size: 40),
                  ),
                  title: Text("Vice President", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text('2 Candidates', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                ),
                Divider(),
                ListTile(
                  leading: Container(
                    // margin: EdgeInsets.all(20),
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person_2, size: 40),
                  ),
                  title: Text("Secretary General", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Text('2 Candidates', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),

                ),
                Divider(),
              ],
            ),
          ),
        )
      ),

    );
  }
}
