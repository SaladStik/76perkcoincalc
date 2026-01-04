import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'coin_calculator.dart';

void main() {
  runApp(const PerkCoinCalculatorApp());
}

class PerkCoinCalculatorApp extends StatelessWidget {
  const PerkCoinCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fallout 76 Perk Coin Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CoinCalculatorScreen(),
    );
  }
}

class CoinCalculatorScreen extends StatefulWidget {
  const CoinCalculatorScreen({super.key});

  @override
  State<CoinCalculatorScreen> createState() => _CoinCalculatorScreenState();
}

class _CoinCalculatorScreenState extends State<CoinCalculatorScreen> {
  final TextEditingController _currentLevelController = TextEditingController();
  final TextEditingController _availableLevelUpsController = TextEditingController();
  final TextEditingController _targetCoinsController = TextEditingController();

  int _availableCoins = 0;
  int _additionalLevelsNeeded = 0;
  int _targetLevel = 0;
  int _maxLevelWithLevelUps = 0;

  @override
  void initState() {
    super.initState();
    _currentLevelController.text = '1';
    _availableLevelUpsController.text = '0';
    _calculate();
  }

  void _calculate() {
    final int currentLevel = int.tryParse(_currentLevelController.text) ?? 0;
    final int availableLevelUps = int.tryParse(_availableLevelUpsController.text) ?? 0;
    final int targetCoins = int.tryParse(_targetCoinsController.text) ?? 0;

    // Coins available from level-ups (considering current level for milestone bonuses)
    final int availableCoins = getAvailableCoins(currentLevel, availableLevelUps);

    // How many MORE levels needed beyond what you have available
    int additionalLevelsNeeded = getAdditionalLevelsNeeded(currentLevel, availableLevelUps, targetCoins);
    int targetLevel = currentLevel + availableLevelUps + additionalLevelsNeeded;

    setState(() {
      _availableCoins = availableCoins;
      _additionalLevelsNeeded = additionalLevelsNeeded;
      _targetLevel = targetLevel;
      _maxLevelWithLevelUps = currentLevel + availableLevelUps;
    });
  }

  @override
  void dispose() {
    _currentLevelController.dispose();
    _availableLevelUpsController.dispose();
    _targetCoinsController.dispose();
    super.dispose();
  }

  Widget _buildInputCard(String title, TextEditingController controller, String hint, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hint,
                prefixIcon: Icon(icon),
              ),
              onChanged: (_) => _calculate(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int targetCoins = int.tryParse(_targetCoinsController.text) ?? 0;
    final bool hasEnoughCoins = _availableCoins >= targetCoins && targetCoins > 0;
    final bool needsMoreLevels = targetCoins > 0 && _additionalLevelsNeeded > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fallout 76 Perk Coin Calculator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Level Input
            _buildInputCard(
              'Your Current Level',
              _currentLevelController,
              'Enter your current level',
              Icons.person,
            ),
            const SizedBox(height: 12),

            // Available Level-Ups Input
            _buildInputCard(
              'Available Level-Ups',
              _availableLevelUpsController,
              'How many level-ups do you have?',
              Icons.arrow_upward,
            ),
            const SizedBox(height: 16),

            // Available Coins Display
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Available Coins',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    Text(
                      '(From ${_availableLevelUpsController.text} level-ups)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 40,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_availableCoins',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider with text
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'NEED MORE COINS?',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),

            // Target Coins Input
            _buildInputCard(
              'How Many Coins Do You Need?',
              _targetCoinsController,
              'Enter target coin amount',
              Icons.monetization_on,
            ),
            const SizedBox(height: 16),

            // Results
            if (_targetCoinsController.text.isNotEmpty) ...[
              Card(
                color: hasEnoughCoins
                    ? Colors.green.shade800
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      if (hasEnoughCoins) ...[
                        const Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You have enough coins!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll have $_availableCoins coins at level $_maxLevelWithLevelUps',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ] else if (needsMoreLevels) ...[
                        Text(
                          'Additional Levels Needed',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 40,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_additionalLevelsNeeded',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You need to reach level $_targetLevel',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                        ),
                        Text(
                          '(Current: ${_currentLevelController.text} + ${_availableLevelUpsController.text} level-ups = $_maxLevelWithLevelUps)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                              ),
                        ),
                        Text(
                          'Need $_additionalLevelsNeeded more levels beyond your available level-ups',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Info section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How Coins Work',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• You earn 2 coins per level\n'
                      '• Bonus: +8 coins every 5 levels\n'
                      '• Formula: (2 × level) + (8 × ⌊level/5⌋)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
