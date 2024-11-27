echo "Extract audio from video"
ffmpeg -y -i music_video.mp4 -vn -c:a flac whole_audio.flac

echo "Slice an audio"
ffmpeg -y -ss 00:00:11 -to 00:00:16 -i whole_audio.flac -c copy audio_section.flac

echo "Lossy MP3 compression"
ffmpeg -y -i audio_section.flac -c:a libmp3lame audio_section.mp3

echo "Subsampling at 24k"
ffmpeg -y -i audio_section.flac -ar 24k audio_section_24k.flac

echo "Subsampling at 12k"
ffmpeg -y -i audio_section.flac -ar 12k audio_section_12k.flac

echo "Extract left channel"
ffmpeg -y -i audio_section.flac \
    -filter_complex "[0:a]channelsplit=channel_layout=stereo[left][right]" \
    -map "[left]" audio_section_left.flac \
    -map "[right]" audio_section_right.flac