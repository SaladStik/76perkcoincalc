/// Calculates the total coins earned at a given level
int coinsAtLevel(int level) {
  return (2 * level) + (8 * (level ~/ 5));
}

/// Calculates coins earned from leveling up from startLevel to endLevel
/// Bonus coins are only awarded when crossing actual multiples of 5 (5, 10, 15, etc.)
int coinsFromLevelRange(int startLevel, int endLevel) {
  if (endLevel <= startLevel) return 0;
  
  // Base coins: 2 per level gained
  int levelsGained = endLevel - startLevel;
  int baseCoins = 2 * levelsGained;
  
  // Bonus coins: 8 for each multiple of 5 crossed
  // Count how many multiples of 5 are between startLevel (exclusive) and endLevel (inclusive)
  int fivesAtStart = startLevel ~/ 5;
  int fivesAtEnd = endLevel ~/ 5;
  int bonusCount = fivesAtEnd - fivesAtStart;
  int bonusCoins = 8 * bonusCount;
  
  return baseCoins + bonusCoins;
}

/// Calculates how many additional levels are needed from currentLevel to earn targetCoins
int getAdditionalLevelsNeeded(int currentLevel, int availableLevelUps, int targetCoins) {
  // First check coins from available level-ups
  int availableCoins = coinsFromLevelRange(currentLevel, currentLevel + availableLevelUps);
  
  if (availableCoins >= targetCoins) {
    return 0;
  }

  int level = currentLevel + availableLevelUps;

  while (coinsFromLevelRange(currentLevel, level) < targetCoins) {
    level++;
  }

  return level - currentLevel - availableLevelUps;
}

/// Calculates coins available from level-ups starting at currentLevel
int getAvailableCoins(int currentLevel, int availableLevelUps) {
  return coinsFromLevelRange(currentLevel, currentLevel + availableLevelUps);
}
