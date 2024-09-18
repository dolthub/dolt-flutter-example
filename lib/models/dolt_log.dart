class LogModel {
  String hash;
  String committer;
  String email;
  String message;
  String date;

  LogModel({
    required this.hash,
    required this.committer,
    required this.email,
    required this.message,
    required this.date,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      hash: json['commit_hash'],
      committer: json['committer'],
      email: json['email'],
      message: json['message'],
      date: json['date'],
    );
  }
}
