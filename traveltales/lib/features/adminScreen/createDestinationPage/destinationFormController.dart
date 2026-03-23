import 'package:flutter/cupertino.dart';

class DestinationFormController {
  final search = TextEditingController();

  final placeName = TextEditingController();
  final location = TextEditingController();
  final genre = TextEditingController();
  final highlights = TextEditingController();
  final description = TextEditingController();

  final bestTimeFrom = TextEditingController();
  final bestTimeTo = TextEditingController();
  final accommodation = TextEditingController();
  final attraction = TextEditingController();
  final safetyTips = TextEditingController();

  final difficulty = TextEditingController();
  final elevation = TextEditingController();
  final transportation = TextEditingController();
  final duration = TextEditingController();

  void clear() {
    placeName.clear();
    location.clear();
    genre.clear();
    highlights.clear();
    description.clear();
    bestTimeFrom.clear();
    bestTimeTo.clear();
    accommodation.clear();
    attraction.clear();
    safetyTips.clear();
    difficulty.clear();
    elevation.clear();
    transportation.clear();
    duration.clear();
  }

  void dispose() {
    search.dispose();
    placeName.dispose();
    location.dispose();
    genre.dispose();
    highlights.dispose();
    description.dispose();
    bestTimeFrom.dispose();
    bestTimeTo.dispose();
    accommodation.dispose();
    attraction.dispose();
    safetyTips.dispose();
    difficulty.dispose();
    elevation.dispose();
    transportation.dispose();
    duration.dispose();
  }
}