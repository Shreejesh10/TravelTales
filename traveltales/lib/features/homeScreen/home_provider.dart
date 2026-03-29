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
  List<Genre> _genres = [];

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;

  List<Destination> get recommended => _recommended;
  List<Destination> get all => _all;
  List<Genre> get genres => _genres;

  Future<void> loadHomeData() async {
    if (_hasLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      _recommended = await getRecommendedDestinations();
      _all = await getAllDestinations();
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
    } catch (e) {
      debugPrint("Refresh error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}