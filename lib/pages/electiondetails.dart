import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter/pages/candidates.dart';
import 'package:voter/pages/submitVotes.dart';

import 'apply_candidate.dart';

class ElectionDetails extends StatefulWidget {
  const ElectionDetails({super.key, required this.election});

  final Map<String, dynamic> election;

  @override
  State<ElectionDetails> createState() => _ElectionDetailsState();
}

class _ElectionDetailsState extends State<ElectionDetails> {

  List<String> currentVotes = [];

  @override
  void initState() {
    super.initState();
    _loadVotesFromSharedPreferences();
  }


  Future<void> _loadVotesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? votesStringList = prefs.getStringList('votes');
    if (votesStringList != null) {
      currentVotes = votesStringList;
    }
    setState(() {
      currentVotes = currentVotes;
    });
    // print(currentVotes);
  }


  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> election = widget.election;
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
                Text(widget.election['election_name'], style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w600),),
                SizedBox(height: 10),
                Text("Choose the candicates who will best represent you and your interests in the university. Voting is open from March 2nd to March 5th", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),),

                SizedBox(height: 20),
                Text("Positions", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 25),),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: election['positions'].length,
                  itemBuilder: (context, index) {
                    final position = election['positions'][index];
                    bool votedFor = currentVotes.any((vote) => vote.contains(position['position']));

                    return GestureDetector(
                      child: ListTile(
                        trailing: votedFor ? Icon(Icons.check_circle, color: Colors.green, size: 30,) : null,
                        leading: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.person, size: 40),
                        ),
                        title: Text(position['position'], style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(position['about'], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                            Text('2 candidates', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Candidates(position: position['position'], election: election,)));
                      },
                    );
                  }, separatorBuilder: (BuildContext context, int index) { return Divider(); },
                ),
              ],
            ),
          ),
        )
      ),

    );
  }
}


class AvailableElections extends StatefulWidget {
  const AvailableElections({super.key});

  @override
  State<AvailableElections> createState() => _AvailableElectionsState();
}

class _AvailableElectionsState extends State<AvailableElections> {
  var elections = [];
  // List<Map<String, dynamic>> elections = [];
  @override
  void initState() {
    super.initState();
    getPositions();
  }

  Future<void> getPositions() async {
    await Firebase.initializeApp();
    await FirebaseFirestore.instance.collection('elections').get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          var electionData = doc.data() as Map<String, dynamic>;
          electionData['id'] = doc.id;
          elections.add(electionData);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elections', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Elections", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),),
                Text("All current and previous elections", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: elections.length,
                  itemBuilder: (context, index) {
                    final election = elections[index];
                    return GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ElectionDetails(election: election)),
                          );
                        },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  election['election_name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                //   active text and icon
                                Icon(Icons.circle, color: Colors.green.shade400, size: 20),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(election['election_description']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
