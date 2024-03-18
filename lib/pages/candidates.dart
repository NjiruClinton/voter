import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Candidates extends StatefulWidget {
  const Candidates({super.key, required this.position, required this.election});
  final String position;
  final Map<String, dynamic> election;

  @override
  State<Candidates> createState() => _CandidatesState();
}

class _CandidatesState extends State<Candidates> {
  List<Map<String, dynamic>> candidates = [];
  List<String> currentVotes = [];

  @override
  void initState() {
    super.initState();
    fetchCandidates();
    _loadVotesFromSharedPreferences();
  }

  Future<void> _loadVotesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? votesStringList = prefs.getStringList('votes');
    if (votesStringList != null) {
      // print(votesStringList);
      currentVotes = votesStringList;
    }
    setState(() {});
  }


  Future<void> fetchCandidates() async {
    final applicationsQuery = FirebaseFirestore.instance
        .collection('applications')
        .where('election_id', isEqualTo: widget.election['id'])
        .where('status', isEqualTo: 'approved')
        .where('position', isEqualTo: widget.position);

    List<QueryDocumentSnapshot> applications = await applicationsQuery.get().then((querySnapshot) => querySnapshot.docs);

    candidates = [];


    for (var application in applications) {
      final email = application['email'];
      final image = application['passport_image'];
      final why = application['why'];
      final plans = application['plans'];

      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) => querySnapshot.docs.first);

      final name = studentDoc['name'];
      final last_name = studentDoc['last_name'];
      final studentId = studentDoc['studentId'];

      candidates.add({
        'name': name,
        'last_name': last_name,
        'email': email,
        'studentId': studentId,
        'image': image,
        'plans': plans,
        'why': why,
      });
    }

    setState(() {});
  }

  Future<void> addVote(String electionId, String email, String position, String image, String name, String last_name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final votes = prefs.getStringList('votes') ?? [];
    final newVoteJson = jsonEncode({
      'election_id': electionId,
      'email': email,
      'position': position,
      'image': image,
      'name': name,
      'last_name': last_name,
    });

    bool voteReplaced = false;

    for (int i = 0; i < votes.length; i++) {
      final existingVoteJson = votes[i];
      final existingVote = jsonDecode(existingVoteJson);

      if (existingVote['position'] == position) {
        votes[i] = newVoteJson;
        voteReplaced = true;
        break;
      }
    }

    if (!voteReplaced) {
      votes.add(newVoteJson);
    }

    await prefs.setStringList('votes', votes);

    setState(() {
      _loadVotesFromSharedPreferences();
    });
    // print(votes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.position, style: GoogleFonts.poppins(fontWeight: FontWeight.bold,),),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Approved Candidates", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),),
                SizedBox(height: 20),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: candidates.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    final name = candidate['name'];
                    final last_name = candidate['last_name'];
                    final email = candidate['email'];
                    final image = candidate['image'];
                    final plans = candidate['plans'];
                    final why = candidate['why'];
                    final studentId  = candidate['studentId'];

                    bool votedFor = false;
                    for (final vote in currentVotes) {
                      final votedForEmail = jsonDecode(vote)['email'];
                      if (votedForEmail == email) {
                        votedFor = true;
                        break;
                      }
                    }

                    return ListTile(
                      trailing: votedFor ? Icon(Icons.check_circle, color: Colors.green, size: 30,) : null,
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(image),
                      ),
                      title: Text(
                        name + " " + last_name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          text: 'Email: $email \n',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          children: [
                            TextSpan(text: studentId + " "),
                            TextSpan(
                              text: 'More Details',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // Your popup content goes here
                                      return AlertDialog(
                                        title: Text("Read More"),
                                        content: Container(
                                          padding: EdgeInsets.all(10),
                                        child: Column(
                                            children: [
                                              ListTile(
                                                leading: CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: NetworkImage(image)
                                                ),
                                                title: Text(name + " " + last_name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                                                subtitle: Text('Candidate, ${widget.position}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                              ),

                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: SizedBox(
                                                  height: 200, // Set your desired fixed height here
                                                  width: double.infinity,
                                                  child: Image.network(
                                                    image,
                                                    fit: BoxFit.cover, // Ensure the image covers the fixed height container
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),

                                              Text(why + "\n" + plans, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                            SizedBox(height: 30),
                                              ElevatedButton(
                                                onPressed: () {
                                                  addVote(widget.election['id'], email, widget.position, image, name, last_name);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Vote for ${name}"),
                                              ),
                                            ],
                                          )
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the popup
                                            },
                                            child: Text("Close"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                            ),
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
