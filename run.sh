echo "Extract audio from video"
ffmpeg -y -i music_video.mp4 -vn -c:a flac whole_audio.flac

echo "Slice an audio"
ffmpeg -y -ss 00:00:11 -to 00:00:16 -i whole_audio.flac -c copy audio_section.flac
