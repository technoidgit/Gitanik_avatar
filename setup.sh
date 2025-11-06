#!/bin/bash
# ====================================================
# 🧠 Gitanik Avatar - Full Environment Setup (macOS)
# ====================================================
# Builds: llama.cpp + whisper.cpp + installs TTS + downloads models
# ====================================================

echo "🚀 Starting Gitanik Avatar environment setup..."

# ------------------------------------
# 1️⃣ Create & activate virtual environment
# ------------------------------------
if [ ! -d "venv" ]; then
  echo "📦 Creating virtual environment..."
  python3 -m venv venv
else
  echo "✅ Virtual environment already exists."
fi

source venv/bin/activate

# ------------------------------------
# 2️⃣ Upgrade pip and install requirements
# ------------------------------------
echo "📥 Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt || echo "⚠️  No requirements.txt found, skipping."

# ------------------------------------
# 3️⃣ Build llama.cpp
# ------------------------------------
echo "🦙 Building llama.cpp..."
cd services/llm/llama.cpp || { echo "❌ llama.cpp folder missing!"; exit 1; }
if [ ! -d "build" ]; then
  mkdir build && cd build
  cmake .. && cmake --build . --config Release
else
  cd build
  cmake --build . --config Release
fi
cd ../../../..  # back to root

# ------------------------------------
# 4️⃣ Build whisper.cpp
# ------------------------------------
echo "🗣️  Building whisper.cpp..."
cd services/asr/whisper.cpp || { echo "❌ whisper.cpp folder missing!"; exit 1; }
if [ ! -d "build" ]; then
  mkdir build && cd build
  cmake .. && cmake --build . --config Release
else
  cd build
  cmake --build . --config Release
fi
cd ../../../..  # back to root

# ------------------------------------
# 5️⃣ Download TinyLlama GGUF model
# ------------------------------------
MODEL_DIR="models"
MODEL_FILE="TinyLlama-1.1B-Chat-v1.0.Q8_0.gguf"
MODEL_URL="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/TinyLlama-1.1B-Chat-v1.0.Q8_0.gguf"

mkdir -p $MODEL_DIR

if [ ! -f "$MODEL_DIR/$MODEL_FILE" ]; then
  echo "⬇️  Downloading TinyLlama model (~1.1 GB)..."
  curl -L -o "$MODEL_DIR/$MODEL_FILE" "$MODEL_URL"
else
  echo "✅ Model already downloaded."
fi

# ------------------------------------
# 6️⃣ Download Coqui TTS model
# ------------------------------------
echo "🔊 Downloading TTS model (vctk/vits)..."
python -m TTS.utils.manage --download_model "tts_models/en/vctk/vits"

# ------------------------------------
# 7️⃣ Success summary
# ------------------------------------
echo "🎉 Gitanik Avatar setup complete!"
echo ""
echo "🧩 Components ready:"
echo "   - llama.cpp ✅"
echo "   - whisper.cpp ✅"
echo "   - Coqui TTS ✅"
echo "   - TinyLlama model ✅"
echo ""
echo "👉 Activate environment: source venv/bin/activate"
echo "👉 Run LLM from: services/llm/llama.cpp/build/bin/llama-cli"
echo "👉 Run TTS via: python -m TTS.bin.synthesize"
echo "👉 Run ASR via: services/asr/whisper.cpp/build/bin/whisper"
