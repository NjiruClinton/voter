import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home.dart';

class ApplyCandidate extends StatefulWidget {
  const ApplyCandidate({super.key});

  @override
  State<ApplyCandidate> createState() => _ApplyCandidateState();
}

class _ApplyCandidateState extends State<ApplyCandidate> {
  // one election data
  //{election_end_date: 03/08/2024, election_name: Students General Election, positions: [{about: The school president, position: School Presidency}, {about: The school secretary general, position: Secretary General}, {about: The vice president, position: Vice President}], election_description: When you cast your vote for president, you tell your state’s electors to cast their votes for the candidate you chose. In Pennsylvania, each candidate for president chooses a list of electors., election_start_date: 03/04/2024}

  // List<Map<String, dynamic>> elections = []; // supposed to be an object of election data
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
          elections.add(doc.data());
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
                      child: ElectionItem(
                        name: election['election_name'],
                        description: election['election_description'],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChoosePosition(election: election,)),
                        );
                      },
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
  // textControllers
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _studentIdController = TextEditingController();
  TextEditingController _whyController = TextEditingController();
  TextEditingController _plansController = TextEditingController();

  File? resumeFile;
  File? transcriptFile;
  File? passportImageFile;

  String? resumeDownloadURL;
  String? transcriptDownloadURL;
  String? passportImageDownloadURL;

  Future<void> selectFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      switch (type) {
        case 'resume':
          resumeFile = file;
          break;
        case 'transcript':
          transcriptFile = file;
          break;
        case 'passport':
          passportImageFile = file;
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
      print("resume file is null");
      return;
    }

    if (transcriptFile != null) {
      String transcriptFilePath = 'transcripts/${DateTime.now().millisecondsSinceEpoch}.${transcriptFile!.path.split('.').last}';
      Reference transcriptRef = storage.ref().child(transcriptFilePath);
      UploadTask transcriptUploadTask = transcriptRef.putFile(transcriptFile!);
      await transcriptUploadTask.whenComplete(() => null);
      transcriptDownloadURL = await transcriptRef.getDownloadURL();
    } else{
      print("transcript file is null");
      return;
    }

    if (passportImageFile != null) {
      String passportImageFilePath = 'passports/${DateTime.now().millisecondsSinceEpoch}.${passportImageFile!.path.split('.').last}';
      Reference passportImageRef = storage.ref().child(passportImageFilePath);
      UploadTask passportImageUploadTask = passportImageRef.putFile(passportImageFile!);
      await passportImageUploadTask.whenComplete(() => null);
      passportImageDownloadURL = await passportImageRef.getDownloadURL();
    } else{
      print("passport image file is null");
      return;
    }
  }


  void submitForm() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('applications')
        .where('student_id', isEqualTo: _studentIdController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student already applied')),
      );
      return;
    };

    if (_formKey.currentState!.validate()) {
      await uploadFilesToFirebase();
      print("submitting...");
      try{
      await FirebaseFirestore.instance.collection('applications').add({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'student_id': _studentIdController.text,
        'why': _whyController.text,
        'plans': _plansController.text,
        'position': widget.position['position'],
        'election': widget.election['election_name'],
        'election_end_date': widget.election['election_end_date'],
        'election_start_date': widget.election['election_start_date'],
        'resume': resumeDownloadURL,
        'transcript': transcriptDownloadURL,
        'passport_image': passportImageDownloadURL,
        'status': 'pending',
        'createdAt': DateTime.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted')),
      );
      _firstNameController.clear();
      _lastNameController.clear();
      _studentIdController.clear();
      _whyController.clear();
      _plansController.clear();
      resumeFile = null;
      transcriptFile = null;
      passportImageFile = null;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home())
      );
      } catch (e) {
        print('Error submitting application: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting application')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> position = widget.position;
    Map<String, dynamic> election = widget.election;
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
                        controller: _firstNameController,
                        maxLines: 1,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "First name",
                          hintStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _lastNameController,
                        maxLines: 1,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "Last name",
                          hintStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _studentIdController,
                        maxLines: 1,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "Student ID",
                          hintStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your student ID';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
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
                      Text("Upload Documents", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 25),),
                      SizedBox(height: 10),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Resume", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                            Icon(Icons.attachment, size: 25,),
                          ],
                        ),
                        onTap: () => selectFile('resume'),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Transcript", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                            Icon(Icons.attachment, size: 25,),
                          ],
                        ),
                        onTap: () => selectFile('transcript'),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Passport Image", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),),
                            Icon(Icons.attachment, size: 25,),
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
                              primary: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Processing Data')),
                                );
                              }
                              submitForm();

                              print('Resume Download URL: $resumeDownloadURL');
                              print('Transcript Download URL: $transcriptDownloadURL');
                              print('Passport Image Download URL: $passportImageDownloadURL');
                            },
                            child: Text('Submit', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
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
