class Book {
  final int? id;
  final String title;
  final String author;
  final String? coverImage;
  final String vibe;
  final String status;

  Book({this.id, required this.title, required this.author, this.coverImage, required this.vibe, required this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverImage': coverImage,
      'vibe': vibe,
      'status': status,
    };
  }
}