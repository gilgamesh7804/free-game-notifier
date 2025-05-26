import 'dart:convert';
import 'package:http/http.dart' as http;

class Game {
  final String id;
  final String title;
  final String image;
  final String url;
  final String startDate;
  final String endDate;

  Game({
    required this.id,
    required this.title,
    required this.image,
    required this.url,
    required this.startDate,
    required this.endDate,
  });
}

Future<List<Game>> fetchEpicFreeGames() async {
  final url = Uri.parse('https://store-site-backend-static-ipv4.ak.epicgames.com/freeGamesPromotions?locale=en-US&country=US&allowCountries=US');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to load games');
  }

  final jsonData = json.decode(response.body);
  final List<Game> games = [];

  final elements = jsonData['data']?['Catalog']?['searchStore']?['elements'];
  if (elements != null) {
    for (var game in elements) {
      final promotions = game['promotions'];
      final offers = promotions?['promotionalOffers'];
      if (offers != null && offers.isNotEmpty) {
        final offer = offers[0]['promotionalOffers'][0];
        games.add(Game(
          id: game['id'],
          title: game['title'],
          image: game['keyImages'][0]['url'] ?? '',
          url: 'https://www.epicgames.com/store/en-US/p/${game['productSlug'] ?? game['urlSlug']}',
          startDate: offer['startDate'],
          endDate: offer['endDate'],
        ));
      }
    }
  }

  return games;
}
