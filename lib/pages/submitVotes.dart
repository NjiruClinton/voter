import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'electiondetails.dart';
import 'home.dart';

class SubmitVotes extends StatefulWidget {
  const SubmitVotes({super.key, required this.election_id});

  final String election_id;

  @override
  State<SubmitVotes> createState() => _SubmitVotesState();
}

class _SubmitVotesState extends State<SubmitVotes> {

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
    currentVotes = votesStringList.where((vote) {
      Map<String, dynamic> voteData = jsonDecode(vote);
      return voteData['election_id'] == widget.election_id;
    }).toList();
  }
  setState(() {
    currentVotes = currentVotes;
  });
  print(currentVotes);
}


  Future<void> _submitVotes() async {
    final election_id = jsonDecode(currentVotes[0])['election_id'];

    final user = FirebaseAuth.instance.currentUser;

    final electionDoc = await FirebaseFirestore.instance.collection('elections')
        .doc(election_id)
        .get();
    final votersData = electionDoc.data()?['voters'] as Map<String, dynamic>?;

    if (votersData != null && votersData.containsKey(user?.email)) {
      final voted = votersData[user?.email]['voted'];
      if (voted != null && voted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("You have already voted", style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),),
              content: Text("You cannot vote again", style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close', style: GoogleFonts.poppins(fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),),
                ),
              ],
            );
          }
      );
      return;
    }
    }


    for (var vote in currentVotes) {
      final voteMap = jsonDecode(vote);
      final position = voteMap['position'];
      final email = voteMap['email'];

      final electionDoc = await FirebaseFirestore.instance.collection('elections').doc(election_id).get();
      final electionData = electionDoc.data();
      final positionVotes = electionData?[position];
      if (positionVotes != null) {
        if (positionVotes[email] != null) {
          final currentVotes = positionVotes[email];
          electionDoc.reference.set({
            position: {
              email: currentVotes + 1
            }
          }, SetOptions(merge: true));
        } else {
          electionDoc.reference.set({
            position: {
              email: 1
            }
          }, SetOptions(merge: true));
        }
      } else {
        electionDoc.reference.set({
          position: {
            email: 1
          }
        }, SetOptions(merge: true));
      }
    }


if (votersData != null && votersData.containsKey(user?.email)) {
  electionDoc.reference.set({
    'voters': {
      user?.email: {
        'voted': true
      }
    }
  }, SetOptions(merge: true));
}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Votes submitted', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green,
      )
    );

  }



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
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AvailableElections()),
                  );
                },
                child: Center(
                  child: Text('Edit my votes', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm submission", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),),
                        content: Text("Your vote is final and cannot be changed. Are you sure you want to submit it?", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),),
                          ),
                          TextButton(
                            onPressed: () {
                              _submitVotes();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            },
                            child: Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),),
                          ),
                        ],
                      );
                    }
                  );
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: currentVotes.length,
                  itemBuilder: (context, index) {
                    final vote = jsonDecode(currentVotes[index]);
                    return ListTile(
                        leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(vote['image'])
                            ),
                      title: Text(vote['position'], style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Text("${vote['name']} ${vote['last_name']}", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),

              ],
            ),
          )
        )
      )
    );
  }
}
