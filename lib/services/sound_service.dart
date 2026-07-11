import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'settings_controller.dart';

/// Plays the short pre-rendered tone assets that replace app.js's WebAudio
/// oscillator beeps (soundGood/soundBad/soundTick plus the ad-hoc beep()
/// calls for connect-pair matches, game key presses, and game zaps). Each
/// call spins up a fresh low-latency player so overlapping sounds (e.g. a
/// timer tick during a feedback beep) don't cut each other off, matching
/// the original's independent-oscillator-per-beep behavior.
class SoundService {
  final SettingsController settings;
  SoundService(this.settings);

  void _play(String asset) {
    if (!settings.settings.sound) return;
    final player = AudioPlayer();
    unawaited(player.setReleaseMode(ReleaseMode.release));
    unawaited(player.play(AssetSource("sounds/$asset")).catchError((_) {}));
    player.onPlayerComplete.listen((_) => player.dispose());
  }

  void good() => _play("good.wav");
  void bad() => _play("bad.wav");
  void tick() => _play("tick.wav");
  void pairMatched() => _play("pair.wav");
  void keyTick() => _play("keytick.wav");
  void zap() => _play("zap.wav");
}
