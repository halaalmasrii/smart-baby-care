import 'package:flutter/material.dart';
import '../widgets/recommendation_card.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          RecommendationCard(
            tipTitle: 'Feeding Tip',
            tipText: 'Always burp your baby after feeding to reduce discomfort.',
            icon: Icons.local_dining,
            color: Colors.orange,
          ),
          SizedBox(height: 16),
          RecommendationCard(
            tipTitle: 'Sleep Tip',
            tipText: 'Keep a calm and quiet environment to help your baby sleep better.',
            icon: Icons.bedtime,
            color: Colors.indigo,
          ),
          SizedBox(height: 16),
          RecommendationCard(
            tipTitle: 'Playtime Tip',
            tipText: 'Engage your baby with colorful toys and gentle sounds.',
            icon: Icons.toys,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }
}
