// This file is a part of dart_vlc (https://github.com/alexmercerind/dart_vlc)
//
// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#ifndef API_API_H_
#define API_API_H_

#include <cstdint>

#include "api/event_manager.h"
#include "core.h"

#ifdef __cplusplus
extern "C" {
#endif

struct DartDeviceList {
  struct Device {
    const char* name;
    const char* id;
    explicit Device(const char* name, const char* id) : name(name), id(id) {}
  };

  size_t size;
  const Device* device_infos;
};

struct DartEqualizer {
  size_t id;
  float pre_amp;
  const float* bands;
  const float* amps;
  size_t size;
};

DLLEXPORT void PlayerCreate(size_t id, size_t video_width,
                            size_t video_height,
                            size_t command_line_argument_count,
                            const char** command_line_arguments);
DLLEXPORT void PlayerDispose(size_t id);

DLLEXPORT void PlayerOpen(size_t id, bool auto_start, const char** source,
                          size_t source_size);

DLLEXPORT void PlayerPlay(size_t id);

DLLEXPORT void PlayerPause(size_t id);

DLLEXPORT void PlayerPlayOrPause(size_t id);

DLLEXPORT void PlayerStop(size_t id);

DLLEXPORT void PlayerNext(size_t id);

DLLEXPORT void PlayerPrevious(size_t id);

DLLEXPORT void PlayerJumpToIndex(size_t id, size_t index);

DLLEXPORT void PlayerSeek(size_t id, size_t position);

DLLEXPORT void PlayerSetVolume(size_t id, float volume);

DLLEXPORT void PlayerSetRate(size_t id, float rate);

DLLEXPORT void PlayerSetUserAgent(size_t id, const char* user_agent);

DLLEXPORT void PlayerSetDevice(size_t id, const char* device_id,
                               const char* device_name);

DLLEXPORT void PlayerSetEqualizer(size_t id, size_t equalizer_id);

DLLEXPORT void PlayerSetPlaylistMode(size_t id, const char* mode);

DLLEXPORT void PlayerAdd(size_t id, const char* type, const char* resource);

DLLEXPORT void PlayerRemove(size_t id, size_t index);

DLLEXPORT void PlayerInsert(size_t id, size_t index, const char* type,
                            const char* resource);

DLLEXPORT void PlayerMove(size_t id, size_t initial_index,
                          size_t final_index);

DLLEXPORT void PlayerTakeSnapshot(size_t id, const char* file_path,
                                  size_t width, size_t height);

DLLEXPORT void PlayerSetAudioTrack(size_t id, size_t track);

DLLEXPORT size_t PlayerGetAudioTrackCount(size_t id);

DLLEXPORT void PlayerSetHWND(size_t id, int64_t hwnd);

DLLEXPORT const char** MediaParse(Dart_Handle object, const char* type,
                                  const char* resource, size_t timeout);

DLLEXPORT void BroadcastCreate(size_t id, const char* type,
                               const char* resource, const char* access,
                               const char* mux, const char* dst,
                               const char* vcodec, size_t vb,
                               const char* acodec, size_t ab);

DLLEXPORT void BroadcastStart(size_t id);

DLLEXPORT void BroadcastDispose(size_t id);

DLLEXPORT void ChromecastCreate(size_t id, const char* type,
                                const char* resource, const char* ip_address);

DLLEXPORT void ChromecastStart(size_t id);

DLLEXPORT void ChromecastDispose(size_t id);

DLLEXPORT void RecordCreate(size_t id, const char* saving_file,
                            const char* type, const char* resource);

DLLEXPORT void RecordStart(size_t id);

DLLEXPORT void RecordDispose(size_t id);

DLLEXPORT DartDeviceList* DevicesAll(Dart_Handle object);

DLLEXPORT struct DartEqualizer* EqualizerCreateEmpty(Dart_Handle object);

DLLEXPORT struct DartEqualizer* EqualizerCreateMode(Dart_Handle object,
                                                    size_t mode);

DLLEXPORT void EqualizerSetBandAmp(size_t id, float band, float amp);

DLLEXPORT void EqualizerSetPreAmp(size_t id, float amp);

#ifdef __cplusplus
}
#endif
#endif
