import 'package:dolt_flutter_example/models/dolt_branch.dart';
import 'package:dolt_flutter_example/models/dolt_log.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static MySQLConnection? _conn;

  DatabaseHelper._internal();

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
      host: dotenv.env['DB_HOST'],
      port: int.parse(dotenv.env['DB_PORT']!),
      userName: dotenv.env['DB_USER']!,
      password: dotenv.env['DB_PASS']!,
      databaseName: dotenv.env['DB_NAME']!,
    );

    await conn.connect();

    return conn;
  }

  String getDatabaseName() {
    return dotenv.env['DB_NAME']!;
  }

  Future<List<BranchModel>> getAllBranches() async {
    final conn = await connection;

    final result =
        await conn.execute('SELECT * FROM dolt_branches ORDER BY name ASC');

    return result.rows
        .map((json) => BranchModel.fromJson(json.assoc()))
        .toList();
  }

  Future<void> deleteBranch(String name) async {
    final conn = await connection;
    await conn.execute('CALL DOLT_BRANCH("-d", "$name")');
  }

  Future<void> createBranch(String name, String fromName) async {
    final conn = await connection;
    await conn.execute('CALL DOLT_BRANCH("$name", "$fromName")');
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
