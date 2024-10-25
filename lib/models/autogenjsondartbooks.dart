class BookFromApi {
  String title;
  String subtitle;
  List<Authors> authors;
  String publishDate;
  List<String> publishers;
  List<int> covers;
  String physicalFormat;
  List<String> isbn13;
  String pagination;
  List<String> sourceRecords;
  List<String> isbn10;
  String copyrightDate;
  Authors type;
  String key;
  int numberOfPages;
  int latestRevision;
  int revision;
  Created created;
  Created lastModified;

  BookFromApi(
      {this.title,
        this.subtitle,
        this.authors,
        this.publishDate,
        this.publishers,
        this.covers,
        this.physicalFormat,
        this.isbn13,
        this.pagination,
        this.sourceRecords,
        //this.languages,
        this.isbn10,
        this.copyrightDate,
        this.type,
        this.key,
        this.numberOfPages,
        //this.works,
        this.latestRevision,
        this.revision,
        this.created,
        this.lastModified});

  BookFromApi.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    subtitle = json['subtitle'];
    if (json['authors'] != null) {
      authors = new List<Authors>();
      json['authors'].forEach((v) {
        authors.add(new Authors.fromJson(v));
      });
    }
    publishDate = json['publish_date'];
    publishers = json['publishers'].cast<String>();
    covers = json['covers'].cast<int>();
    physicalFormat = json['physical_format'];
    isbn13 = json['isbn_13'].cast<String>();
    pagination = json['pagination'];
    sourceRecords = json['source_records'].cast<String>();
    isbn10 = json['isbn_10'].cast<String>();
    copyrightDate = json['copyright_date'];
    type = json['type'] != null ? new Authors.fromJson(json['type']) : null;
    key = json['key'];
    numberOfPages = json['number_of_pages'];
    latestRevision = json['latest_revision'];
    revision = json['revision'];
    created =
    json['created'] != null ? new Created.fromJson(json['created']) : null;
    lastModified = json['last_modified'] != null
        ? new Created.fromJson(json['last_modified'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['subtitle'] = this.subtitle;
    if (this.authors != null) {
      data['authors'] = this.authors.map((v) => v.toJson()).toList();
    }
    data['publish_date'] = this.publishDate;
    data['publishers'] = this.publishers;
    data['covers'] = this.covers;
    data['physical_format'] = this.physicalFormat;
    data['isbn_13'] = this.isbn13;
    data['pagination'] = this.pagination;
    data['source_records'] = this.sourceRecords;
    data['isbn_10'] = this.isbn10;
    data['copyright_date'] = this.copyrightDate;
    if (this.type != null) {
      data['type'] = this.type.toJson();
    }
    data['key'] = this.key;
    data['number_of_pages'] = this.numberOfPages;
    // if (this.works != null) {
    //   data['works'] = this.works.map((v) => v.toJson()).toList();
    // }
    data['latest_revision'] = this.latestRevision;
    data['revision'] = this.revision;
    if (this.created != null) {
      data['created'] = this.created.toJson();
    }
    if (this.lastModified != null) {
      data['last_modified'] = this.lastModified.toJson();
    }
    return data;
  }
}

class Authors {
  String key;

  Authors({this.key});

  Authors.fromJson(Map<String, dynamic> json) {
    key = json['key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    return data;
  }
}

class Created {
  String type;
  String value;

  Created({this.type, this.value});

  Created.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}