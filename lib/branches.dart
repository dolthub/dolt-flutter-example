import 'package:dolt_flutter_example/pull.dart';
import 'package:dolt_flutter_example/util.dart';
import 'package:flutter/material.dart';
import 'package:dolt_flutter_example/database_helper.dart';
import 'package:dolt_flutter_example/models/dolt_branch.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key, required this.title});

  final String title;

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  // Create an instance of the database helper
  DatabaseHelper db = DatabaseHelper.instance;
  List<BranchModel> branches = [];
  String databaseName = '';

  // State for create branch form
  final formKey = GlobalKey<FormState>();
  TextEditingController newBranchController = TextEditingController();
  TextEditingController fromBranchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      databaseName = db.getDatabaseName();
    });
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

  // Create a new branch in the database
  createBranch() async {
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
        refreshBranches();
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
  String? validateBranch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a branch name.';
    }
    return null;
  }

  // Delete a branch from the database
  deleteBranch(String name) async {
    db.deleteBranch(name).then((respond) async {
      Navigator.pop(context);
      setState(() {});
      handleSuccess(context, "Branch deleted");
      refreshBranches();
    }).catchError((error) {
      handleError(context, error, "delete branch");
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

  // Create a dialog with the new branch form
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
              child: Text(
                'Dolt Branches in $databaseName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
            Icons.account_tree_outlined,
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
                icon: const Icon(Icons.arrow_forward,
                    color: Color.fromARGB(255, 41, 227, 193)),
                tooltip: "See pull request",
              ),
              IconButton(
                onPressed: () => deleteBranchDialog(branch.name),
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 81, 0),
                ),
                tooltip: "Delete branch",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
