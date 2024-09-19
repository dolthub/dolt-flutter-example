import 'package:dolt_flutter_example/util.dart';
import 'package:flutter/material.dart';
import 'package:dolt_flutter_example/database_helper.dart';
import 'package:dolt_flutter_example/models/dolt_branch.dart';
import 'package:dolt_flutter_example/pull.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create an instance of the database helper
  DatabaseHelper db = DatabaseHelper.instance;
  int _counter = 0;
  final int _buttonId = 1;
  List<BranchModel> branches = [];
  String _currentBranch = "";

  // State for create branch form
  final formKey = GlobalKey<FormState>();
  TextEditingController newBranchController = TextEditingController();
  TextEditingController fromBranchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    _refreshBranches(null);
    super.initState();
  }

  @override
  dispose() {
    // Close the database when no longer needed
    db.close();
    super.dispose();
  }

  _refreshBranches(String? firstBranch) {
    db.getAllBranches().then((branchesRes) {
      if (branchesRes.isNotEmpty) {
        // targetBranch is either firstBranch, main if it exists, or first branch in list
        final targetBranch = branchesRes
            .firstWhere((b) => b.name == (firstBranch ?? "main"),
                orElse: () => branchesRes.first)
            .name;
        setState(() {
          branches = branchesRes;
          _currentBranch = targetBranch;
        });
        _refreshCount(targetBranch);
      }
    }).catchError((error) {
      handleError(context, error, 'fetch counter');
    });
  }

  // Fetch and refresh the count from the database
  _refreshCount(String branch) {
    db.getCounter(_buttonId, branch).then((value) {
      setState(() {
        _counter = value;
      });
    }).catchError((error) {
      handleError(context, error, 'fetch counter');
    });
  }

  void _incrementCounter() {
    db.updateCounter(_buttonId, _currentBranch).then((value) {
      _refreshCount(_currentBranch);
    }).catchError((error) {
      handleError(context, error, 'increment counter');
    });
  }

  // Navigate to the PullView screen and refresh branches afterward
  _goToPullView(String fromBranch) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PullView(fromBranch: fromBranch, branches: branches)),
    );
    _refreshBranches(fromBranch);
  }

  // Create a new branch in the database
  _createBranch() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState?.save();
      db
          .createBranch(newBranchController.text, fromBranchController.text)
          .then((respond) async {
        handleSuccess(context, "Branch added");
        Navigator.pop(context, {
          'reload': true,
        });
        _refreshBranches(newBranchController.text);
      }).catchError((error) {
        handleError(context, error, "create branch");
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in all fields."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    }

    setState(() {
      isLoading = false;
    });
  }

  // Validate the title field
  String? _validateBranch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a branch name.';
    }
    return null;
  }

  // Create a dialog with the new branch form
  _createBranchDialog({int? id}) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create a new branch'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Text('Creates a new branch from an existing branch.'),
                  Form(
                      key: formKey,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: newBranchController,
                              decoration: const InputDecoration(
                                labelText: 'New Branch Name',
                              ),
                              validator: _validateBranch,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: fromBranchController,
                              decoration: const InputDecoration(
                                labelText: 'From Branch Name',
                              ),
                              validator: _validateBranch,
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 193, 223, 255))),
                onPressed: _createBranch,
                child: const Text('Create Branch'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    right: 40.0, left: 40.0, bottom: 30.0),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Text(
                        'Branch:',
                      ),
                    ),
                    DropdownMenu<String>(
                      textStyle: const TextStyle(fontSize: 14),
                      width: 250,
                      initialSelection: _currentBranch,
                      onSelected: (String? value) {
                        setState(() {
                          _currentBranch = value!;
                        });
                        _refreshCount(value!);
                      },
                      dropdownMenuEntries: branches
                          .map<DropdownMenuEntry<String>>((BranchModel value) {
                        return DropdownMenuEntry<String>(
                          value: value.name,
                          label: value.name,
                        );
                      }).toList(),
                    ),
                    IconButton(
                      onPressed: _createBranchDialog,
                      icon: const Icon(Icons.add),
                      tooltip: "Create new branch",
                      iconSize: 30,
                    ),
                    IconButton(
                      onPressed: () => _goToPullView(_currentBranch),
                      icon: const Icon(Icons.arrow_forward,
                          color: Color.fromARGB(255, 41, 227, 193)),
                      tooltip: "View pull request",
                      iconSize: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'You have pushed the button this many times:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
