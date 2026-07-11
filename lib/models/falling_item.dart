/// One falling picture in the reward game — mirrors the `{c,b,e,el,y}`
/// objects pushed onto `game.items` in app.js.
class FallingItem {
  final String letterChar; // first letter of the word (bare[0])
  final String bare;
  final String emoji;
  final double leftPercent; // 5..70, randomized once at spawn
  double y;
  FallingItem({required this.letterChar, required this.bare, required this.emoji, required this.leftPercent, required this.y});
}
