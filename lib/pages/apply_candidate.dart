import 'dart:io';
import 'package:emailjs/emailjs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';

class ApplyCandidate extends StatefulWidget {
  const ApplyCandidate({super.key});

  @override
  State<ApplyCandidate> createState() => _ApplyCandidateState();
}

class _ApplyCandidateState extends State<ApplyCandidate> {

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
                    return Container(
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


class ElectionItem extends StatelessWidget {
  final String name;
  final String description;

  const ElectionItem({
    super.key,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                name,
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
          Text(description),
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
              })
            ],
          ),

        ],
      ),
    );
  }
}


class ChoosePosition extends StatefulWidget {
  const ChoosePosition({super.key, required this.election});

  final Map<String, dynamic> election;

  @override
  State<ChoosePosition> createState() => _ChoosePositionState();
}
class _ChoosePositionState extends State<ChoosePosition> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> election = widget.election;
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Position', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("Available Positions", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),)),
                Center(child: Text("You can only apply for one position", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: election['positions'].length,
                  itemBuilder: (context, index) {
                    final position = election['positions'][index];
                    return GestureDetector(
                      child: PositionItem(
                        position: position['position'],
                        description: position['about'],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ApplyForm(position: position, election: election)),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          )
        )
      ),
    );
  }
}


class PositionItem extends StatelessWidget {
  final String position;
  final String description;

  const PositionItem({
    super.key,
    required this.position,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                position,
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
          Text(description, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class ApplyForm extends StatefulWidget {
  const ApplyForm({super.key, required this.position, required this.election});

  final Map<String, dynamic> position;
  final Map<String, dynamic> election;

  @override
  State<ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends State<ApplyForm> {

  final _formKey = GlobalKey<FormState>();
  TextEditingController _whyController = TextEditingController();
  TextEditingController _plansController = TextEditingController();

  File? resumeFile;
  File? transcriptFile;
  File? passportImageFile;

  String? resumeDownloadURL;
  String? transcriptDownloadURL;
  String? passportImageDownloadURL;

 Future<void> selectFile(String type) async {
  List<String> allowedExtensions;
  int maxFileSize = 5 * 1024 * 1024;
  switch (type) {
    case 'resume':
    case 'transcript':
      allowedExtensions = ['pdf'];
      break;
    case 'passport':
      allowedExtensions = ['png', 'jpg', 'jpeg'];
      break;
    default:
      allowedExtensions = [];
      break;
  }

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: allowedExtensions
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    if (file.lengthSync() > maxFileSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected file is too large. Please select a file smaller than 5MB.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            backgroundColor: Colors.redAccent
        ),
      );
      return;
    }

    switch (type) {
      case 'resume':
        setState(() {
          resumeFile = file;
        });
        break;
      case 'transcript':
        setState(() {
          transcriptFile = file;
        });
        break;
      case 'passport':
        setState(() {
          passportImageFile = file;
        });
        break;
    }
  }
}

  Future<void> uploadFilesToFirebase() async {
    print("uploading...");
    FirebaseStorage storage = FirebaseStorage.instance;

    if (resumeFile != null) {
      String resumeFilePath = 'resumes/${DateTime.now().millisecondsSinceEpoch}.${resumeFile!.path.split('.').last}';
      Reference resumeRef = storage.ref().child(resumeFilePath);
      UploadTask resumeUploadTask = resumeRef.putFile(resumeFile!);
      await resumeUploadTask.whenComplete(() => null);
      resumeDownloadURL = await resumeRef.getDownloadURL();
    } else{
      return;
    }

    if (transcriptFile != null) {
      String transcriptFilePath = 'transcripts/${DateTime.now().millisecondsSinceEpoch}.${transcriptFile!.path.split('.').last}';
      Reference transcriptRef = storage.ref().child(transcriptFilePath);
      UploadTask transcriptUploadTask = transcriptRef.putFile(transcriptFile!);
      await transcriptUploadTask.whenComplete(() => null);
      transcriptDownloadURL = await transcriptRef.getDownloadURL();
    } else{
      return;
    }

    if (passportImageFile != null) {
      String passportImageFilePath = 'passports/${DateTime.now().millisecondsSinceEpoch}.${passportImageFile!.path.split('.').last}';
      Reference passportImageRef = storage.ref().child(passportImageFilePath);
      UploadTask passportImageUploadTask = passportImageRef.putFile(passportImageFile!);
      await passportImageUploadTask.whenComplete(() => null);
      passportImageDownloadURL = await passportImageRef.getDownloadURL();
    } else{
      return;
    }
  }

  bool _isApplying = false;
  void submitForm() async {
    // check if files are there
    if (resumeFile == null || transcriptFile == null || passportImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required files'), backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isApplying = true;
    });
    try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to apply')),
      );
      return;
    }


DocumentSnapshot<Map<String, dynamic>> electionSnapshot =
    await FirebaseFirestore.instance
        .collection('elections')
        .doc(widget.election['id'] as String)
        .get();

Map<String, dynamic>? voters = electionSnapshot.data()?['voters'] as Map<String, dynamic>?;

if (voters != null) {
  if (voters.containsKey(user.email)) {
    if (voters[user.email]?['status'] != 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your voter account is not approved yet')),
      );
      return;
    }
  }
}

Map<String, dynamic>? applications = electionSnapshot.data()?['applications'] as Map<String, dynamic>?;

if (applications != null) {
  for (var application in applications.values) {
    if (application['email'] == user.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student already applied')),
      );
      return;
    }
  }
}

    if (_formKey.currentState!.validate()) {
      await uploadFilesToFirebase();
      print('Resume Download URL: $resumeDownloadURL');
      print('Transcript Download URL: $transcriptDownloadURL');
      print('Passport Image Download URL: $passportImageDownloadURL');
      print("submitting...");
        String? applicationId = user.email;

        await FirebaseFirestore.instance
            .collection('elections')
            .doc(widget.election['id'] as String)
            .set({
          'applications': {
            applicationId: {
              'email': user.email,
              'why': _whyController.text,
              'plans': _plansController.text,
              'position': widget.position['position'],
              'resume': resumeDownloadURL,
              'transcript': transcriptDownloadURL,
              'passport_image': passportImageDownloadURL,
              'status': 'pending',
              'createdAt': FieldValue.serverTimestamp(),
            }
          }
        }, SetOptions(merge: true));


        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Application submitted", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),),
              content: Text("You will be notified when your application is approved", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),),
                ),
              ],
            );
          }
        );

        Map <String, dynamic> templateParams = {
          'subject': 'Candidate Application',
          'to_email': user.email,
          'message': 'You have successfully applied for the position of ${widget.position['position']} in the ${widget.election['election_name']}',
          'html': 'This is to confirm your application has been sent and will be reviewed shortly. You will be notified when your application is approved.',
        };

        await EmailJS.send(
          'service_idoq2ho',
          'template_3sjuysv',
          templateParams,
          const Options(
            publicKey: '8wGz3AhpezFNPK6Re',
        privateKey: 'IwlgAcY8plvpCv4cBVFR0',
        ),
        );


        _whyController.clear();
        _plansController.clear();
        resumeFile = null;
        transcriptFile = null;
        passportImageFile = null;

        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home())
        );
      }
    } catch (e) {
    print('Error submitting application: $e');
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Error submitting application'), backgroundColor: Colors.redAccent,),
    );
    } finally {
    setState(() {
    _isApplying = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> position = widget.position;
    Map<String, dynamic> election = widget.election;

    String? transcriptName = transcriptFile != null ? transcriptFile!.path.split('/').last : null;
    String? resumeName = resumeFile != null ? resumeFile!.path.split('/').last : null;
    String? passportImageName = passportImageFile != null ? passportImageFile!.path.split('/').last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Apply', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(

        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Apply for ${position['position']}", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                SizedBox(height: 20),
                Text("You are applying for the position of ${position['position']} in the ${election['election_name']}.", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _whyController,
                        maxLines: 5,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "Why are you the best candidate for this position?",
                          hintStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter why you are the best candidate for this position';
                          }
                          return null;
                        },
    ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _plansController,
                        maxLines: 5,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "What are your plans for this position?",
                          hintStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your plans for this position';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text("Upload Documents(max 5mbs)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 25),),
                      SizedBox(height: 10),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Resume(.pdf)", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                                resumeName != null
                                    ? Text(resumeName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blueAccent),)
                                    : SizedBox(),
                              ],
                            ),
                            if (resumeFile != null)
                              Icon(
                                Icons.check_circle,
                                size: 25,
                                color: Colors.green,
                              )
                            else
                              Icon(
                                Icons.attachment,
                                size: 25,
                              ),
                          ],
                        ),
                        onTap: () => selectFile('resume'),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Transcript(.pdf)", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                                transcriptName != null
                                    ? Text(transcriptName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blueAccent),)
                                    : SizedBox(),
                              ],
                            ),
                            if (transcriptFile != null)
                              Icon(
                                Icons.check_circle,
                                size: 25,
                                color: Colors.green,
                              )
                            else
                              Icon(
                                Icons.attachment,
                                size: 25,
                              ),
                          ],
                        ),
                        onTap: () => selectFile('transcript'),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Passport Image(.png, .jpg, .jpeg)", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                                passportImageName != null
                                    ? Text(passportImageName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.blueAccent),)
                                    : SizedBox(),
                              ],
                            ),
                            if (passportImageFile != null)
                              Icon(
                                Icons.check_circle,
                                size: 25,
                                color: Colors.green,
                              )
                            else
                              Icon(
                                Icons.attachment,
                                size: 25,
                              ),
                          ],
                        ),
                        onTap: () => selectFile('passport'),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async{
                              if (_formKey.currentState!.validate() && !_isApplying) {
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(content: Text('Processing Data')),
                                // );

                                submitForm();
                              }
                            },
                            child: _isApplying ? CircularProgressIndicator() : Text('Submit', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApplyVoter extends StatefulWidget {
  const ApplyVoter({super.key, required this.election});

  final Map<String, dynamic> election;

  @override
  State<ApplyVoter> createState() => _ApplyVoterState();
}

class _ApplyVoterState extends State<ApplyVoter> {

  bool _isApplying = false;
  void applyAsVoter() async {
    setState(() {
      _isApplying = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to apply')),
      );
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> electionSnapshot =
      await FirebaseFirestore.instance
          .collection('elections')
          .doc(widget.election['id'] as String)
          .get();

      Map<String, dynamic>? voters = electionSnapshot.data()?['voters'] as Map<String, dynamic>?;

      if (voters == null) {
        voters = {};
      }


      if (voters.containsKey(user.email)) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("You have already applied", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),),
                content: Text("You cannot apply again", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),),
                  ),
                ],
              );
            }
        );
      }


      voters[user.email ?? ''] = {
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('elections')
          .doc(widget.election['id'] as String)
          .update({'voters': voters});

      // await FirebaseFirestore.instance.collection('mail').add({
      //   "to": [user.email],
      //   'subject' : 'Voter Application',
      //   'message': {
      //     'text': 'You have successfully applied to vote in the ${widget.election['election_name']}',
      //     'html': 'This is to confirm your voter application has been sent and will be reviewed shortly. <strong> You will be notified when your application is approved. </strong>',
      //   }
      //
      // });

      Map<String, dynamic> templateParams = {
        'subject': 'Voter Application',
        'to_email': user.email,
        'message': 'You have successfully applied to vote in the ${widget.election['election_name']}',
        'html': 'This is to confirm your voter application has been sent and will be reviewed shortly. You will be notified when your application is approved.',
      };

      await EmailJS.send(
        'service_idoq2ho',
        'template_3sjuysv',
          templateParams,
          const Options(
            publicKey: '8wGz3AhpezFNPK6Re',
            privateKey: 'IwlgAcY8plvpCv4cBVFR0',
          ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Application submitted", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),),
              content: Text("You will be notified when your application is approved", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),),
                ),
              ],
            );
          }
      );


    } catch (e) {
      print('Error submitting application: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting application'), backgroundColor: Colors.redAccent,),
      );
    } finally {
      setState(() {
        _isApplying = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Apply as a voter", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                SizedBox(height: 20),
                Text("You are applying to vote in the ${widget.election['election_name']}.", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (!_isApplying) {
                          applyAsVoter();
                        }
                      },
                      child: _isApplying ? CircularProgressIndicator() : Text('Submit', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

