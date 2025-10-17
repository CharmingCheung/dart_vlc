/// Represents a media track (audio, video, or subtitle).
class MediaTrack {
  /// Track ID (used to select the track).
  final int id;

  /// Track name/description (e.g., "English", "French", "Track 1").
  final String name;

  /// Track type.
  final MediaTrackType type;

  const MediaTrack({
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  String toString() => 'MediaTrack(id: $id, name: $name, type: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaTrack &&
        other.id == id &&
        other.name == name &&
        other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ type.hashCode;
}

/// Type of media track.
enum MediaTrackType {
  /// Audio track.
  audio,

  /// Video track.
  video,

  /// Subtitle track (SPU - Sub Picture Unit).
  subtitle,
}

extension MediaTrackTypeExtension on MediaTrackType {
  String get name {
    switch (this) {
      case MediaTrackType.audio:
        return 'audio';
      case MediaTrackType.video:
        return 'video';
      case MediaTrackType.subtitle:
        return 'subtitle';
    }
  }

  static MediaTrackType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'audio':
        return MediaTrackType.audio;
      case 'video':
        return MediaTrackType.video;
      case 'subtitle':
      case 'spu':
        return MediaTrackType.subtitle;
      default:
        throw ArgumentError('Unknown MediaTrackType: $value');
    }
  }
}
