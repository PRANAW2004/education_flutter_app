import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class ExamScreen extends StatefulWidget {

  final List<dynamic> examTimetableData;

  const ExamScreen({super.key, required this.examTimetableData});

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final client = OdooClient("http://educationv17.odoo.com");
  int itemCount = 0; 
  List<dynamic> exams = [];
  List<dynamic> filteredExams = []; 

 
  String selectedSubject = 'All';
  String selectedExamType = 'All';

  
  final List<Color> cardColors = [
    const Color(0xFFFFCCCC), 
    const Color(0xFFFFE0B2),  
    const Color(0xFFCCFFCC), 
    const Color(0xFFE0CCFF),  
    const Color(0xFFCCE5FF),  
    const Color(0xFFFFFFCC),  
    const Color(0xFFE6CCFF), 
    const Color(0xFFCCFFE6),
  ];

  int _selectedIndex = 0; 
  @override
  void initState() {
    super.initState();
    exams = widget.examTimetableData;
    applyFilters();
    // fetchData();
  }

  // Future<void> fetchData() async {
  //   try {
  //     // Authenticate with Odoo
  //     await client.authenticate(
  //       "neha-klientinformatics-education1-main-16365936",
  //       'admin',
  //       'a',
  //     );
  //     int studentId = 22;

  //     // Fetch data
      

      
  //     setState(() {
  //       // exams = res;
  //       applyFilters(); 
  //     });
  //   } on OdooException catch (e) {
  //     print("Error: $e");
  //   } finally {
  //     client.close();
  //   }
  // }
  
  
  void applyFilters() {
    setState(() {
      filteredExams = exams.where((exam) {
        
        final subjectMatch = selectedSubject == 'All' || exam['subject_id'][1] == selectedSubject;
        
        final examTypeMatch = selectedExamType == 'All' || exam['exam_id'][1].contains(selectedExamType);
        return subjectMatch && examTypeMatch;
      }).toList();
      itemCount = filteredExams.length;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFA784F2),
          title: const Text(
            "Exam Schedule",
            style: TextStyle(color: Colors.white), 
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); 
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Subject Dropdown
                  Expanded(
                    child: Row(
                      children: [
                        const Text("Subject: "),
                        DropdownButton<String>(
                          value: selectedSubject,
                          items: <String>[
                            'All', 'TELUGU', 'HINDU', 'ENGLISH', 'MATHEMATICS', 'SCIENCE', 'SOCIAL'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSubject = newValue!;
                              applyFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  Row(
                    children: [
                      const Text("Sort by: "),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.sort),
                        onSelected: (String newValue) {
                          setState(() {
                            selectedExamType = newValue;
                            applyFilters();
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return <String>['All', 'Formative Assiment - I', 'Formattive Assisement -II', 'Formative Assesment III']
                              .map((String value) {
                            return PopupMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: itemCount, // Number of cards based on filtered itemCount
                  itemBuilder: (context, index) {
                    // Extract data for each filtered exam
                    var examData = filteredExams[index];
                    var subjectName = examData['subject_id'][1]; // Subject name
                    var examDate = examData['date']; // Exam date
                    var examDay = examData['day']; // Exam day
                    var fromTime = examData['time_from']; // Exam start time
                    var toTime = examData['time_to']; // Exam end time
                    var examName = examData['exam_id'][1]; // Exam name

                    // Convert time to a readable format
                    String fromTimeFormatted = "${fromTime.toInt()}:${((fromTime % 1) * 60).toInt()}";
                    String toTimeFormatted = "${toTime.toInt()}:${((toTime % 1) * 60).toInt()}";

                    // Get color for the current card
                    Color cardColor = cardColors[index % cardColors.length];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left Column: Subject Name and Exam Name
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$subjectName",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$examName",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Right Column: Date, Day, and Timings
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Date: $examDate",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Day: $examDay",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$fromTimeFormatted - $toTimeFormatted",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
      );
    
  }
}