import 'package:dolt_flutter_example/models/dolt_log.dart';
import 'package:flutter/material.dart';
import 'package:dolt_flutter_example/database_helper.dart';
import 'package:dolt_flutter_example/models/dolt_branch.dart';

class PullView extends StatefulWidget {
  const PullView({super.key, required this.fromBranch, required this.branches});

  final List<BranchModel> branches;
  final String fromBranch;

  @override
  State<PullView> createState() => _PullViewState();
}

class _PullViewState extends State<PullView> {
  // Create an instance of the database helper
  DatabaseHelper db = DatabaseHelper.instance;
  String dropdownValue = "";
  List<LogModel> logs = [];

  @override
  void initState() {
    if (widget.branches.isNotEmpty) {
      setState(() {
        dropdownValue = widget.branches.first.name;
      });
      getLogs(widget.branches.first.name);
      super.initState();
    }
  }

  getLogs(String? toBranch) {
    if (toBranch == null) {
      return;
    }
    db.getPullLogs(widget.fromBranch, toBranch).then((value) {
      setState(() {
        logs = value;
      });
    });
  }

  mergePull() {
    db.mergeBranches(widget.fromBranch, dropdownValue).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pull request merged successfully'),
        ),
      );
    });
    // Route back to home page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Dolt Pull Request Page"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Choose branches to view the pull request',
              ),
              Text(
                'From branch: ${widget.fromBranch}',
              ),
              const Text(
                'To branch:',
              ),
              DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
                  });
                  getLogs(value);
                },
                items: widget.branches
                    .map<DropdownMenuItem<String>>((BranchModel value) {
                  return DropdownMenuItem<String>(
                    value: value.name,
                    child: Text(value.name),
                  );
                }).toList(),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 193, 223, 255))),
                onPressed: mergePull,
                child: const Text('Merge branch'),
              ),
              Container(
                child: logs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Text(
                          "No logs found",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          const Text("Logs:"),
                          ...logs.map((log) {
                            return buildLogCard(log);
                          }),
                        ],
                      ),
              ),
            ],
          ),
        ));
  }

  // Helper method to build a log card
  Widget buildLogCard(LogModel log) {
    return Card(
      child: GestureDetector(
        onTap: () => {},
        child: ListTile(
          leading: const Icon(
            Icons.note,
            color: Color.fromARGB(255, 28, 3, 15),
          ),
          title: Text(log.hash),
          subtitle: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.message),
                Text("Committed at ${log.date} by ${log.committer}"),
              ],
            ),
          ),
          // trailing: Wrap(
          //   children: [
          //     IconButton(
          //       onPressed: () => goToPullView(branch.name),
          //       icon: const Icon(
          //         Icons.arrow_forward,
          //         color: Color.fromARGB(255, 41, 227, 193),
          //       ),
          //     ),
          //     IconButton(
          //       onPressed: () => deleteBranchDialog(branch.name),
          //       icon: const Icon(
          //         Icons.delete,
          //         color: Color.fromARGB(255, 255, 81, 0),
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
