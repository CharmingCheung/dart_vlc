import 'package:dart_vlc_ffi/src/media_source/media.dart';

/// State of a [Player] instance.
class CurrentState {
  /// Index of currently playing [Media].
  int? index;

  /// Currently playing [Media].
  Media? media;

  /// [List] of [Media] currently opened in the [Player] instance.
  List<Media> medias = <Media>[];

  /// Whether a [Playlist] is opened or a [Media].
  bool isPlaylist = false;
}

/// Position & duration state of a [Player] instance.
class PositionState {
  /// Position of playback in [Duration] of currently playing [Media].
  Duration? position = Duration.zero;

  /// Length of currently playing [Media] in [Duration].
  Duration? duration = Duration.zero;
}

/// Playback state of a [Player] instance.
class PlaybackState {
  /// Whether [Player] instance is playing or not.
  bool isPlaying = false;

  /// Whether [Player] instance is seekable or not.
  bool isSeekable = true;

  /// Whether the current [Media] has ended playing or not.
  bool isCompleted = false;
}

/// Volume & Rate state of a [Player] instance.
class GeneralState {
  /// Volume of [Player] instance.
  double volume = 1.0;

  /// Rate of playback of [Player] instance.
  double rate = 1.0;
}

/// Subtitle state of a [Player] instance.
class SubtitleState {
  /// Whether the current subtitle should be visible.
  bool isShowing = false;

  /// Subtitle payload rendered for the current frame.
  String text = '';

  /// Start time in playback timeline.
  Duration? start = Duration.zero;

  /// Stop time in playback timeline.
  Duration? stop = Duration.zero;

  /// Timestamp at which the event was emitted.
  Duration? timestamp = Duration.zero;
}
