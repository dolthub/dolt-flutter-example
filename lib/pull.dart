import 'package:dolt_flutter_example/models/dolt_log.dart';
import 'package:dolt_flutter_example/util.dart';
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
        // dropdownValue is either main if it exists or first branch in list
        dropdownValue = widget.branches
            .firstWhere((branch) => branch.name == "main",
                orElse: () => widget.branches.first)
            .name;
      });
      _getLogs(dropdownValue);
      super.initState();
    }
  }

  _getLogs(String? toBranch) {
    if (toBranch == null) {
      return;
    }
    db.getPullLogs(widget.fromBranch, toBranch).then((value) {
      setState(() {
        logs = value;
      });
    }).catchError((error) {
      handleError(context, error, "get logs");
    });
  }

  _mergePull() {
    db.mergeBranches(widget.fromBranch, dropdownValue).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pull request merged successfully'),
        ),
      );
      // Route back to home page
      Navigator.pop(context);
    }).catchError((error) {
      handleError(context, error, "merge branches");
    });
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
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Text(
                      'Base branch:',
                    ),
                  ),
                  DropdownMenu<String>(
                    textStyle: const TextStyle(fontSize: 14),
                    initialSelection: dropdownValue,
                    onSelected: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                      _getLogs(value);
                    },
                    dropdownMenuEntries: widget.branches
                        .map<DropdownMenuEntry<String>>((BranchModel value) {
                      return DropdownMenuEntry<String>(
                        value: value.name,
                        label: value.name,
                      );
                    }).toList(),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 40.0, left: 40.0),
                    child: Icon(
                      Icons.arrow_back,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Text(
                      'From branch:',
                    ),
                  ),
                  Text(widget.fromBranch),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 193, 223, 255))),
                onPressed: _mergePull,
                child: const Text('Merge branch'),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                child: logs.isEmpty
                    ? const Text(
                        "No differences found between branches",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pull request logs:",
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(
                            height: 10,
                          ),
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
            Icons.commit,
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
        ),
      ),
    );
  }
}
