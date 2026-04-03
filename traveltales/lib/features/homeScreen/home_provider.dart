import 'package:flutter/material.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/api/destinationAPI.dart';
import 'package:traveltales/core/model/destination_model.dart';
import 'package:traveltales/core/model/genre_model.dart';

class HomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<Destination> _recommended = [];
  List<Destination> _all = [];
  List<Destination> _bestPlacesToVisit = [];
  List<Destination> _quickGetaways = [];
  List<Genre> _genres = [];

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;

  List<Destination> get recommended => _recommended;
  List<Destination> get all => _all;
  List<Destination> get bestPlacesToVisit => _bestPlacesToVisit;
  List<Destination> get quickGetaways => _quickGetaways;
  List<Genre> get genres => _genres;

  Future<void> loadHomeData() async {
    if (_hasLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      _recommended = await getRecommendedDestinations();
      _all = await getAllDestinations();
      _all.shuffle();
      _quickGetaways = _all.where(isQuickGetawayDestination).toList();
      _bestPlacesToVisit = _all
          .where((destination) => !isQuickGetawayDestination(destination))
          .toList();
      _genres = await fetchAllGenres();

      _hasLoaded = true;
    } catch (e) {
      debugPrint("Home load error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommended = await getRecommendedDestinations();
      _all = await getAllDestinations();
      _all.shuffle();
      _quickGetaways = _all.where(isQuickGetawayDestination).toList();
      _bestPlacesToVisit = _all
          .where((destination) => !isQuickGetawayDestination(destination))
          .toList();
    } catch (e) {
      debugPrint("Refresh error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}

bool isQuickGetawayDestination(Destination destination) {
  final duration = destination.extraInfo.duration.trim().toLowerCase();

  if (duration.isEmpty) {
    return false;
  }

  final firstNumber = RegExp(r'\d+').firstMatch(duration)?.group(0);
  final days = firstNumber == null ? null : int.tryParse(firstNumber);

  if (days == null) {
    return false;
  }

  return days <= 2;
}
