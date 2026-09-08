import 'package:meta/meta.dart';

/// The filter chips on the words screen (`docs/UI-UX.md` section 4.1, F-043).
enum WordFilter {
  /// Everything the user has, minus soft-deleted and archived words.
  ///
  /// Not a stored list: **All** is a filter, which is why `word_lists` has no
  /// seeded "All words" row.
  all,

  /// Starred words only (F-044).
  favourites,

  /// Words whose study card is due now and not suspended.
  dueToday,

  /// Words with neither transcription filled in - the ones still to do.
  noIpa,

  /// Words in one specific list. Requires [WordQuery.listId].
  inList,
}

/// The sort options on the words screen (F-040).
enum WordSort {
  /// Most recently changed first.
  recent,

  /// A-Z on the normalised headword, so case and spacing do not affect order.
  alphabetical,

  /// Weakest first: lowest Leitner box, then most lapses.
  ///
  /// Words with no study card yet sort first, which is right - never practised
  /// is the least known of all.
  leastKnown,
}

/// Everything that shapes the words list: filter, sort, search and paging.
///
/// One object rather than five parameters, so adding a dimension later does not
/// change every signature between the screen and the DAO.
@immutable
final class WordQuery {
  /// Creates a query.
  const new({
    this.filter = WordFilter.all,
    this.sort = WordSort.recent,
    this.searchTerm,
    this.listId,
    this.limit,
  });

  /// Which chip is selected.
  final WordFilter filter;

  /// How the results are ordered.
  ///
  /// Ignored when [searchTerm] is set: search results come back by relevance,
  /// because someone who typed a term wants the best match, not the newest.
  final WordSort sort;

  /// Raw text from the search field. Null or blank means no search.
  final String? searchTerm;

  /// The list to filter by, when [filter] is [WordFilter.inList].
  final String? listId;

  /// Maximum rows to return. Null means all of them.
  final int? limit;

  /// Whether this query actually searches.
  bool get isSearching => searchTerm != null && searchTerm!.trim().isNotEmpty;

  /// A copy with the given fields replaced.
  ///
  /// Passing `clearSearch: true` removes the search term, which a null
  /// `searchTerm` argument cannot express.
  WordQuery copyWith({
    WordFilter? filter,
    WordSort? sort,
    String? searchTerm,
    String? listId,
    int? limit,
    bool clearSearch = false,
  }) {
    return WordQuery(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchTerm: clearSearch ? null : (searchTerm ?? this.searchTerm),
      listId: listId ?? this.listId,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordQuery &&
          other.filter == filter &&
          other.sort == sort &&
          other.searchTerm == searchTerm &&
          other.listId == listId &&
          other.limit == limit);

  @override
  int get hashCode => Object.hash(filter, sort, searchTerm, listId, limit);

  @override
  String toString() =>
      'WordQuery(${filter.name}, ${sort.name}, search: $searchTerm, '
      'list: $listId, limit: $limit)';
}
