import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'movie_model.dart';

part 'movie_response_model.g.dart';

@JsonSerializable()
class MovieResponseModel extends Equatable {
  final int page;
  @JsonKey(name: 'results')
  final List<MovieModel> results;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'total_results')
  final int totalResults;

  const MovieResponseModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory MovieResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovieResponseModelToJson(this);

  @override
  List<Object?> get props => [page, results, totalPages, totalResults];
}
