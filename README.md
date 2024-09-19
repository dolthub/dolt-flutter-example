# dolt_flutter_example

An example Flutter counter application that connects to a [Dolt](https://www.doltdb.com) database.
Includes branch and pull request workflows.

Learn more about this application in [this blog](https://www.dolthub.com/blog/2024-09-20-flutter-and-dolt).

<img width="1476" alt="Screenshot 2024-09-19 at 3 51 17 PM" src="https://github.com/user-attachments/assets/327cde26-a28c-4a59-9bea-6f2b32cdd11b">

## Getting Started

This project is a starting point for a Flutter - Dolt application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Connecting to Dolt

In order to connect to a Dolt database, you must add your database connectivity
information. This is done using a [`.env` file](https://pub.dev/packages/flutter_dotenv).

First create a new `.env` file in the root of this application. It must have the following
fields:

```shell
DB_HOST="my.host.name"
DB_PORT=3306
DB_USER="root"
DB_PASS="xxxxxxxxxxxxxxxxxx"
DB_NAME="mydb"
```

Then when you run this application, you should see the counter and branches from
your Dolt database populated on the home screen.
