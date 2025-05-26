// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/epic_games_service.dart';

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final start = _formatDate(game.startDate, dateFormat);
    final end = _formatDate(game.endDate, dateFormat);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            game.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 60,
                height: 60,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 60,
                height: 60,
                child: Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        ),
        title: Text(
          game.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Free from $start to $end'),
        trailing: TextButton(
          child: const Text('View'),
          onPressed: () => _launchUrl(context, game.url),
        ),
      ),
    );
  }

  String _formatDate(String dateStr, DateFormat formatter) {
    try {
      return formatter.format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr.split('T')[0];
    }
  }

  void _launchUrl(BuildContext context, String url) async {
    // ignore: avoid_print
    print('Trying to open: $url');
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }
}
