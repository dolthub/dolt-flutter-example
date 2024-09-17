class BranchModel {
  String name;
  String hash;
  String latestCommitter;
  String latestCommitterEmail;
  String latestCommitMessage;
  String latestCommitDate;

  BranchModel({
    required this.name,
    required this.hash,
    required this.latestCommitter,
    required this.latestCommitterEmail,
    required this.latestCommitMessage,
    required this.latestCommitDate,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      name: json['name'],
      hash: json['hash'],
      latestCommitter: json['latest_committer'],
      latestCommitterEmail: json['latest_committer_email'],
      latestCommitMessage: json['latest_commit_message'],
      latestCommitDate: json['latest_commit_date'],
    );
  }
}
