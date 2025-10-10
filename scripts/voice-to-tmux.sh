#!/bin/bash

# Voice-to-text for tmux integration
# Records audio, transcribes it, and sends to active tmux pane

TEMP_AUDIO="/tmp/voice_recording.wav"
RECORDING_PID_FILE="/tmp/voice_recording.pid"

# Function to start recording
start_recording() {
  echo "🎤 Recording... (Press Enter to stop)"

  # Clean up any previous recording
  rm -f "$TEMP_AUDIO"

  # Start recording in background
  if command -v sox &>/dev/null; then
    # Using sox (works on macOS with brew install sox)
    rec -q -t wav "$TEMP_AUDIO" rate 16k channels 1 &
  elif command -v ffmpeg &>/dev/null; then
    # Fallback to ffmpeg (for macOS)
    ffmpeg -f avfoundation -i ":0" -ar 16000 -ac 1 -t 30 "$TEMP_AUDIO" -loglevel quiet &
  else
    echo "❌ No audio recording tool found. Install sox: brew install sox"
    return 1
  fi

  RECORDING_PID=$!
  echo $RECORDING_PID >"$RECORDING_PID_FILE"

  # Wait for Enter key
  read -r

  # Stop recording
  if [ -f "$RECORDING_PID_FILE" ]; then
    kill $RECORDING_PID 2>/dev/null
    rm "$RECORDING_PID_FILE"
    # Give it a moment to finish
    sleep 0.5
  fi
}

# Function to transcribe audio
transcribe_audio() {
  if [ ! -f "$TEMP_AUDIO" ]; then
    echo "❌ No audio file found"
    return 1
  fi

  # Check if file has content
  if [ ! -s "$TEMP_AUDIO" ]; then
    echo "❌ Empty audio file"
    rm -f "$TEMP_AUDIO"
    return 1
  fi

  # Using whisper (install with: pip install openai-whisper)
  if command -v whisper &>/dev/null; then
    TRANSCRIPTION=$(whisper "$TEMP_AUDIO" --language en --model tiny --output_format txt --output_dir /tmp 2>/dev/null)
    # Get the actual text from the output file
    if [ -f "/tmp/voice_recording.txt" ]; then
      TRANSCRIPTION=$(cat "/tmp/voice_recording.txt" | tr -d '\n' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      rm -f "/tmp/voice_recording.txt"
    fi
  # Alternative: use macOS built-in speech recognition (if available)
  elif command -v osascript &>/dev/null; then
    # Convert wav to a format osascript can handle, then use macOS speech recognition
    echo "Using macOS speech recognition (limited)"
    TRANSCRIPTION="[Speech recognition not available - install whisper: pip install openai-whisper]"
  else
    echo "❌ No transcription tool found. Install whisper: pip install openai-whisper"
    rm -f "$TEMP_AUDIO"
    return 1
  fi

  # Clean up audio file
  rm -f "$TEMP_AUDIO"

  echo "$TRANSCRIPTION"
}

# Function to send text to tmux
send_to_tmux() {
  local text="$1"

  if [ -z "$text" ] || [ "$text" = " " ]; then
    echo "❌ No text to send"
    return 1
  fi

  # Check if we're in tmux
  if [ -n "$TMUX" ]; then
    # Get the pane that was active before the popup opened
    # tmux popup saves the original pane ID in TMUX_POPUP_PANE_ID
    if [ -n "$TMUX_POPUP_PANE_ID" ]; then
      TARGET_PANE="$TMUX_POPUP_PANE_ID"
    else
      # Fallback to current pane
      TARGET_PANE=$(tmux display-message -p '#S:#I.#P')
    fi

    # Send text to target pane
    tmux send-keys -t "$TARGET_PANE" "$text"
    echo "✅ Sent: $text"
  else
    echo "❌ Not in tmux session"
    return 1
  fi
}

# Main function
main() {
  # Check dependencies
  if ! command -v tmux &>/dev/null; then
    echo "tmux not found"
    exit 1
  fi

  # Start the process
  start_recording

  # Transcribe the audio
  TRANSCRIBED_TEXT=$(transcribe_audio)

  if [ -n "$TRANSCRIBED_TEXT" ]; then
    echo "📝 Transcribed: $TRANSCRIBED_TEXT"
    send_to_tmux "$TRANSCRIBED_TEXT"
  else
    echo "❌ No transcription available"
  fi
}

# Run main function
main "$@"

