import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class MovieModel extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'id')
  int id;
  @HiveField(1)
  @JsonKey(name: 'adult')
  bool adult;
  @HiveField(2)
  @JsonKey(name: 'backdrop_path')
  String? backdropPath;
  @HiveField(3)
  @JsonKey(name: 'genre_ids')
  List<int> genreIds;
  @HiveField(4)
  @JsonKey(name: 'original_language')
  String? originalLanguage;
  @HiveField(5)
  @JsonKey(name: 'original_title')
  String? originalTitle;
  @HiveField(6)
  String? overview;
  @HiveField(7)
  @JsonKey(name: 'popularity')
  double? popularity;
  @HiveField(8)
  @JsonKey(name: 'poster_path')
  String? posterPath;
  @HiveField(9)
  @JsonKey(name: 'release_date')
  String releaseDate;
  @HiveField(10)
  String title;
  @HiveField(11)
  @JsonKey(name: 'video')
  bool video;
  @HiveField(12)
  @JsonKey(name: 'vote_average')
  double voteAverage;
  @HiveField(13)
  @JsonKey(name: 'vote_count')
  int voteCount;

  MovieModel({
    required this.id,
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : '';

  String get genreString {
    final genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };
    if (genreIds.isEmpty) return 'Unknown';
    return genreMap[genreIds.first] ?? 'Unknown';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          adult == other.adult &&
          title == other.title &&
          overview == other.overview &&
          posterPath == other.posterPath &&
          backdropPath == other.backdropPath &&
          releaseDate == other.releaseDate &&
          video == other.video &&
          voteAverage == other.voteAverage &&
          voteCount == other.voteCount &&
          _listEquals(genreIds, other.genreIds) &&
          originalLanguage == other.originalLanguage &&
          originalTitle == other.originalTitle &&
          popularity == other.popularity;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      adult.hashCode ^
      title.hashCode ^
      (overview?.hashCode ?? 0) ^
      (posterPath?.hashCode ?? 0) ^
      (backdropPath?.hashCode ?? 0) ^
      releaseDate.hashCode ^
      video.hashCode ^
      voteAverage.hashCode ^
      voteCount.hashCode ^
      genreIds.hashCode ^
      (originalLanguage?.hashCode ?? 0) ^
      (originalTitle?.hashCode ?? 0) ^
      (popularity?.hashCode ?? 0);
}

class MovieModelAdapter extends TypeAdapter<MovieModel> {
  @override
  final int typeId = 0;

  @override
  MovieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieModel(
      id: fields[0] as int,
      adult: fields[1] as bool,
      backdropPath: fields[2] as String?,
      genreIds: (fields[3] as List).cast<int>(),
      originalLanguage: fields[4] as String?,
      originalTitle: fields[5] as String?,
      overview: fields[6] as String?,
      popularity: fields[7] as double?,
      posterPath: fields[8] as String?,
      releaseDate: fields[9] as String,
      title: fields[10] as String,
      video: fields[11] as bool,
      voteAverage: fields[12] as double,
      voteCount: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MovieModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.adult)
      ..writeByte(2)
      ..write(obj.backdropPath)
      ..writeByte(3)
      ..write(obj.genreIds)
      ..writeByte(4)
      ..write(obj.originalLanguage)
      ..writeByte(5)
      ..write(obj.originalTitle)
      ..writeByte(6)
      ..write(obj.overview)
      ..writeByte(7)
      ..write(obj.popularity)
      ..writeByte(8)
      ..write(obj.posterPath)
      ..writeByte(9)
      ..write(obj.releaseDate)
      ..writeByte(10)
      ..write(obj.title)
      ..writeByte(11)
      ..write(obj.video)
      ..writeByte(12)
      ..write(obj.voteAverage)
      ..writeByte(13)
      ..write(obj.voteCount);
  }
}
