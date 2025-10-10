#!/bin/bash

echo "🎙️ Setting up Voice-to-Text for tmux..."

# Check if homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install homebrew first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install sox for audio recording
echo "📦 Installing sox for audio recording..."
brew install sox

# Install whisper for transcription
echo "🤖 Installing OpenAI Whisper for transcription..."
pip3 install openai-whisper

# Check if python3 is available
if ! command -v python3 &> /dev/null; then
    echo "⚠️  Python3 not found. Installing via homebrew..."
    brew install python3
fi

# Download whisper model (tiny model for fast transcription)
echo "⬇️  Downloading whisper model..."
python3 -c "import whisper; whisper.load_model('tiny')"

echo ""
echo "✅ Setup complete!"
echo ""
echo "🎯 Usage:"
echo "   1. Press your configured tmux key (currently set as Cmd-Ctrl-` or similar)"
echo "   2. Speak into your microphone"
echo "   3. Press Enter to stop recording"
echo "   4. The transcribed text will be sent to your tmux pane"
echo ""
echo "🔧 To configure a different key binding, edit:"
echo "   ~/.dotfiles/tmux.conf (look for voice-to-tmux.sh)"
echo ""
echo "🎤 Test the setup by running:"
echo "   ~/.dotfiles/scripts/voice-to-tmux.sh"