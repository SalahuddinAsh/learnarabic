/// One card shown in match/missing modes: a candidate answer plus whether it's correct.
class AnswerCard {
  final String text;
  final bool ok;
  const AnswerCard(this.text, this.ok);
}

/// Two connect-mode word<->picture pairs to drag together.
class ConnectPair {
  final String bare;
  final String vocalized;
  final String emoji;
  const ConnectPair(this.bare, this.vocalized, this.emoji);
}

/// A single generated question. Mirrors the JS `q` object from app.js — most
/// fields are only meaningful for certain mode/level combinations, matching
/// how the original loosely-typed object worked.
class Question {
  final String mode; // match | missing | connect | build | read
  final String level; // letters | words | sent
  final String key; // anti-repeat key
  final String? weakKey; // weak-memory key (null for connect boards, tracked per-pair instead)
  final String insKey; // instruction i18n key

  final String? prompt;
  final String? promptEmoji;
  final bool missingWord;
  final bool emojiCards;
  final bool sent;
  final bool toEmoji; // pic mode: true = word shown, pick the emoji

  final List<AnswerCard>? cards;
  final String answerText;
  final String? reveal;

  final List<String>? tiles; // build mode: letters or sentence words to tap in order
  final List<String>? accepted; // build/order mode: accepted final strings
  final String? targetShow; // vocalized form to display on success
  final String joiner; // "" for word letters, " " for sentence words

  final List<ConnectPair>? pairs; // connect (words) mode

  const Question({
    required this.mode,
    required this.level,
    required this.key,
    this.weakKey,
    required this.insKey,
    this.prompt,
    this.promptEmoji,
    this.missingWord = false,
    this.emojiCards = false,
    this.sent = false,
    this.toEmoji = false,
    this.cards,
    required this.answerText,
    this.reveal,
    this.tiles,
    this.accepted,
    this.targetShow,
    this.joiner = "",
    this.pairs,
  });
}
