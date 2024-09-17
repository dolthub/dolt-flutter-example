import 'package:dolt_flutter_example/models/dolt_branch.dart';
import 'package:dolt_flutter_example/models/dolt_log.dart';
import 'package:mysql_client/mysql_client.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static MySQLConnection? _conn;

  DatabaseHelper._internal();

  // Database name and version
  static const String databaseName = 'flutter';

  static const String tableName = 'dolt_branches';

  // Define a getter to access the database asynchronously.
  Future<MySQLConnection> get connection async {
    // If the database instance is already initialized, return it.
    if (_conn != null) {
      return _conn!;
    }

    // If the database instance is not initialized, call the initialization method.
    _conn = await _initConn();

    // Return the initialized database instance.
    return _conn!;
  }

  _initConn() async {
    final conn = await MySQLConnection.createConnection(
      host: "",
      port: 3306,
      userName: "",
      password: "",
      databaseName: "flutter",
    );

    await conn.connect();

    return conn;
  }

  // A method that retrieves all dolt_branches.
  Future<List<BranchModel>> getAllBranches() async {
    final conn = await connection;

    final result =
        await conn.execute('SELECT * FROM $tableName ORDER BY name ASC');

    return result.rows
        .map((json) => BranchModel.fromJson(json.assoc()))
        .toList();
  }

  // A method to delete a branch
  Future<void> deleteBranch(String name) async {
    final conn = await connection;
    try {
      await conn.execute('CALL DOLT_BRANCH("-d", "$name")');
    } catch (err) {
      print("Something went wrong when deleting a branch: $err");
    }
  }

  // A method to create a branch
  Future<void> createBranch(String name, String fromName) async {
    final conn = await connection;
    try {
      await conn.execute('CALL DOLT_BRANCH("$name", "$fromName")');
    } catch (err) {
      print("Something went wrong when creating a branch: $err");
    }
  }

  Future<List<LogModel>> getPullLogs(String fromBranch, String toBranch) async {
    final conn = await connection;
    final result =
        await conn.execute('SELECT * FROM DOLT_LOG("$toBranch..$fromBranch")');
    return result.rows.map((json) => LogModel.fromJson(json.assoc())).toList();
  }

  Future<void> mergeBranches(String fromBranch, String toBranch) async {
    final conn = await connection;
    await conn.execute('CALL DOLT_CHECKOUT("$toBranch")');
    await conn.execute('CALL DOLT_MERGE("$fromBranch")');
  }

  Future close() async {
    final conn = await connection;
    conn.close();
  }
}
