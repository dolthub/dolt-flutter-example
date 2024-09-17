import 'package:dolt_flutter_example/pull.dart';
import 'package:flutter/material.dart';
import 'package:dolt_flutter_example/database_helper.dart';
import 'package:dolt_flutter_example/models/dolt_branch.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create an instance of the database helper
  DatabaseHelper db = DatabaseHelper.instance;
  List<BranchModel> branches = [];

  // State for create branch form
  final formKey = GlobalKey<FormState>();
  TextEditingController newBranchController = TextEditingController();
  TextEditingController fromBranchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    refreshBranches();
    super.initState();
  }

  @override
  dispose() {
    // Close the database when no longer needed
    db.close();
    super.dispose();
  }

  // Fetch and refresh the list of branches from the database
  refreshBranches() {
    db.getAllBranches().then((value) {
      setState(() {
        branches = value;
      });
    });
  }

  // Navigate to the PullView screen and refresh branches afterward
  goToPullView(String fromBranch) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PullView(fromBranch: fromBranch, branches: branches)),
    );
    refreshBranches();
  }

  // Create a new branch
  createBranch() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState?.save();
      db
          .createBranch(newBranchController.text, fromBranchController.text)
          .then((respond) async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Branch successfully added."),
          backgroundColor: Color.fromARGB(255, 4, 160, 74),
        ));
        Navigator.pop(context, {
          'reload': true,
        });
        refreshBranches();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to create branch."),
          backgroundColor: Color.fromARGB(255, 235, 108, 108),
        ));
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
  String? validateBranch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a branch name.';
    }
    return null;
  }

  // Delete a branch
  deleteBranch(String name) async {
    db.deleteBranch(name).then((respond) async {
      Navigator.pop(context);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Branch successfully deleted."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
      refreshBranches();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to delete branch."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  // Create a dialog for deleting a branch
  deleteBranchDialog(String name) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Row(children: [
              Icon(
                Icons.delete_forever,
                color: Color.fromARGB(255, 255, 81, 0),
              ),
              Text('Delete Branch')
            ]),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to delete the "$name" branch?'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red)),
                onPressed: () => deleteBranch(name),
                child: const Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  // Create a dialog for creating a new branch
  createBranchDialog({int? id}) async {
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
                              validator: validateBranch,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: fromBranchController,
                              decoration: const InputDecoration(
                                labelText: 'From Branch Name',
                              ),
                              validator: validateBranch,
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
                onPressed: createBranch,
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Dolt Branches',
            ),
            Container(
              child: branches.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text(
                        "No records to display",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        ...branches.map((branch) {
                          return buildBranchCard(branch);
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
      // Floating action button for creating new branches
      floatingActionButton: FloatingActionButton(
        onPressed: createBranchDialog,
        tooltip: 'Create Branch',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper method to build a branch card
  Widget buildBranchCard(BranchModel branch) {
    return Card(
      child: GestureDetector(
        onTap: () => {},
        child: ListTile(
          leading: const Icon(
            Icons.note,
            color: Color.fromARGB(255, 28, 3, 15),
          ),
          title: Text(branch.name),
          subtitle: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branch.hash),
                Text(branch.latestCommitMessage),
                Text(
                    "Committed at ${branch.latestCommitDate} by ${branch.latestCommitter}"),
              ],
            ),
          ),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () => goToPullView(branch.name),
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Color.fromARGB(255, 41, 227, 193),
                ),
              ),
              IconButton(
                onPressed: () => deleteBranchDialog(branch.name),
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 81, 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
