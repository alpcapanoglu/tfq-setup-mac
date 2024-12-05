# Installing Tensorflow Quantum on a Mac 
For people who aren't seasoned programmers, or computer nerds, or Linux admins, etc.
## Introduction
This whole process is built around the final goal that is building Tensorflow Quantum 'from source'. 
Every step before that is to facilitate that. You can either use the script that is provided (and update it as needed, for instance with some version inputs in some commands), or you can follow a step-by-step guide.

## Script
Place or copy the script in a location of your preference. It's best to do this through the terminal/CLI, as you will then need to
run the script through the CLI as well in order to provide some inputs. If you're new to this, don't be scared, just read through the following section.

I strongly suggest that you create a new directory, whether running the script or following the steps manually.

The script might go wrong in some places, most likely in Steps 1 or 7. If Step 1 is not working as expected, you can try
following the manual guide to install the system requirements (XCode, Homebrew, python 3.10, bazelisk and XCode Command Line Tools), 
and running the script again. You can also commend out Step 1 and try, to make sure. 

Step 7 might require some tampering with, depending on the versions of your XCode or potentially of other tools in your system. 
The command in the script is what worked for me.

As a side helper, to get the version of XCode that you have, there are a million ways out there, but the one that I found most useful
was: `system_profiler -json SPDeveloperToolsDataType
`

### Intro to CLI for beginners
You can use the command `cd` to "change directory", AKA navigate the file system. Example:
```shell
cd /Users/your-user/Desktop # Takes you to your desktop folder
cd some-folder-name # Takes you to some-folder-name, if it exists under the file that you are in.
```
The file that you are currently in will appear on the left of your cursor.
The "addresses" `.` and `..` point to "this directory/folder" and the "parent directory/folder", respectively.
To "list" the contents of the directory that you're in, use `ls`; this takes no inputs.

You can use `mkdir` to create new directories, AKA folders. This only takes the name of the directory that you want to create:
```shell
mkdir qfoo # Creates new empty directory called "qfoo"
```

Finally (almost), you can use `cp` followed by "/path/to/source" and "/path/to/target" (without quotes in the terminal) to copy a file. For a folder you need to add the recursive flag, `-r` to it:
```shell
cp /qbar/some-file.txt another-file.txt 
cp -r qfoo qbar/qfoo 
```

Made a mistake? "Remove" it using `rm`. Same rules go here for directories and the recursive flag:
```shell
rm another-file.txt # Deletes the file 
rm -r qfoo # Deletes the directory (including its contents) 
```

## Step-by-step guide
### Step 0 
- Install XCode (use the app store). Also run it and accept its T&C.
- Install Homebrew. Go to the Homebrew website and follow installation instructions; any version will do.

### Step 1
Install XCode Command Line tools:
```shell
xcode-select --install
```
Install python 3.10 and bazelisk using brew (Homebrew):
```shell
brew update
brew install python@3.10
brew install bazelisk
```

### Step 2 
Create & activate virtual environment with Python 3.10.
```shell
python3.10 -m venv .tfq
source .tfq/bin/activate
```

### Step 3
Install tensorflow 2.15.0
```shell
pip install --update pip wheel setuptools
pip install tensorflow==2.15.0
```

### Step 4 
Clone the TFQ repo (and navigate to it)
```shell
git clone https://github.com/tensorflow/quantum.git
cd quantum
```

### Step 5 
Run TFQ build config script & install TFQ's dependencies
The configuration script will ask for input, unless you know what you're doing, select yes/'y' and yes/'y'.
```shell
bash ./configure.sh
pip install -r requirements.txt
```

### Step 6
Rename some Tensorflow files from the venv installations, because reasons (in particular because we installed Tensorflow instead of building it from source).
```shell
cp ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_cc.2.dylib ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_cc.dylib
cp ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_framework.2.dylib ../.tfq/lib/python3.10/site-packages/tensorflow/libtensorflow_framework.dylib
```

### Step 7
Attempt build. Things that can go wrong:
- XCode version might be wrong, feel free to update it to whatever version you have. You can use `system_profiler -json SPDeveloperToolsDataType` to get the version (see "macOS" under "spdevtools_sdks").
- C++17 is rather old, but you might have trouble building it depending on how old your gcc is. Either update Xcode Command Line Tools or gcc.
- Many other unknowable things if you're unlucky. I suggest phind.com to debug any errors if you can't reach me.
```shell
bazel build --xcode_version=16.1 -c opt --cxxopt="-O3" --cxxopt="-march=native" --cxxopt="-std=c++17" --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=1" release:build_pip_package
```

### Step 8
Package build into wheel, to be installed locally and install into this venv. 
```shell
bazel-bin/release/build_pip_package /tmp/tfquantum/
python3 -m pip install /tmp/tfquantum/$(ls /tmp/tfquantum)
```

## Final state
You can test whether the installation worked with the following command:
```shell
python3 -c "import tensorflow as tf; print(tf.config.list_physical_devices('CPU'))"
```

You can now use Tensorflow Quantum in this virtual environment. You will not be able to use it elsewhere, this is something that I have not yet done.