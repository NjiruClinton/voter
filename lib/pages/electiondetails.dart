import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubmitVotes(election_id: election['id'])),
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

                    final applications_data = widget.election['applications'] as Map<String, dynamic>;
                    final approvedApplications = applications_data.values.where((application) => application['position'] == position['position'] && application['status'] == 'approved').toList();



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
                            Text('${approvedApplications.length} candidates', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Candidates(position: position['position'], election: election,)));
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
    return Container(
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
                String startDateString = election['election_start_date'];
                String endDateString = election['election_end_date'];

                DateFormat dateFormat = DateFormat('MM/dd/yyyy');
                DateTime startDate = dateFormat.parse(startDateString);
                DateTime endDate = dateFormat.parse(endDateString);

                bool isEnded = endDate.isBefore(DateTime.now());
                bool isStarted = startDate.isBefore(DateTime.now());
                bool released = election['results'];

                String formattedDateRange = DateFormat('MMMM dd, yyyy').format(startDate) + ' - ' + DateFormat('MMMM dd, yyyy').format(endDate);

                return GestureDetector(
                  onTap: () {
                    if (isEnded && released) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Results(election: election,)),
                      );
                    } else if(isEnded && !released) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Results not released yet'),
                        duration: Duration(seconds: 2),
                      ));
                    }
                    else if (isStarted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            ElectionDetails(election: election,)),
                      );
                    }
                  },
                  child: !isStarted ? Container(
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(isEnded ? 'Ended' : isStarted ? 'Active' : 'Upcoming', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isEnded ? Colors.red : isStarted ? Colors.green : Colors.blue),),

                          ],
                        ),

                        SizedBox(height: 8),
                        Text( formattedDateRange, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

                        Text(election['election_description']),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text("Apply as a voter", style: GoogleFonts.poppins( fontWeight: FontWeight.bold, color: Colors.white),),
                                onPressed: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ApplyVoter(election: election)),
                                  );
                                }),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text("Apply for candidacy", style: GoogleFonts.poppins( fontWeight: FontWeight.bold, color: Colors.white),),
                                onPressed: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChoosePosition(election: election)),
                                  );
                                  })
                            ],
                          ),
                        ],
                      ),
                  ) : Container(
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(isEnded ? 'Ended' : isStarted ? 'Active' : 'Upcoming', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isEnded ? Colors.red : isStarted ? Colors.green : Colors.blue),),

                          ],
                        ),

                        SizedBox(height: 8),
                        Text( formattedDateRange, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

                        Text(election['election_description']),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
    );
  }
}


class Results extends StatefulWidget {
  const Results({super.key, required this.election});

  final Map<String, dynamic> election;

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {

  getResults() {
    Map<String, dynamic> election = widget.election;
    List<Widget> results = [];


    for (var position in election['positions']) {
      int totalVotes = 0;
      election[position['position']].forEach((candidate, votes) {
        totalVotes += votes as int;
      });

      double maxPercentage = 0;
      String topCandidate = '';
      election[position['position']].forEach((candidate, votes) {
        double percentage = (votes / totalVotes) * 100;
        if (percentage > maxPercentage) {
          maxPercentage = percentage;
          topCandidate = candidate;
        }
      });

      results.add(
        Text(position['position'], style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w600),),
      );

      for (var candidate in election[position['position']].keys) {
        double percentage = (election[position['position']][candidate] / totalVotes) * 100;

        results.add(
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('applications').where('email', isEqualTo: candidate).get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasData) {
                var application = snapshot.data!.docs[0].data() as Map<String, dynamic>;
                return FutureBuilder(
                  future: FirebaseFirestore.instance.collection('students').where('email', isEqualTo: candidate).get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasData) {
                      var student = snapshot.data!.docs[0].data() as Map<String, dynamic>;
                      Widget leadingWidget = SizedBox();
                      if (candidate == topCandidate) {
                        leadingWidget = Icon(Icons.star, color: Colors.yellow, size: 30);
                      }
                      return ListTile(
                        trailing: leadingWidget,
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(application['passport_image']),
                        ),
                        title: Text('${student['name']} ${student['last_name']}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${election[position['position']][candidate]} votes', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                            Text('${percentage.toStringAsFixed(2)}%', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                          ],
                        ),
                      );
                    }
                    return CircularProgressIndicator();
                  },
                );
              }
              return CircularProgressIndicator();
            },
          ),
        );
      }
    }
    return results;
  }


 int getTotalVotes() {
  int totalVotes = 0;
  Map<String, dynamic> voters = widget.election['voters'];
  voters.forEach((key, value) {
    if (value['voted'] == true) {
      totalVotes++;
    }
  });
  return totalVotes;
}

int getEligibleVoters() {
  int eligibleVoters = 0;
  Map<String, dynamic> voters = widget.election['voters'];
  voters.forEach((key, value) {
    if (value['status'] == 'approved') {
      eligibleVoters++;
    }
  });
  return eligibleVoters;
}



  displayVotingRate() {
  int totalVotes = getTotalVotes();
  int eligibleVoters = getEligibleVoters();

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: MediaQuery.of(context).size.width * 0.45,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total votes", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),),
                  SizedBox(height: 10),
                  Text(totalVotes.toString(), style: GoogleFonts.lato(fontSize: 25, fontWeight: FontWeight.w900),),
                ],
              )
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.45,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Eligible Voters", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),),
                  SizedBox(height: 10),
                  Text(eligibleVoters.toString(), style: GoogleFonts.lato(fontSize: 25, fontWeight: FontWeight.w900),),
                ],
              )
          )
        ],
      ),
      SizedBox(height: 20),
      Container(
          padding: EdgeInsets.all(30),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Voting Rate", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),),
              SizedBox(height: 10),
              Text('${(totalVotes / eligibleVoters * 100).toStringAsFixed(2)}%', style: GoogleFonts.lato(fontSize: 25, fontWeight: FontWeight.w900),),
            ],
          )
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results', style: GoogleFonts.poppins(fontWeight: FontWeight.bold,),),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                displayVotingRate(),
                SizedBox(height: 20),

                getResults().length > 0 ? Column(
                  children: getResults(),
                ) : Container(),

                SizedBox(height: 20),
              ],
            ),
          ),
        )
      ),
    );
  }
}
