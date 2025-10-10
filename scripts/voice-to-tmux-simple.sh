#!/bin/bash

# Simple voice-to-text for tmux
# This version works better in tmux popups

TEMP_AUDIO="/tmp/voice_$(date +%s).wav"

cleanup() {
    rm -f "$TEMP_AUDIO" 2>/dev/null
    exit 0
}

trap cleanup EXIT INT TERM

echo "🎤 Voice-to-Text Recording"
echo "========================"
echo ""
echo "Press ENTER to start recording..."
read -r

echo "🔴 Recording... Press ENTER to stop"

# Start recording
if command -v sox &> /dev/null; then
    rec -q -t wav "$TEMP_AUDIO" rate 16k channels 1 &
elif command -v ffmpeg &> /dev/null; then
    ffmpeg -f avfoundation -i ":0" -ar 16000 -ac 1 "$TEMP_AUDIO" -loglevel quiet &
else
    echo "❌ Install sox: brew install sox"
    exit 1
fi

RECORDING_PID=$!

# Wait for stop signal
read -r

# Stop recording
kill $RECORDING_PID 2>/dev/null
sleep 0.5

echo ""
echo "🔄 Transcribing..."

# Check if file exists and has content
if [ ! -f "$TEMP_AUDIO" ] || [ ! -s "$TEMP_AUDIO" ]; then
    echo "❌ No audio recorded"
    exit 1
fi

# Transcribe
if command -v whisper &> /dev/null; then
    whisper "$TEMP_AUDIO" --language en --model turbo --output_format txt --output_dir /tmp &>/dev/null

    # Get the filename without extension
    BASENAME=$(basename "$TEMP_AUDIO" .wav)

    if [ -f "/tmp/${BASENAME}.txt" ]; then
        TRANSCRIPTION=$(cat "/tmp/${BASENAME}.txt" | tr -d '\n' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        rm -f "/tmp/${BASENAME}.txt"
    else
        echo "❌ Transcription failed"
        echo "Press any key to close..."
        read -r
        exit 1
    fi
else
    echo "❌ Whisper not found. Installing..."
    echo ""
    echo "Run: pip3 install openai-whisper"
    echo ""
    echo "Press any key to close..."
    read -r
    exit 1
fi

# Clean the transcription
TRANSCRIPTION=$(echo "$TRANSCRIPTION" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

if [ -z "$TRANSCRIPTION" ] || [ "$TRANSCRIPTION" = " " ]; then
    echo "❌ No speech detected"
    echo "Press any key to close..."
    read -r
    exit 1
fi

echo ""
echo "📝 Transcribed: \"$TRANSCRIPTION\""
echo ""

# Send to tmux
if [ -n "$TMUX" ]; then
    # Find the calling pane (the one that opened this popup)
    CALLING_PANE=$(tmux list-panes -F '#{pane_id}:#{pane_active}' | grep ':1$' | cut -d: -f1 | head -1)

    if [ -z "$CALLING_PANE" ]; then
        # Fallback: get all panes except current popup
        CALLING_PANE=$(tmux list-panes -F '#{pane_id}' | head -1)
    fi

    if [ -n "$CALLING_PANE" ]; then
        tmux send-keys -t "$CALLING_PANE" "$TRANSCRIPTION"
        echo "✅ Sent to tmux pane $CALLING_PANE"
    else
        echo "❌ Could not find target pane"
        exit 1
    fi
else
    echo "❌ Not in tmux session"
    exit 1
fi

echo ""
echo "Press any key to close..."
read -r