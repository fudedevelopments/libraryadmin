class Book {
  final String? id;
  final String title;
  final String author;
  final String? genre;
  final int? publicationYear;
  final String? description;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.genre,
    this.publicationYear,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'],
      publicationYear: json['publication_year'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'title': title, 'author': author};

    if (id != null) data['id'] = id;
    if (genre != null) data['genre'] = genre;
    if (publicationYear != null) data['publication_year'] = publicationYear;
    if (description != null) data['description'] = description;

    return data;
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    int? publicationYear,
    String? description,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      publicationYear: publicationYear ?? this.publicationYear,
      description: description ?? this.description,
    );
  }
}
