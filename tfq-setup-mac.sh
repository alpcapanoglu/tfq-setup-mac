#!/bin/zsh

# Install XCode, run it and accept T&C
echo "[Step 0]: WARNING: Before you start:\nYou need to install the following before running this script:\n
1 - XCode (use the app store). Also run it and accept its T&C.
2 - Brew (go to the Homebrew website and follow installation instructions), any version will do.\n
It is suggested to run this script when you have access to high-bandwidth internet and with your machine plugged in.\n
When you have both of these things installed, you can press any key (and enter) to continue this installation script.\n
You can press Ctrl+C at any time to stop the script.\n"
read -n 1

# Install python 3.10 and bazelisk
echo "\n\n[Step 1] Installing Python 3.10, Bazelisk and Xcode Command Line Tools The last one will take a while and will
need you to answer questions.\n"
sleep 2
brew update
brew install python@3.10
brew install bazelisk
xcode-select --install


# Create venv with python 3.10
echo "\n\n[Step 2] Creating virtual environment with Python 3.10.\n"
sleep 2
python3.10 -m venv .tfq
source .tfq/bin/activate

# Install tensorflow 2.15.0
echo "\n\n[Step 3] Updating pip and installing Tensorflow 2.15.0.\n"
sleep 2
pip install --update pip wheel setuptools
pip install tensorflow==2.15.0

# Clone the TFQ repo
echo "\n\n[Step 4] Cloning Tensorflow Quantum from source."
sleep 2
git clone https://github.com/tensorflow/quantum.git
cd quantum

# Run TFQ build config script
echo "\n\n[Step 5] Run the configuration script by TFQ and install dependencies.
Warning: You will have to provide input (I suggest 'y' 'y'.\n"
sleep 2
bash ./configure.sh
pip install -r requirements.txt

# Rename some Tensorflow files from the venv installations, because reasons.
echo "\n\n[Step 6] Because we took a shortcut by installing Tensorflow instead of taking an hour to build it ourselves,
we need to change the names of some files."
cp ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_cc.2.dylib ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_cc.dylib
cp ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_framework.2.dylib ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_framework.dylib

# Attempt build. Things that can go wrong:
# - XCode version might be wrong, feel free to update it to whatever version you have.
# - C++17 is rather old, but you might have trouble building it depending on how old your gcc is. Either update Xcode Command Line Tools or gcc.
# - Many other unknowable things if you're unlucky. I suggest phind.com to debug any errors if you can't reach me.
echo "\n\n[Step 7] Build Tensorflow Quantum.\n"
bazel build --xcode_version=16.1 -c opt --cxxopt="-O3" --cxxopt="-march=native" --cxxopt="-std=c++17" --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=1" release:build_pip_package

# Package build into wheel, to be installed locally and install into this venv.
bazel-bin/release/build_pip_package /tmp/tfquantum/
python3 -m pip install /tmp/tfquantum/$(ls /tmp/tfquantum)