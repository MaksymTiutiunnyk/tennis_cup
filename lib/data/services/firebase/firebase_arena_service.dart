import 'package:tennis_cup/data/services/abstract/i_arena_service.dart';
import 'package:tennis_cup/data/services/dto/arena_dto.dart';

// Firebase had no separate arenas collection — arenas were a hardcoded list
// in the app. This implementation fulfils IArenaService by returning that
// same static list with synthetic IDs mapped to the legacy title strings.
class FirebaseArenaService implements IArenaService {
  const FirebaseArenaService();

  @override
  Future<List<ArenaDto>> fetchAllArenas() async => const [
        ArenaDto(id: 1, name: 'Australia', color: 'GREEN'),
        ArenaDto(id: 2, name: 'Europe', color: 'BLUE'),
        ArenaDto(id: 3, name: 'Beijing', color: 'GREEN'),
        ArenaDto(id: 4, name: 'America', color: 'RED'),
        ArenaDto(id: 5, name: 'Africa', color: 'BLACK'),
        ArenaDto(id: 6, name: 'Asia', color: 'YELLOW'),
        ArenaDto(id: 7, name: 'Montreal', color: 'GREEN'),
        ArenaDto(id: 8, name: 'New Delhi', color: 'GREEN'),
        ArenaDto(id: 9, name: 'Rio', color: 'BLACK'),
        ArenaDto(id: 10, name: 'Mexico', color: 'RED'),
        ArenaDto(id: 11, name: 'Rome', color: 'RED'),
        ArenaDto(id: 12, name: 'Paris', color: 'BLUE'),
        ArenaDto(id: 13, name: 'Prague', color: 'WHITE'),
        ArenaDto(id: 14, name: 'Seoul', color: 'YELLOW'),
        ArenaDto(id: 15, name: 'Tokyo', color: 'BROWN'),
        ArenaDto(id: 16, name: 'London', color: 'BROWN'),
      ];

  @override
  Future<ArenaDto> fetchArenaById(int id) async {
    final all = await fetchAllArenas();
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => ArenaDto(id: id, name: '', color: ''),
    );
  }
}
