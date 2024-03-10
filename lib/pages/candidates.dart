import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Candidates extends StatefulWidget {
  const Candidates({super.key});

  @override
  State<Candidates> createState() => _CandidatesState();
}

class _CandidatesState extends State<Candidates> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Presidency Candidates', style: GoogleFonts.poppins(fontWeight: FontWeight.bold,),),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("About the candidates", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),),
                SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/student.jpeg')
                  ),
                  title: Text("Clinton Njiru", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: RichText(
                    text: TextSpan(
                      text:
                      'Clinton is a senior majoring in computer science. He has been... ',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        TextSpan(
                          text: 'More Details',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Open your popup here
                              // You can use showDialog or any other method to display your popup
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // Your popup content goes here
                                  return AlertDialog(
                                    title: Text("Read More"),
                                    content: Container(
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: AssetImage('assets/images/student.jpeg')
                                            ),
                                            title: Text("Clinton Njiru", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                                            subtitle: Text('Candidate, School Presidency', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                          ),

                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.asset('assets/images/student.jpeg'),
                                          ),
                                          SizedBox(height: 20),

                                          Text("Clinton is a senior majoring in computer science. He has been a member of the gdsc club and serves as its Flutter mentor. \"I'm passionate about bringing the best of our university to the world. Let's make sure we are not great but also known for it.\"", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                        SizedBox(height: 30),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Vote for clinton"),
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
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
