import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Results extends StatefulWidget {


  final List<Map<String,dynamic>> examResultData;

  const Results({super.key, required this.examResultData});

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {

  String? selectedSemester;
  final List<String> semesters = ['Semester-1', 'Semester-2'];

  List<Map<String, dynamic>> fetchedData = [];
  int _currentIndex = 0;

  @override
  void initState() {
    print(widget.examResultData);
    super.initState();
    setState((){
      fetchedData = widget.examResultData;
    });
  }

  void handleSubmit() {
    print("Selected Semester: $selectedSemester");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA784F2),
        title: const Text('Results', style: TextStyle(color: Colors.white)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Semester",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSemester,
              hint: const Text("Select Semester"),
              items: semesters.map((semester) {
                return DropdownMenuItem(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSemester = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("SUBMIT"),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Results",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Subject")),
                      DataColumn(label: Text("Mark")),
                      DataColumn(label: Text("Pass Mark")),
                      DataColumn(label: Text("Mark Scored")),
                      DataColumn(label: Text("Grade")),
                    ],
                    rows: fetchedData.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['subject_id'][1] ?? '')),
                        DataCell(Text(data['mark'].toString())),
                        DataCell(Text(data['pass_mark'].toString())),
                        DataCell(Text(data['mark_scored'].toString())),
                        DataCell(Text(data['grade_id'][1] ?? '')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
  }