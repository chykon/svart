#!/bin/bash

set -euo pipefail

# Add Dart repository key.

declare -r input_pubkey_file='tool/devcontainer/dart.pub'
declare -r output_pubkey_file='/usr/share/keyrings/dart.gpg'

sudo gpg --output ${output_pubkey_file} --dearmor ${input_pubkey_file}

# Add Dart repository.

declare -r dart_repository_url='https://storage.googleapis.com/download.dartlang.org/linux/debian'
declare -r dart_repository_file='/etc/apt/sources.list.d/dart_stable.list'

echo "deb [signed-by=${output_pubkey_file}] ${dart_repository_url} stable main" | sudo tee ${dart_repository_file}

# Install Dart SDK.

sudo apt-get update
sudo apt-get install dart

# Get project dependencies.

dart pub get
