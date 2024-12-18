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

echo "Extract left and right channels"
ffmpeg -y -i audio_section.flac \
    -filter_complex "[0:a]channelsplit=channel_layout=stereo[left][right]" \
    -map "[left]" audio_section_left.flac \
    -map "[right]" audio_section_right.flac

echo "Merge stereo channels"
ffmpeg -y -i audio_section.flac -ac 1 mono.flac

echo "Fade in/out"
ffmpeg -y -i mono.flac -af afade=t=in:ss=0:ns=44100 mono_fade_in.flac 
ffmpeg -y -i mono.flac -af afade=t=out:ss=$((44100*4)):ns=44100 mono_fade_out.flac 
ffmpeg -y -i mono.flac -af "afade=t=in:ss=0:ns=44100,afade=t=out:ss=$((44100*4)):ns=44100" mono_fade_both.flac 

echo "Tremolo"
ffmpeg -y -i mono.flac -af tremolo=f=10:d=0.5 mono_tremolo.flac 

echo "Vibrato"
ffmpeg -y -i mono.flac -af vibrato=f=4:d=0.5 mono_vibrato.flac 

echo "Echo"
ffmpeg -y -i mono.flac -af aecho=in_gain=1.0:out_gain=1.0:delays=400:decays=0.2 mono_echo.flac 

echo "Frequency shift"
ffmpeg -y -i mono.flac -af afreqshift=shift=100 mono_higher_shift.flac 
ffmpeg -y -i mono.flac -af afreqshift=shift=-100 mono_lower_shift.flac 

echo "Compressor"
ffmpeg -y -i mono.flac -af acompressor=threshold=-60dB  mono_compressed.flac 

echo "Expander"
ffmpeg -y -i mono.flac -af "compand=attacks=0:points=-40/-169|-10/-4|0/0" mono_expanded.flac 

echo "Compressor (with compand)"
ffmpeg -y -i mono.flac -af "compand=attacks=0:points=-40/-10|-4/-10|0/0" mono_compand_compressed.flac 

echo "Lossy MP3 compression at 96kbps"
ffmpeg -y -i mono.flac -c:a libmp3lame -b:a 96k mono_compressed_96k.mp3

echo "Lossy MP3 compression at 64kbps"
ffmpeg -y -i mono.flac -c:a libmp3lame -b:a 64k mono_compressed_64k.mp3

echo "Lossy MP3 compression at 32kbps"
ffmpeg -y -i mono.flac -c:a libmp3lame -b:a 32k mono_compressed_32k.mp3

echo "Concatenation"
ffmpeg -y -f concat -i compression_concat.txt mono_compressed_all.mp3

echo "Looped 4 times (stream_loop = repeat X more times)"
ffmpeg -y -stream_loop 3 -i mono.flac mono_looped.flac

echo "Frequency spectrum"
ffmpeg -y -i mono_compressed_96k.mp3 -lavfi showspectrumpic=s=hd720 compressed_96k.jpg
ffmpeg -y -i mono_compressed_32k.mp3 -lavfi showspectrumpic=s=hd720 compressed_32k.jpg

echo "Speed-up"
ffmpeg -y -i mono.flac -filter:a "atempo=2.0" mono_double_speed.wav

echo "Slow-down"
ffmpeg -y -i mono.flac -filter:a "atempo=0.5" mono_half_speed.wav