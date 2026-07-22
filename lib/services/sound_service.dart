import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../generated/assets.dart';
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

  void _play(String assetPath) {
    if (!settings.settings.sound) return;
    try {
      final player = AudioPlayer();
      final relativePath = assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath;
      unawaited(player.setReleaseMode(ReleaseMode.release).catchError((_) {}));
      unawaited(player.play(AssetSource(relativePath)).catchError((_) {}));
      player.onPlayerComplete.listen(
        (_) => unawaited(player.dispose().catchError((_) {})),
        onError: (_) {},
      );
    } catch (_) {}
  }

  void good() => _play(Assets.soundsGood);
  void bad() => _play(Assets.soundsBad);
  void tick() => _play(Assets.soundsTick);
  void pairMatched() => _play(Assets.soundsPair);
  void keyTick() => _play(Assets.soundsKeytick);
  void zap() => _play(Assets.soundsZap);
}
