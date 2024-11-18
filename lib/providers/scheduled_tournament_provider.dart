import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennis_cup/model/arena.dart';
import 'package:tennis_cup/model/tournament.dart';
import 'package:tennis_cup/providers/arena_filter_provider.dart';
import 'package:tennis_cup/providers/schedule_date_provider.dart';
import 'package:tennis_cup/providers/time_filter_provider.dart';

final scheduledTournamentProvider = FutureProvider<List<Tournament>>((ref) async {
  final DateTime tournamentDate = ref.watch(scheduleDateProvider);
  final Arena tournamentArena = ref.watch(arenaFilterProvider);
  final Time tournamentTime = ref.watch(timeFilterProvider);

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Define the start and end of the selected day
  final Timestamp startOfDay = Timestamp.fromDate(DateTime(
    tournamentDate.year,
    tournamentDate.month,
    tournamentDate.day,
    0, 0, 0,
  ));
  final Timestamp endOfDay = Timestamp.fromDate(DateTime(
    tournamentDate.year,
    tournamentDate.month,
    tournamentDate.day,
    23, 59, 59,
  ));

  // Fetch tournaments within the selected date range and other filters
  final querySnapshot = await firestore
      .collection('tournaments')
      .where('date', isGreaterThanOrEqualTo: startOfDay)
      .where('date', isLessThanOrEqualTo: endOfDay)
      .where('time', isEqualTo: tournamentTime.name) 
      .where('arena', isEqualTo: tournamentArena.title) 
      .get();

  // Map Firestore documents to a list of Tournament objects
  List<Tournament> filteredTournaments = await Future.wait(
    querySnapshot.docs.map((doc) async => Tournament.fromFirestore(doc))
  );

  return filteredTournaments;
});
