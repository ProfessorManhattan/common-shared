#!/bin/bash

# This file houses all the shared functions used across various
# update.sh files which are used to synchronize common files
# across many different projects. It also includes various
# functions that perform maintenance tasks and install missing
# software requirements like Node.js and Python.


ANSIBLE_GALAXY_USERNAME=professormanhattan

##############################################
############## COMMON FUNCTIONS ##############
##############################################


# Logs an error message
error() {
  if [ "$container" != 'docker' ]; then
    run-func ./.modules/shared/log.js error "$1"
  else
    echo "ERROR: $1"
  fi
}

# Logs an info message
info() {
  if [ "$container" != 'docker' ]; then
    run-func ./.modules/shared/log.js info "$1"
  else
    echo "INFO $1"
  fi
}

# Logs a regular log message
log() {
  if [ "$container" != 'docker' ]; then
    run-func ./.modules/shared/log.js debug "$1"
  else
    echo "LOG: $1"
  fi
}

# Logs a success message
success() {
  if [ "$container" != 'docker' ]; then
    run-func ./.modules/shared/log.js success "$1"
  else
    echo "SUCCESS: $1"
  fi
}

# Logs a warning message
warn() {
  if [ "$container" != 'docker' ]; then
    run-func ./.modules/shared/log.js warn "$1"
  else
    echo "WARN: $1"
  fi
}

# Determines whether or not an executable is accessible
command_exists() {
  type "$1" &>/dev/null
}

# Verifies the SHA256 checksum of a file
# Usage: sha256 <file> <checksum>
sha256() {
  if [ "$(uname)" == "Darwin" ]; then
    echo "$2 $1" | sha256sum --check
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "$1  $2" | shasum -s -a 256 -c
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    error "Windows support not added yet"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    error "Windows support not added yet"
  fi
}

##############################################
########### DEPENDENCY INSTALLERS ############
##############################################

# Ensures the docker pushrm plugin is installed. This is used to automatically
# update the README.md embedded on the DockerHub website.
ensure_docker_pushrm_installed() {
  if [ "$container" != 'docker' ]; then
    log "Checking whether docker-pushrm is already installed"
    if [ "$(uname)" == "Darwin" ]; then
      # System is Mac OS X
      local DESTINATION="$HOME/.docker/cli-plugins/docker-pushrm"
      local DOWNLOAD_SHA256=ffd208cd01287f457878d4851697477c0493c5e937d7ebfa36cca46d37bff659
      local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_darwin_amd64
      if [ ! -f "$DESTINATION" ]; then
        info "docker-pushrm is not currently installed"
        log "Ensuring the ~/.docker/cli-plugins folder exists"
        mkdir -p $HOME/.docker/cli-plugins
        log "Downloading docker-pushrm"
        wget $DOWNLOAD_URL -O $DESTINATION
        sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        chmod +x $DESTINATION
        success "docker-pushrm successfully installed to the ~/.docker/cli-plugins folder"
      else
        info "docker-pushrm is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      # System is Linux
      local DESTINATION="$HOME/.docker/cli-plugins/docker-pushrm"
      local DOWNLOAD_SHA256=7475cbdf63a6887bd46f44549fba6b04113b6979dc6977b3fdfb2cdd62162771
      local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_linux_amd64
      if [ ! -f "$DESTINATION" ]; then
        info "docker-pushrm is not currently installed"
        log "Ensuring the ~/.docker/cli-plugins folder exists"
        mkdir -p $HOME/.docker/cli-plugins
        log "Downloading docker-pushrm"
        wget $DOWNLOAD_URL -O $DESTINATION
        sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        chmod +x $DESTINATION
        success "docker-pushrm successfully installed to the ~/.docker/cli-plugins folder"
      else
        info "docker-pushrm is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      # System is Windows 32-bit
      local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_windows_386.exe
      error "Windows support has not been added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      # System is Windows 64-bit
      local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_windows_amd64.exe
      error "Windows support has not been added yet"
    fi
  else
    info "Bypassing installation of docker-pushrm because the 'container' environment variable is set to 'docker'"
  fi
}

# Ensures DockerSlim is installed. If it is not present, it is installed to ~/.local/bin for
# the current user
ensure_dockerslim_installed() {
  if [ "$container" != 'docker' ]; then
    log "Checking whether DockerSlim is already installed"
    if [ "$(uname)" == "Darwin" ]; then
      # System is Mac OS X
      local BASH_PROFILE="$HOME/.bash_profile"
      local DESTINATION="$HOME/.local/bin/docker-slim"
      local DOWNLOAD_DESTINATION=/tmp/megabytelabs/dist_mac.zip
      local DOWNLOAD_SHA256=1e37007d1e69e98841f1af9a78c0eae4b419449c0fd66c9e40d7426c47d5d57e
      local DOWNLOAD_URL=https://downloads.dockerslim.com/releases/1.35.1/dist_mac.zip
      local TMP_DIR=/tmp/megabytelabs
      local USER_BIN_FOLDER="$HOME/.local/bin"
      if [ ! -f "$DESTINATION" ] && ! command_exists docker-slim; then
        info "DockerSlim is not currently installed"
        log "Downloading DockerSlim for Mac OS X"
        mkdir -p $TMP_DIR
        wget $DOCKER_SLIM_DOWNLOAD_LINK -O $DOWNLOAD_DESTINATION
        sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        unzip $DOWNLOAD_DESTINATION -d $TMP_DIR
        log "Ensuring the ~/.local/bin folder exists"
        mkdir -p $USER_BIN_FOLDER
        cp $TMP_DIR/dist_mac/* $USER_BIN_FOLDER
        rm -rf $TMP_DIR/dist_mac
        rm $DOWNLOAD_DESTINATION
        chmod +x $USER_BIN_FOLDER/docker-slim
        chmod +x $USER_BIN_FOLDER/docker-slim-sensor
        success "DockerSlim successfully installed to the ~/.local/bin folder"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bash_profile
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "DockerSlim is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      # System is Linux
      local BASH_PROFILE="$HOME/.bashrc"
      local DESTINATION="$HOME/.local/bin/docker-slim"
      local DOWNLOAD_DESTINATION=/tmp/megabytelabs/dist_linux.tar.gz
      local DOWNLOAD_SHA256=b0f1b488d33b09be8beb224d4d26cb2d3e72669a46d242a3734ec744116b004c
      local DOWNLOAD_URL=https://downloads.dockerslim.com/releases/1.35.1/dist_linux.tar.gz
      local TMP_DIR=/tmp/megabytelabs
      local USER_BIN_FOLDER="$HOME/.local/bin"
      if [ ! -f "$DESTINATION" ] && ! command_exists docker-slim; then
        info "DockerSlim is not currently installed"
        log "Downloading DockerSlim for Linux"
        mkdir -p $TMP_DIR
        wget $DOCKER_SLIM_DOWNLOAD_LINK -O $DOWNLOAD_DESTINATION
        sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        tar -zxvf $DOWNLOAD_DESTINATION
        log "Ensuring the ~/.local/bin folder exists"
        mkdir -p $USER_BIN_FOLDER
        cp $TMP_DIR/dist_linux/* $USER_BIN_FOLDER
        rm $TMP_DIR/dist_linux.tar.gz
        rm -rf $TMP_DIR/dist_linux
        chmod +x $USER_BIN_FOLDER/docker-slim
        chmod +x $USER_BIN_FOLDER/docker-slim-sensor
        success "DockerSlim successfully installed to the ~/.local/bin folder"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "DockerSlim is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      # System is Windows 32-bit
      error "Windows support has not been added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      # System is Windows 64-bit
      error "Windows support has not been added yet"
    fi
  else
    info "Bypassing installation of DockerSlim because the 'container' environment variable is set to 'docker'"
  fi
}

# Ensures jq is installed. If it is not present, it is installed to ~/.local/bin for
# the current user
ensure_jq_installed() {
  if [ "$container" != 'docker' ]; then
    log "Checking whether jq is already installed"
    if [ "$(uname)" == "Darwin" ]; then
      # System is Mac OS X
      local BASH_PROFILE="$HOME/.bash_profile"
      local DESTINATION="$HOME/.local/bin/jq"
      local DOWNLOAD_SHA256=5c0a0a3ea600f302ee458b30317425dd9632d1ad8882259fcaf4e9b868b2b1ef
      local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64
      local USER_BIN_FOLDER="$HOME/.local/bin"
      if [ ! -f "$DESTINATION" ] && ! command_exists jq; then
        info "jq is not currently installed"
        log "Ensuring the ~/.local/bin folder exists"
        mkdir -p $USER_BIN_FOLDER
        log "Downloading jq for Mac OS X" # TODO: For all installers, remove the file if the checksum fails
        wget $DOWNLOAD_URL -O $DESTINATION
        sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        chmod +x $DESTINATION
        success "jq successfully installed to the ~/.local/bin folder"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bash_profile
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "jq is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      # System is Linux
      local BASH_PROFILE="$HOME/.bashrc"
      local DESTINATION="$HOME/.local/bin/jq"
      local DOWNLOAD_SHA256=af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44
      local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
      local USER_BIN_FOLDER="$HOME/.local/bin"
      if [ ! -f "$DESTINATION" ] && ! command_exists jq; then
        info "jq is not currently installed"
        log "Ensuring the ~/.local/bin folder exists"
        mkdir -p $USER_BIN_FOLDER
        log "Downloading jq for Linux"
        wget $DOWNLOAD_URL -O $DESTINATION
        sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        chmod +x $DESTINATION
        success "jq successfully installed to the ~/.local/bin folder"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "jq is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      # System is Windows 32-bit
      local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win32.exe
      error "Windows support has not been added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      # System is Windows 64-bit
      local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
      error "Windows support has not been added yet"
    fi
  else
    info "Bypassing installation of jq because the 'container' environment variable is set to 'docker'"
  fi
}

# Ensures yq is installed. If it is not present, it is installed to ~/.local/bin for
# the current user
ensure_yq_installed() {
  if [ "$container" != 'docker' ]; then
    log "Checking whether yq is already installed"
    if [ "$(uname)" == "Darwin" ]; then
      # System is Mac OS X
      local BASH_PROFILE="$HOME/.bash_profile"
      local DESTINATION="$HOME/.local/bin/yq"
      local DOWNLOAD_SHA256=b8022412841288a1ed5bfa51b3899631b566e2d9508f3ae55d4e0b9a1b6ac3a6
      local DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_darwin_amd64
      local USER_BIN_FOLDER="$HOME/.local/bin"
      if [ ! -f "$DESTINATION" ] && ! command_exists yq; then
        info "yq is not currently installed"
        log "Ensuring the ~/.local/bin folder exists"
        mkdir -p $USER_BIN_FOLDER
        log "Downloading yq for Mac OS X"
        wget $DOWNLOAD_URL -O $DESTINATION
        sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        chmod +x $DESTINATION
        success "yq successfully installed to the ~/.local/bin folder"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bash_profile
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "yq is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      # System is Linux
      local BASH_PROFILE="$HOME/.bashrc"
      local DESTINATION="$HOME/.local/bin/yq"
      local DOWNLOAD_SHA256=c0a7ea321579c6019f00ff4a46cc2f64ce903aa01ec52de21befe0f93e4a6ca1
      local DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_linux_amd64
      local USER_BIN_FOLDER="$HOME/.local/bin"
      if [ ! -f "$DESTINATION" ] && ! command_exists yq; then
        info "yq is not currently installed"
        log "Ensuring the ~/.local/bin folder exists"
        mkdir -p $USER_BIN_FOLDER
        log "Downloading yq for Linux"
        wget $DOWNLOAD_URL -O $DESTINATION
        sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        chmod +x $DESTINATION
        success "yq successfully installed to the ~/.local/bin folder"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "yq is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      # System is Windows 32-bit
      local DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_windows_386.exe
      error "Windows support has not been added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      # System is Windows 64-bit
      local DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_windows_amd64.exe
      error "Windows support has not been added yet"
    fi
  else
    info "Bypassing installation of yq because the 'container' environment variable is set to 'docker'"
  fi
}

# Ensures Node.js is installed by using nvm
ensure_node_installed() {
  if [ "$container" != 'docker' ]; then
    if ! command_exists npx; then
      echo "A recent version of Node.js is not installed."
      echo "Installing nvm"
      wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
      export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      echo "Installing Node.js via nvm"
      nvm install node
      local NODE_INSTALLED=true
    fi
    if [ ! -d node_modules ]; then
      echo "The node_modules folder appears to be missing"
      echo "Installing project npm dependencies"
      if [ ! -f package.json ]; then
        cp ./.modules/$REPO_TYPE/files/package.json package.json
      fi
      npm install
      exit 0
    fi
    if ! command_exists run-func; then
      npm install -g run-func
      if [ "$NODE_INSTALLED" == true ]; then
        success "The latest version of Node.js has been successfully installed"
        info "The script will continue to use the latest version of Node.js but in order to use it yourself you will have to close/open the terminal"
        success "Successfully installed npm global dependency (run-func)"
        log "Installing husky pre-commit git hook"
        success "Successfully installed husky pre-commit git hook"
      fi
    fi
    log "Ensuring husky pre-commit hook is registered"
    npx husky install
    success "Husky pre-commit hook is registered"
  else
    info "Bypassing installation of Node.js because the 'container' environment variable is set to 'docker'"
  fi
}

ensure_packer_installed() {
  if [ "$container" != 'docker' ]; then
    log "Checking whether Packer is already installed"
    local DOWNLOAD_DESTINATION=/tmp/megabytelabs/packer.zip
    local TMP_DIR=/tmp/megabytelabs
    local USER_BIN_FOLDER="$HOME/.local/bin"
    if [ "$(uname)" == "Darwin" ]; then
      local BASH_PROFILE="$HOME/.bash_profile"
      local DOWNLOAD_SHA256=2dd688672157eed5d9f5126b1dd160862926ab698dc91e4ffb5a7fc2deb0b037
      local DOWNLOAD_URL=https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_darwin_amd64.zip
      if ! command_exists packer; then
        info "Packer is not currently installed"
        mkdir -p $TMP_DIR
        mkdir -p "$USER_BIN_FOLDER"
        log "Downloading the Packer binary"
        wget $DOWNLOAD_URL -O $DOWNLOAD_DESTINATION
        sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        log "Installing Packer"
        unzip "$DOWNLOAD_DESTINATION" -d "$TMP_DIR"
        mv "$TMP_DIR/packer" "$HOME/.local/bin/packer"
        success "Successfully installed Packer to ~/.local/bin"
        rm "$DOWNLOAD_DESTINATION"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "Packer is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      local BASH_PROFILE="$HOME/.bashrc"
      local DOWNLOAD_SHA256=9429c3a6f80b406dbddb9b30a4e468aeac59ab6ae4d09618c8d70c4f4188442e
      local DOWNLOAD_URL=https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_linux_amd64.zip
      if ! command_exists packer; then
        info "Packer is not currently installed"
        mkdir -p $TMP_DIR
        mkdir -p "$USER_BIN_FOLDER"
        log "Downloading the Packer binary"
        wget $DOWNLOAD_URL -O $DOWNLOAD_DESTINATION
        sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        log "Installing Packer"
        unzip "$DOWNLOAD_DESTINATION" -d "$TMP_DIR"
        mv "$TMP_DIR/packer" "$HOME/.local/bin/packer"
        success "Successfully installed Packer to ~/.local/bin"
        rm "$DOWNLOAD_DESTINATION"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "Packer is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      error "Windows support not added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      error "Windows support not added yet"
    fi
  else
    info "Bypassing installation of Packer because the 'container' environment variable is set to 'docker'"
  fi
}

ensure_python3_installed() {
  if [ "$container" != 'docker' ]; then
    log "Checking whether Python 3 is already installed"
    if [ "$(uname)" == "Darwin" ]; then
      local BASH_PROFILE="$HOME/.bash_profile"
      local DOWNLOAD_DESTINATION=/tmp/megabytelabs/miniconda.sh
      local DOWNLOAD_SHA256=b3bf77cbb81ee235ec6858146a2a84d20f8ecdeb614678030c39baacb5acbed1
      local DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-MacOSX-x86_64.sh
      local MINICONDA_BIN_FOLDER="$HOME/.local/miniconda/bin"
      local MINICONDA_PATH="$HOME/.local/miniconda"
      local TMP_DIR=/tmp/megabytelabs
      if ! command_exists python3; then
        info "Python 3 is not currently installed"
        mkdir -p $TMP_DIR
        mkdir -p $HOME/.local
        log "Downloading miniconda to install Python 3"
        wget $DOWNLOAD_URL -O $DOWNLOAD_DESTINATION
        sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        log "Installing Python 3 via miniconda"
        bash $DOWNLOAD_DESTINATION -b -p $HOME/.local/miniconda
        success "Python 3 and miniconda successfully installed to ~/.local/miniconda"
        rm $DOWNLOAD_DESTINATION
        export PATH="$MINICONDA_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/miniconda/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/miniconda/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/miniconda/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/miniconda/bin folder is already included in the PATH variable"
        fi
      else
        info "Python 3 is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      local BASH_PROFILE="$HOME/.bashrc"
      local DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
      local DOWNLOAD_SHA256=536817d1b14cb1ada88900f5be51ce0a5e042bae178b5550e62f61e223deae7c
      local DOWNLOAD_DESTINATION=/tmp/megabytelabs/miniconda.sh
      local MINICONDA_BIN_FOLDER="$HOME/.local/miniconda/bin"
      local MINICONDA_PATH="$HOME/.local/miniconda"
      local TMP_DIR=/tmp/megabytelabs
      if ! command_exists python3; then
        info "Python 3 is not currently installed"
        mkdir -p $TMP_DIR
        mkdir -p $HOME/.local
        log "Downloading miniconda to install Python 3"
        wget $DOWNLOAD_URL -O $DOWNLOAD_DESTINATION
        sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        log "Installing Python 3 via miniconda"
        bash $DOWNLOAD_DESTINATION -b -p $MINICONDA_PATH
        success "Python 3 and miniconda successfully installed to ~/.local/miniconda"
        rm $DOWNLOAD_DESTINATION
        export PATH="$MINICONDA_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/miniconda/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/miniconda/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/miniconda/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/miniconda/bin folder is already included in the PATH variable"
        fi
      else
        info "Python 3 is already installed"
      fi
      wget $DOWNLOAD_URL -O $DESTINATION
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      local DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Windows-x86.exe
      local DOWNLOAD_SHA256=5045fb9dc4405dbba21054262b7d104ba61a8739c1a56038ccb0258f233ad646
      error "Windows support not added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      local DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Windows-x86_64.exe
      local DOWNLOAD_SHA256=c3a43d6bc4c4fa92454dbfa636ccb859a045d875df602b31ae71b9e0c3fec2b8
      error "Windows support not added yet"
    fi
  else
    info "Bypassing installation of Python 3 because the 'container' environment variable is set to 'docker'"
  fi
}

ensure_vagrant_installed() {
  if [ "$container" != 'docker' ]; then
    log "Checking whether Vagrant is already installed"
    local DOWNLOAD_DESTINATION=/tmp/megabytelabs/vagrant_linux.zip
    local DOWNLOAD_SHA256=6dced262e5001d96baf99cad4bf75c30ab1e04092c28bb18078f3f0db1123d2c
    local DOWNLOAD_URL=https://releases.hashicorp.com/vagrant/2.2.16/vagrant_2.2.16_linux_amd64.zip
    local TMP_DIR=/tmp/megabytelabs
    local USER_BIN_FOLDER="$HOME/.local/bin"
    if [ "$(uname)" == "Darwin" ]; then
      local BASH_PROFILE="$HOME/.bash_profile"
      if ! command_exists vagrant; then
        brew install --cask vagrant
      else
        info "Vagrant is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      local BASH_PROFILE="$HOME/.bashrc"
      if ! command_exists vagrant; then
        info "Vagrant is not currently installed"
        mkdir -p $TMP_DIR
        mkdir -p "$USER_BIN_FOLDER"
        log "Downloading the Vagrant binary"
        wget $DOWNLOAD_URL -O $DOWNLOAD_DESTINATION
        sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
        log "SHA256 checksum validated successfully"
        log "Installing Vagrant"
        unzip "$DOWNLOAD_DESTINATION" -d "$TMP_DIR"
        mv "$TMP_DIR/vagrant" "$HOME/.local/bin/vagrant"
        success "Successfully installed Vagrant to ~/.local/bin"
        rm "$DOWNLOAD_DESTINATION"
        export PATH="$USER_BIN_FOLDER:$PATH"
        # Check to see if the "export PATH" command is already present in ~/.bashrc
        if [[ $(grep -L 'export PATH=$HOME/.local/bin:$PATH' "$BASH_PROFILE") ]]; then
          echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >>$BASH_PROFILE
          success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
        else
          log "The ~/.local/bin folder is already included in the PATH variable"
        fi
      else
        info "Vagrant is already installed"
      fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      error "Windows support not added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      error "Windows support not added yet"
    fi
  else
    info "Bypassing installation of Vagrant because the 'container' environment variable is set to 'docker'"
  fi
}

missing_virtualization_platforms_notice() {
  if [ "$container" != 'docker' ]; then
    if [ "$(uname)" == "Darwin" ]; then
      if ! command_exists kvm; then
        warn "KVM is not currently installed on your computer."
        info "You can install KVM by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/kvm"
      fi
      if ! command_exists VBoxManage; then
        warn "VirtualBox is not currently installed on your computer."
        info "You can install VirtualBox by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/virtualbox"
      fi
      if ! command_exists vmrun; then
        warn "VMWare Fusion is not currently installed on your computer."
        info "You can install VMWare Fusion by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/vmware"
      fi
      if ! command_exists prlctl; then
        warn "Parallels is not currently installed on your computer."
        info "You can install Parallels by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/parallels"
      fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      if ! command_exists kvm; then
        warn "KVM is not currently installed on your computer."
        info "You can install KVM by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/kvm"
      fi
      if ! command_exists VBoxManage; then
        warn "VirtualBox is not currently installed on your computer."
        info "You can install VirtualBox by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/virtualbox"
      fi
      if ! command_exists vmware; then
        warn "VMWare is not currently installed on your computer."
        info "You can install VMWare by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/vmware"
      fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      info "Virtualization platform detection notice currently not available on Windows."
      # TODO Add same kind of check for all the above platforms except Parallels because its not available for Windows.
      # TODO Instead add detection for Hyper-V
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      info "Virtualization platform detection notice currently not available on Windows."
      # TODO Add same kind of check for all the above platforms except Parallels because its not available for Windows.
      # TODO Instead add detection for Hyper-V
    fi
  fi
}

##############################################
############### BUSINESS LOGIC ###############
##############################################

# Adds a test.sh file to the test folder in Dockerfile projects
# if the test folder exists
add_docker_test_script() {
  if [ -d test ]; then
    info "The test folder exists"
    log "Adding the common test.sh file to the test folder"
    cp ./.modules/$REPO_TYPE/test.sh ./test/test.sh
    log "Checking for presence of the 'docker_command' in .blueprint.json"
    local HAS_DOCKER_COMMAND=$(jq -e 'has("docker_command")' .blueprint.json)
    if [ "$HAS_DOCKER_COMMAND" != 'false' ]; then
      info "'docker_command' is present in the .blueprint.json file"
      local SLUG=$(jq -r '.slug' .blueprint.json)
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak 's^DOCKER_SLUG^'"${SLUG}"'^g' ./test/test.sh && rm ./test/test.sh.bak
      else
        sed -i 's^DOCKER_SLUG^'"${SLUG}"'^g' ./test/test.sh
      fi
      log "Injecting Docker slug name into ./test/test.sh"
      local COMMAND=$(jq -r '.docker_command' .blueprint.json)
      log "Injecting Docker command into ./test/test.sh"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak 's^DOCKER_COMMAND^'"${COMMAND}"'^g' ./test/test.sh && rm ./test/test.sh.bak
      else
        sed -i 's^DOCKER_COMMAND^'"${COMMAND}"'^g' ./test/test.sh
      fi
    else
      warn "The test folder exists but there is no 'docker_command' in .blueprint.json"
    fi
  fi
}

# Copies a file into the working directory for Dockerfiles that rely on
# the initctl polyfill
add_initctl() {
  log "Checking whether initctl needs to be copied to the project's root"
  if [ "$REPO_TYPE" == 'dockerfile' ]; then
    # Determine type of Dockerfile project
    local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
    if [ "$SUBGROUP" == 'ansible-molecule' ]; then
      # Copy initctl file if the Dockerfile is based on Ubuntu or Debian
      DOCKERFILE_FIRSTLINE=$(head -n 1 ./Dockerfile)
      if [[ "$DOCKERFILE_FIRSTLINE" == *"debian"* ]] || [[ "$DOCKERFILE_FIRSTLINE" == *"ubuntu"* ]]; then
        info "Debian-flavor OS specified in Dockerfile"
        log "Copying initctl to the project's root"
        cp ./.modules/dockerfile/initctl initctl
        success "Copied initctl file to the repository's root"
      else
        log "Project does not appear to be Debian-flavored so the initctl file is unnecessary"
      fi
    else
      log "Project is a Dockerfile project but does not need the initctl file"
    fi
  else
    log "Project is not a Dockerfile project so initctl is unnecessary"
  fi
}

# Ensures the Bento submodule is present
ensure_bento_submodule_latest() {
  if [ ! -d "./.modules/bento" ]; then
    log "Adding the chef/bento repository as a submodule"
    mkdir -p ./.modules
    git submodule add -b master https://github.com/chef/bento.git ./.modules/bento
    success "Successfully added the chef/bento submodule"
  else
    log "Updating the chef/bento submodule"
    cd ./.modules/bento
    git checkout master && git pull origin master --ff-only
    cd ../..
    success "Successfully updated the chef/bento submodule"
  fi
}

# Ensures the project's documentation partials submodule is added to the project
ensure_project_docs_submodule_latest() {
  if [ ! -d "./.modules/docs" ]; then
    log "Adding a new submodule for the documentation partials"
    mkdir -p ./.modules
    git submodule add -b master https://gitlab.com/megabyte-labs/documentation/$REPO_TYPE.git ./.modules/docs
    success "Successfully added the docs submodule"
  else
    log "Updating the documentation submodule"
    cd ./.modules/docs
    git checkout master && git pull origin master --ff-only
    cd ../..
    success "Successfully updated the docs submodule"
  fi
}

ensure_windows_submodule_latest() {
  log "Checking for presence of the Autounattend.xml file to add submodule for a Windows Packer project"
  if [ -f ./Autounattend.xml ]; then
    info "Project appears to be a Windows Packer project"
    if [ ! -d "./.modules/windows" ]; then
      log "Adding the packer-windows submodule"
      git submodule add -b main https://github.com/StefanScherer/packer-windows ./.modules/windows
      success "Successfully added the packer-windows submodule"
    else
      log "Updating the packer-windows submodule"
      cd ./.modules/windows
      git checkout main && git pull origin main --ff-only
      cd ../..
      success "Successfully updated the packer-windows submodule"
    fi
  fi
}

# TODO: Add ensure_wget_installed and make it so that it can be installed without sudo password

# Generate chart data used for documentation
generate_ansible_charts() {
  if [ "$REPO_TYPE" == 'ansible' ]; then
    if [ -f main.yml ]; then
      # Playbook
      npx @megabytelabs/ansibler --roles ./roles --output ./dependency-chart.json --base-url https://gitlab.com/megabyte-labs/ansible-roles --username professormanhattan --populate-descriptions
    fi
  fi
}

# Generates the README.md and CONTRIBUTING.md with documentation partials using
# the Node.js library @appnest/readme
generate_documentation() {
  # Assign README_FILE the appropriate value based on the repository type
  log "Detecting the appropriate README.md template file to use"
  local README_FILE=blueprint-readme.md
  if [ "$REPO_TYPE" == 'dockerfile' ]; then
    local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
    local HAS_DOCKERSLIM_COMMAND=$(jq -e 'has("dockerslim_command")' .blueprint.json)
    if [ "$SUBGROUP" == 'ansible-molecule' ]; then
      local README_FILE='blueprint-readme-ansible-molecule.md'
    elif [ "$SUBGROUP" == 'apps' ]; then
      local README_FILE='blueprint-readme-apps.md'
      if [ "$HAS_DOCKERSLIM_COMMAND" != 'false' ]; then
        local README_FILE='blueprint-readme-apps-slim.md'
      fi
    elif [ "$SUBGROUP" == 'ci-pipeline' ]; then
      local README_FILE='blueprint-readme-ci.md'
      log "Determing whether dockerslim_command is available in .blueprint.json"
      if [ "$HAS_DOCKERSLIM_COMMAND" != 'false' ]; then
        local README_FILE='blueprint-readme-ci-slim.md'
      fi
    elif [ "$SUBGROUP" == 'software' ]; then
      local README_FILE='blueprint-readme-software.md'
      if [ "$HAS_DOCKERSLIM_COMMAND" != 'false' ]; then
        local README_FILE='blueprint-readme-software-slim.md'
      fi
    fi
  elif [ "$REPO_TYPE" == 'ansible' ]; then
    if [ -f ./main.yml ]; then
      README_FILE=blueprint-readme-playbooks.md
    fi
  fi
  if [ "$REPO_TYPE" == 'packer' ]; then
    jq -s '.[0] * .[1] * .[2]' template.json ./.modules/docs/common.json .blueprint.json >__bp.json
  else
    jq -s '.[0] * .[1]' .blueprint.json ./.modules/docs/common.json >__bp.json
  fi
  log "Generating the CONTRIBUTING.md file"
  npx -y @appnest/readme generate --config __bp.json --input ./.modules/docs/blueprint-contributing.md --output CONTRIBUTING.md
  npx prettier --write CONTRIBUTING.md
  success "Successfully generated the CONTRIBUTING.md file"
  log "Generating the README.md file"
  if [ "$REPO_TYPE" == 'ansible' ] && [ ! -f main.yml ]; then
    info "Project type appears to be an Ansible role"
    log "Generating partials using mod-ansible-autodoc"
    if ! command_exists mod-ansible-autodoc; then
      info "mod-ansible-autodoc does not appear to be installed"
      log "Installing mod-ansible-autodoc"
      pip3 install mod-ansible-autodoc
    fi
    mod-ansible-autodoc --todo-title "### TODO" --actions-title "## Features" --tags-title "### Tags" --variables-title "## Variables"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak -r 's/^####(.*):$/###\1/g' ansible_actions.md && rm ansible_actions.md.bak
    else
      sed -i -r 's/^####(.*):$/###\1/g' ansible_actions.md
    fi
    local BLANK_VARIABLES_FILE_CONTENTS='""'
    local VARIABLES_FILE_CONTENTS=$(cat ansible_variables.json)
    if [ "$VARIABLES_FILE_CONTENTS" != "$BLANK_VARIABLES_FILE_CONTENTS" ]; then
      # Variables file contents is not empty
      info "There are variables present"
      local VARIABLES_CONTENT='## Variables\n\nThis role contains variables that you can customize. The variables you can customize are located in `defaults/main.yml`. By default, the variables use sensible defaults but you may want to customize the role depending on your use case. The variables, along with descriptions and examples, are listed in the chart below:\n\n{{ ansible_variables }}\n\n'
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak 's^## Variables^'"$VARIABLES_CONTENT"'^g' ansible_variables.md && rm ansible_variables.md.bak
      else
        sed -i 's^## Variables^'"$VARIABLES_CONTENT"'^g' README.md
      fi
      ROLE_VARIABLES=$(jq -r '.role_variables' ansible_variables.json)
      jq --arg a "${ROLE_VARIABLES}" '.role_variables = $a' __bp.json > __jq.json && mv __jq.json __bp.json
    fi
  fi
  if [ -f dependency-chart.json ]; then
    local ROLE_DEPENDENCIES=$(jq -r '.role_dependencies' dependency-chart.json)
    jq --arg a "${ROLE_DEPENDENCIES}" '.role_dependencies = $a' __bp.json > __jq.json && mv __jq.json __bp.json
  fi
  npx -y @appnest/readme generate --config __bp.json --input ./.modules/docs/$README_FILE
  npx prettier --write README.md
  success "Successfully generated the README.md file"
  rm -f __bp.json ansible_actions.md ansible_tags.md ansible_todo.md ansible_variables.md ansible_variables.json dependency-chart.json

  # Remove formatting error
  # log "Fixing a quirk in the README.md and CONTRIBUTING.md files"
  # sed -i .bak 's/](#-/](#/g' README.md && rm README.md.bak
  # sed -i .bak 's/](#-/](#/g' CONTRIBUTING.md && rm CONTRIBUTING.md.bak
  # success "Successfully updated the README.md and CONTRIBUTING files"

  # Inject DockerSlim build command into README.md for ci-pipeline projects
  log "Determining whether anything needs to be injected into the README.md file"
  if [ "$REPO_TYPE" == 'dockerfile' ]; then
    local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
    if [ "$SUBGROUP" == "ci-pipeline" ]; then
      log "Injecting a DockerSlim command from the package.json into the README.md"
      local PACKAGE_SLIM_BUILD=$(jq -r '.dockerslim_command' .blueprint.json | sed 's/\\//g')
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak 's^DOCKER_SLIM_BUILD_COMMAND^'"${PACKAGE_SLIM_BUILD}"'^g' README.md && rm README.md.bak
      else
        sed -i 's^DOCKER_SLIM_BUILD_COMMAND^'"${PACKAGE_SLIM_BUILD}"'^g' README.md
      fi
      success "Successfully updated the README.md with the DockerSlim command"
    else
      log "Project is a Dockerfile project but no changes to the README.md are necessary"
    fi
  else
    log "No change to the README.md necessary"
  fi
}

install_requirements() {
  if [ "$container" != 'docker' ]; then
    # Install Python 3 requirements if requirements.txt is present
    if [ -f requirements.txt ]; then
      pip3 install -r requirements.txt
    fi

    # Install Ansible Galaxy requirements if requirements.yml is present
    if [ -f requirements.yml ]; then
      ansible-galaxy install -r requirements.yml --ignore-errors
    fi
  else
    info "Bypassing installation of project requirements because the 'container' environment variable is set to 'docker'"
  fi
}

copy_playbook_files() {
  cp -Rf ./.modules/$REPO_TYPE/files/.gitlab . # TODO: Figure out how to combine these copy statements
  cp -Rf ./.modules/$REPO_TYPE/files/.husky .
  cp -Rf ./.modules/$REPO_TYPE/files/.vscode .
  cp ./.modules/$REPO_TYPE/files/.ansible-lint .ansible-lint
  cp ./.modules/$REPO_TYPE/files/.gitignore .gitignore
  cp ./.modules/$REPO_TYPE/files/.gitlab-ci.yml .gitlab-ci.yml
  cp ./.modules/$REPO_TYPE/files/LICENSE LICENSE
  cp ./.modules/$REPO_TYPE/playbook-files/package.json package.json
  cp ./.modules/$REPO_TYPE/files/requirements.txt requirements.txt
  cp -Rf ./.modules/$REPO_TYPE/playbook-files/. .
}

# Updates package.json
copy_project_files_and_generate_package_json() {
  # Prepare common Ansible files for copying over
  if [ "$REPO_TYPE" == 'ansible' ] && [ ! -f ./main.yml ]; then
    # Replace the role_name placeholder with the repository folder name
    log "Injecting the Ansible submodule with the appropriate role folder name variable"
    local ROLE_FOLDER=$(basename "$PWD")
    if [[ "$OSTYPE" == "darwin"* ]]; then
      grep -rl 'MEGABYTE_ROLE_PLACEHOLDER' ./.modules/$REPO_TYPE/files | xargs sed -i .bak "s/MEGABYTE_ROLE_PLACEHOLDER/${ROLE_FOLDER}/g"
      find ./.modules/$REPO_TYPE/files -name "*.bak" -type f -delete
    else
      grep -rl 'MEGABYTE_ROLE_PLACEHOLDER' ./.modules/$REPO_TYPE/files | xargs sed -i "s/MEGABYTE_ROLE_PLACEHOLDER/${ROLE_FOLDER}/g"
    fi
  fi

  # Copy files over from the Dockerfile shared submodule
  if [ -f ./package.json ]; then
    # Retain information from package.json
    log "Backing up the package.json name and version"
    local PACKAGE_NAME=$(jq -r '.slug' .blueprint.json)
    if [ "$REPO_TYPE" == 'ansible' ]; then
      local PACKAGE_NAME=$(jq -r '.role_name' .blueprint.json)
    fi
    local PACKAGE_VERSION=$(jq -r '.version' package.json)
    if [ "$REPO_TYPE" == 'dockerfile' ]; then
      local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
      # The ansible-molecule subgroup does not store its template in .blueprint.json so it is retained
      if [ "$SUBGROUP" == "ansible-molecule" ]; then
        log "Backing up the package.json description"
        local PACKAGE_DESCRIPTION=$(jq -r '.description' package.json)
      fi
    elif [ "$REPO_TYPE" == 'ansible' ]; then
      local PACKAGE_DESCRIPTION=$(jq -r '.role_description' .blueprint.json)
    elif [ "$REPO_TYPE" == 'packer' ] || [ "$REPO_TYPE" == 'npm' ]; then
      log "Backing up the package.json description"
      local PACKAGE_DESCRIPTION=$(jq -r '.description' package.json)
    fi
    if [ "$REPO_TYPE" == 'npm' ]; then
      local PACKAGE_DEPS=$(jq -r '.dependencies' package.json)
      # Inherit versions from common NPM package.json devDependencies
      local PACKAGE_DEVDEPS=$(jq -s '.[0].devDependencies * .[1].devDependencies | .' package.json ./.modules/$REPO_TYPE/files/package.json)
    fi
    warn "Copying the $REPO_TYPE common files into the repository - this may overwrite changes to files managed by the common repository. For more information please see the CONTRIBUTING.md document."
    if [ "$REPO_TYPE" == 'ansible' ] && [ -f ./main.yml ]; then
      copy_playbook_files
    else
      cp -Rf ./.modules/$REPO_TYPE/files/. .

      # Reset ./.modules/ansible if appropriate
      if [ "$REPO_TYPE" == 'ansible' ] && [ ! -f ./main.yml ]; then
        log "Resetting Ansible submodule to HEAD"
        cd ./.modules/ansible
        git reset --hard HEAD
        cd ../..
      fi
    fi
    log "Injecting package.json with the saved name and version"
    local PACKAGE_NAME_PREFIX=""
    if [ "$REPO_TYPE" == 'ansible' ]; then
      if [ ! -f main.yml ]; then
        # No main.yml file so this must be an Ansible role
        local PACKAGE_NAME_PREFIX=ansible-
      fi
    elif [ "$REPO_TYPE" == 'dockerfile' ]; then
      local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
      if [ "$SUBGROUP" == 'ansible-molecule' ]; then
        local PACKAGE_NAME_PREFIX=docker-ansible-molecule-
      else
        local PACKAGE_NAME_PREFIX=docker-
      fi
    elif [ "$REPO_TYPE" == 'packer' ]; then
      local PACKAGE_NAME_PREFIX=packer-
    elif [ "$REPO_TYPE" == 'python' ]; then
      local PACKAGE_NAME_PREFIX=python-
    fi
    jq --arg a "@megabytelabs/${PACKAGE_NAME_PREFIX}${PACKAGE_NAME}" '.name = $a' package.json >__jq.json && mv __jq.json package.json
    jq --arg a "${PACKAGE_VERSION//\//}" '.version = $a' package.json >__jq.json && mv __jq.json package.json
    if [ "$REPO_TYPE" == 'dockerfile' ] && [ "$SUBGROUP" == 'ansible-molecule' ]; then
      log "Injecting package.json with the saved description"
      jq --arg a "${PACKAGE_DESCRIPTION//\//}" '.description = $a' package.json >__jq.json && mv __jq.json package.json
    elif [ "$REPO_TYPE" == 'ansible' ] || [ "$REPO_TYPE" == 'packer' ] || [ "$REPO_TYPE" == 'npm' ]; then
      log "Injecting package.json with the saved description"
      jq --arg a "${PACKAGE_DESCRIPTION//\//}" '.description = $a' package.json >__jq.json && mv __jq.json package.json
    fi
    if [ "$REPO_TYPE" == 'npm' ]; then
      log "Injecting dependencies and devDependencies back into package.json"
      jq --argjson a "${PACKAGE_DEPS}" '.dependencies = $a' package.json >__jq.json && mv __jq.json package.json
      jq --argjson a "${PACKAGE_DEVDEPS}" '.devDependencies = $a' package.json >__jq.json && mv __jq.json package.json
      if [ -f .blueprint.json ]; then
        log "Injecting slug/name from .blueprint.json into package.json"
        local PROJECT_SLUG=$(jq -r '.slug' .blueprint.json)
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i .bak 's^PROJECT_SLUG^'"${PROJECT_SLUG}"'^g' package.json && rm package.json.bak
        else
          sed -i 's^PROJECT_SLUG^'"${PROJECT_SLUG}"'^g' package.json
        fi
      else
        warn "Project is missing a .blueprint.json file. Please populate it, following the same format as another NPM package project that has a .blueprint.json file"
      fi
    fi
    success "Successfully updated the package.json file and copied the shared $REPO_TYPE files into this repository"
  else
    info "Repository appears to be a new project - it does not have a package.json file"
    if [ "$REPO_TYPE" == 'ansible' ] && [ -f main.yml ]; then
      # The project type is an Ansible playbook
      log "Copying Ansible Playbook files since the main.yml file is present in the root directory"
      copy_playbook_files
    else
      log "Copying base files from the common $REPO_TYPE repository"
      cp -Rf ./.modules/$REPO_TYPE/files/ .
      if [ "$REPO_TYPE" == 'dockerfile' ] && [ "$SUBGROUP" == 'ci-pipeline' ]; then
        log "Injecting the package.json name variable with the slug variable from .blueprint.json"
        local PACKAGE_NAME=$(jq -r '.slug' .blueprint.json)
        jq --arg a "@megabytelabs/${PACKAGE_NAME}" '.name = $a' package.json >__jq.json && mv __jq.json package.json
        success "Successfully initialized the project with the shared $REPO_TYPE files and updated the name in package.json"
      elif [ "$REPO_TYPE" == 'npm' ]; then
        if [ -f .blueprint.json ]; then
          log "Injecting slug/name from .blueprint.json into package.json"
          local PROJECT_SLUG=$(jq -r '.slug' .blueprint.json)
          if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i .bak 's^PROJECT_SLUG^'"${PROJECT_SLUG}"'^g' package.json && rm package.json.bak
          else
            sed -i 's^PROJECT_SLUG^'"${PROJECT_SLUG}"'^g' package.json
          fi

        else
          warn "Project is missing a .blueprint.json file. Please populate it, following the same format as another NPM package project that has a .blueprint.json file"
        fi
      fi
    fi
  fi

  # Run dockerfile-subgroup specific tasks
  if [ "$REPO_TYPE" == 'dockerfile' ]; then
    log "Determing whether dockerslim_command is available in .blueprint.json"
    local HAS_DOCKERSLIM_COMMAND=$(jq -e 'has("dockerslim_command")' .blueprint.json)
    if [ "$HAS_DOCKERSLIM_COMMAND" != 'false' ]; then
      info "The dockerslim_command is present in the .blueprint.json file"
      # Ensures the scripts.build:slim value matches the value in .blueprint.json
      log "Ensuring the 'build:slim' variable in package.json is updated"
      local DOCKERSLIM_COMMAND=$(jq -r '.dockerslim_command' .blueprint.json)
      log "Replacing the placeholder in package.json with the variable from .blueprint.json"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak "s^DOCKER_SLIM_COMMAND_HERE^${DOCKERSLIM_COMMAND}^g" package.json && rm package.json.bak
      else
        sed -i "s^DOCKER_SLIM_COMMAND_HERE^${DOCKERSLIM_COMMAND}^g" package.json
      fi
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak "s^DOCKER_SLIM_COMMAND_HERE^\&^g" package.json && rm package.json.bak
      else
        sed -i "s^DOCKER_SLIM_COMMAND_HERE^\&^g" package.json
      fi
      success "Successfully ensured that the right 'build:slim' value is included in package.json"
    else
      info "The dockerslim_command is not present in the .blueprint.json file"
      log "Removing DockerSlim-specific tasks in package.json"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak '/build:slim/d' package.json && rm package.json.bak
        sed -i .bak '/publish:publish-slim/d' package.json && rm package.json.bak
        sed -i .bak '/scan:slim/d' package.json && rm package.json.bak
        sed -i .bak '/shell:slim/d' package.json && rm package.json.bak
      else
        sed -i '/build:slim/d' package.json
        sed -i '/publish:publish-slim/d' package.json
        sed -i '/scan:slim/d' package.json
        sed -i '/shell:slim/d' package.json
      fi
      success "Removed DockerSlim-specific package.json scripts since there is no dockerslim_command specified in .blueprint.json"
    fi

    # Remove the test:unit script if there is no test folder present
    log "Detecting presence of the test folder in the root of the project"
    if [ ! -d ./test ]; then
      warn "The test folder is not present in the root of this project. If this is by design then you can ignore this. However, if it is not by design then please read the README.md and CONTRIBUTING.md and add a test case."
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i .bak '/test:unit/d' package.json && rm package.json.bak
      else
        sed -i '/test:unit/d' package.json
      fi
      success "Successfully removed the scripts.test:unit test step from package.json"
    else
      info "The test folder is present in the root of this project so the scripts.test:unit script in package.json is being left as is"
    fi
    # Copies name value from package.json to other locations that should match the string
    log "Performing tasks specific to Dockerfile projects"
    log "Replacing all instances of the string 'dockerfile-project' in package.json with the package.json name"
    local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
    if [ "$SUBGROUP" == "ansible-molecule" ]; then
      local PACKAGE_NAME_PREFIX="ansible-molecule-"
    fi
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak "s^dockerfile-project^${PACKAGE_NAME_PREFIX}${PACKAGE_NAME}^g" package.json && rm package.json.bak
    else
      sed -i "s^dockerfile-project^${PACKAGE_NAME_PREFIX}${PACKAGE_NAME}^g" package.json
    fi
    success "Successfully updated the 'dockerfile-project' string to the package.json name"

    # Updates the description from .blueprint.json
    local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
    if ([ "$SUBGROUP" == 'ci-pipeline' ] || [ "$SUBGROUP" == 'ansible-molecule' ]) && [ "$container" != 'docker' ]; then
      log "Ensuring the package.json description is updated, using a value specified in .blueprint.json"
      local DESCRIPTION_TEMPLATE=$(jq -r '.description_template' .blueprint.json)
      jq --arg a "${DESCRIPTION_TEMPLATE}" '.description = $a' package.json >__jq.json && mv __jq.json package.json
      success "Successfully copied the .blueprint.json description to the package.json description"
      local SLUG=$(jq -r '.slug' .blueprint.json)
      local CONTAINER_STATUS=$(docker images -q megabytelabs/${SLUG}:slim)
      if [[ -n "$CONTAINER_STATUS" ]]; then
        info ":slim image appears to have already been built"
        log "Injecting container size information into package.json description"
        local PACKAGE_NAME=$(jq -r '.slug' .blueprint.json)
        local COMPRESSED_SIZE=$(docker manifest inspect -v "megabytelabs/$PACKAGE_NAME:slim" | grep size | awk -F ':' '{sum+=$NF} END {print sum}' | awk '{$1=$1/(1024^2); print $1,"MB";}')
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i .bak "s^IMAGE_SIZE_PLACEHOLDER^ \(only ${COMPRESSED_SIZE} compressed!)^g" package.json && rm package.json.bak
        else
          sed -i "s^IMAGE_SIZE_PLACEHOLDER^ \(only ${COMPRESSED_SIZE} compressed!)^g" package.json
        fi
        success "Successfully injected image size information into package.json description"
      else
        # Container does not exist
        info ":slim container does not appear to be built yet"
        if [ -f slim.report.json ]; then
          info "A DockerSlim report is present in this repository"
          log "Injecting the package.json description with the container file size detailed in slim.report.json"
          local SLIM_IMAGE_SIZE=$(jq -r '.minified_image_size_human' slim.report.json)
          if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i .bak "s^IMAGE_SIZE_PLACEHOLDER^ \(only ${SLIM_IMAGE_SIZE}!)^g" package.json && rm package.json.bak
          else
            sed -i "s^IMAGE_SIZE_PLACEHOLDER^ \(only ${SLIM_IMAGE_SIZE}!)^g" package.json
          fi
          success "Successfully added the container file size to the package.json description"
        else
          info "The slim.report.json file appears to be missing from this repository"
          log "Removing the container file size placeholder from the description in package.json"
          if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i .bak "s^IMAGE_SIZE_PLACEHOLDER^^g" package.json && rm package.json.bak
          else
            sed -i "s^IMAGE_SIZE_PLACEHOLDER^^g" package.json
          fi
          success "Successfully removed the container file size placeholder from the description in package.json"
        fi
      fi
    fi
  fi
  log "Ensuring the package.json file is Prettier-compliant"
  npx prettier-package-json --write
  success "Successfully ensured that the package.json file is Prettier-compliant"
}

generate_vagrantfile() {
  log "Generating Vagrantfile"
  local OS_BOX_BASENAME=$(jq -r '.variables.box_basename' template.json)
  local OS_DESCRIPTION=$(jq -r '.variables.description' template.json)
  local OS_HOSTNAME=$(jq -r '.hostname' .blueprint.json)
  local OS_TAG=$(jq -r '.vagrant_tag' .blueprint.json)
  local VAGRANTUP_USER=$(jq -r '.variables.vagrantup_user' template.json)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i .bak "s^OS_BOX_BASENAME^${OS_BOX_BASENAME}^g" Vagrantfile && rm Vagrantfile.bak
    sed -i .bak "s^OS_DESCRIPTION^${OS_DESCRIPTION}^g" Vagrantfile && rm Vagrantfile.bak
    sed -i .bak "s^OS_HOSTNAME^${OS_HOSTNAME}^g" Vagrantfile && rm Vagrantfile.bak
    sed -i .bak "s^OS_TAG^${OS_TAG}^g" Vagrantfile && rm Vagrantfile.bak
    sed -i .bak "s^VAGRANTUP_USER^${VAGRANTUP_USER}^g" Vagrantfile && rm Vagrantfile.bak
  else
    sed -i "s^OS_BOX_BASENAME^${OS_BOX_BASENAME}^g" Vagrantfile
    sed -i "s^OS_DESCRIPTION^${OS_DESCRIPTION}^g" Vagrantfile
    sed -i "s^OS_HOSTNAME^${OS_HOSTNAME}^g" Vagrantfile
    sed -i "s^OS_TAG^${OS_TAG}^g" Vagrantfile
    sed -i "s^VAGRANTUP_USER^${VAGRANTUP_USER}^g" Vagrantfile
  fi
  success "Generated Vagrantfile"
}

# Miscellaneous fixes
misc_fixes() {
  # Ensure .blueprint.json is using Prettier formatting
  if [ -f .blueprint.json ]; then
    log "Ensuring .blueprint.json is properly formatted"
    npx prettier --write .blueprint.json
    success ".blueprint.json is Prettier-compliant"
  fi
  # Ensure slim.report.json is using Prettier formatting
  if [ -f slim.report.json ]; then
    log "Ensuring the slim.report.json is properly formatted"
    npx prettier --write slim.report.json
    success "slim.report.json is Prettier-compliant"
  fi
  # Ensure pre-commit hook is executable
  if [ -f .husky/pre-commit ]; then
    log "Ensuring the Husky pre-commit hook is executable"
    chmod 755 .husky/pre-commit
    success "The Husky pre-commit has the correct file permissions"
  fi
  # Ensure paths.txt is in alphabetical order
  if [ -f paths.txt ]; then
    log "Ensuring paths.txt is in alphabetical order"
    sort paths.txt -o paths.txt
    success "paths.txt is in alphabetical order"
  fi
  # Ensure requirements.txt is in alphabetical order
  if [ -f requirements.txt ]; then
    log "Ensuring requirements.txt is in alphabetical order"
    sort requirements.txt -o requirements.txt
    success "requirements.txt is in alphabetical order"
  fi
  # Ensure Ansible Galaxy project ID is injected into .blueprint.json if project is a Ansible role
  if [ "$REPO_TYPE" == 'ansible' ] && [ -d molecule ] && [ ! -f main.yml ]; then
    info "Project appears to be an Ansible role"
    log "Injecting role name into package.json for Docker shell scripts"
    local ROLE_NAME=$(jq -r '.role_name' .blueprint.json)
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak "s^ANSIBLE_ROLE_NAME^${ROLE_NAME}^g" package.json && rm package.json.bak
    else
      sed -i "s^ANSIBLE_ROLE_NAME^${ROLE_NAME}^g" package.json
    fi
    log "Ensuring project ID is injected into .blueprint.json"
    local HAS_PROJECT_ID=$(jq -e 'has("ansible_galaxy_project_id")' .blueprint.json)
    if [ "$HAS_PROJECT_ID" != 'true' ]; then
      info "Project ID is absent from .blueprint.json"
      log "Acquiring project ID and injecting it into .blueprint.json"
      local PROJECT_ID=$(ansible-galaxy info "professormanhattan.${ROLE_NAME}" | grep -E 'id: [0-9]' | awk {'print $2'})
      if [ "$PROJECT_ID" ]; then
        jq --arg a "${PROJECT_ID}" '.ansible_galaxy_project_id = $a' .blueprint.json >__jq.json && mv __jq.json .blueprint.json
        success "Successfully acquired the project ID for professormanhattan.${ROLE_NAME} and added it to .blueprint.json"
      else
        warn "The professormanhattan.${ROLE_NAME} role does not appear to be on Ansible Galaxy"
      fi
    else
      info "Project ID is already present in .blueprint.json"
    fi
  fi
  if [ -d node_modules ]; then
    info "node_modules folder is present"
    log "Running npm audit fix to ensure there are no vulnerabilities"
    npm audit fix || true
    success "Ran npm audit fix"
  fi
}

populate_alternative_descriptions() {
  if [ "$REPO_TYPE" == 'ansible' ] && [ ! -f main.yml ]; then
    # Repository is type ansible and does not have a main.yml file so it must be a role
    # Read the description from meta/main.yml
    if command_exists yq; then
      log "Generating role descriptions"
      local DESCRIPTION=$(yq e '.galaxy_info.description' meta/main.yml)
      local LOWERCASE_DESCRIPTION=`echo ${DESCRIPTION:0:1} | tr '[A-Z]' '[a-z]'`${DESCRIPTION:1}
      local BLUEPRINT_DESCRIPTION="An Ansible role that ${LOWERCASE_DESCRIPTION}"
      local ALT_DESCRIPTION="This repository is the home of an Ansible role that ${LOWERCASE_DESCRIPTION}."
      log "Writing alternative role descriptions to .blueprint.json"
      jq --arg a "${BLUEPRINT_DESCRIPTION}" '.role_description = $a' .blueprint.json >__jq.json && mv __jq.json .blueprint.json
      jq --arg a "${ALT_DESCRIPTION}" '.role_description_alt = $a' .blueprint.json >__jq.json && mv __jq.json .blueprint.json
      success "Successfully populated .blueprint.json with alternative role descriptions"
    else
      warn "yq is not installed. Skipping logic that populates .blueprint.json with alternative description formats."
    fi
  fi
}

populate_common_missing_ansible_dependencies() {
  if [ ! -f main.yml ]; then
    info "Project type appears to be an Ansible role"
    info "Attempting to automatically populate common role and collection dependencies"
    log "Ensuring chocolatey.chocolatey collection is in requirements (if necessary)"
    local CHOCO_REFS=$(grep -Ril "chocolatey.chocolatey" ./tasks)
    if [ "$CHOCO_REFS" ]; then
      local CHOCO_REQS_REFS=$(yq eval '.collections' requirements.yml)
      if [[ ! $CHOCO_REQS_REFS =~ "chocolatey.chocolatey" ]]; then
        yq eval -i -P '.collections = .collections + {"name": "chocolatey.chocolatey", "source": "https://galaxy.ansible.com"}' requirements.yml
        (echo "---" && cat requirements.yml) > _reqs.yml && mv _reqs.yml requirements.yml
      fi
    fi
    log "Ensuring community.general collection is in meta requirements (if necessary)"
    local COMMUNITY_REFS=$(grep -Ril "community.general" ./tasks)
    if [ "$COMMUNITY_REFS" ]; then
      local COMMUNITY_REQ_REFS=$(yq eval '.collections' requirements.yml)
      if [[ ! $COMMUNITY_REQ_REFS =~ "community.general" ]]; then
        yq eval -i -P '.collections = .collections + {"name": "community.general", "source": "https://galaxy.ansible.com"}' requirements.yml
        (echo "---" && cat requirements.yml) > _reqs.yml && mv _reqs.yml requirements.yml
      fi
    fi
    log "Ensuring professormanhattan.homebrew role is in meta requirements (if necessary)"
    local HOMEBREW_REFS=$(grep -Ril "community.general.homebrew" ./tasks)
    if [ "$HOMEBREW_REFS" ]; then
      local HOMEBREW_META_REFS=$(yq eval '.dependencies' meta/main.yml)
      if [[ ! $HOMEBREW_META_REFS =~ "professormanhattan.homebrew" ]]; then
        yq eval -i -P '.dependencies = .dependencies + {"role": "professormanhattan.homebrew", "when": "ansible_os_family == \"Darwin\""}' meta/main.yml
        (echo "---" && cat meta/main.yml) > _meta_dash.yml && mv _meta_dash.yml meta/main.yml
      fi
    fi
    log "Ensuring professormanhattan.nodejs role is in meta requirements (if necessary)"
    local NODEJS_REFS=$(grep -Ril "community.general.npm" ./tasks)
    if [ "$NODEJS_REFS" ]; then
      local NODEJS_META_REFS=$(yq eval '.dependencies' meta/main.yml)
      if [[ ! $NODEJS_META_REFS =~ "professormanhattan.nodejs" ]]; then
        yq eval -i -P '.dependencies = .dependencies + {"role": "professormanhattan.nodejs"}' meta/main.yml
        (echo "---" && cat meta/main.yml) > _meta_dash.yml && mv _meta_dash.yml meta/main.yml
      fi
    fi
    log "Ensuring professormanhattan.ruby role is in meta requirements (if necessary)"
    local RUBY_REFS=$(grep -Ril "community.general.gem" ./tasks)
    if [ "$RUBY_REFS" ]; then
      local RUBY_META_REFS=$(yq eval '.dependencies' meta/main.yml)
      if [[ ! $RUBY_META_REFS =~ "professormanhattan.ruby" ]]; then
        yq eval -i -P '.dependencies = .dependencies + {"role": "professormanhattan.ruby"}' meta/main.yml
        (echo "---" && cat meta/main.yml) > _meta_dash.yml && mv _meta_dash.yml meta/main.yml
      fi
    fi
    log "Ensuring professormanhattan.snapd role is in meta requirements (if necessary)"
    local SNAPD_REFS=$(grep -Ril "community.general.snap" ./tasks)
    if [ "$SNAPD_REFS" ]; then
      local SNAPD_META_REFS=$(yq eval '.dependencies' meta/main.yml)
      if [[ ! $SNAPD_META_REFS =~ "professormanhattan.snapd" ]]; then
        # If role is the snapd role, then skip it
        local SNAPD_ROLE_INDICATOR=$(grep -Ril "role_name: snapd" ./meta/main.yml)
        if [ ! "$SNAPD_ROLE_INDICATOR" ]; then
          yq eval -i -P '.dependencies = .dependencies + {"role": "professormanhattan.snapd", "when": "ansible_os_family == \"Darwin\""}' meta/main.yml
          (echo "---" && cat meta/main.yml) > _meta_dash.yml && mv _meta_dash.yml meta/main.yml
        fi
      fi
    fi
    log "Ensuring all the dependencies in meta/main.yml are also in the requirements.yml file"
    yq eval -j '.dependencies' meta/main.yml > _meta-deps.json
    local REQ_REFS=$(yq eval '.roles' requirements.yml)
    jq -rc '.[] .role' _meta-deps.json | while read ROLE_NAME; do
      if [[ ! $REQ_REFS =~ $ROLE_NAME ]]; then
        ROLE_NAME=$ROLE_NAME yq eval -i -P '.roles = .roles + {"name": env(ROLE_NAME)}' requirements.yml
        (echo "---" && cat requirements.yml) > _reqs.yml && mv _reqs.yml requirements.yml
      fi
    done
    rm _meta-deps.json
    success "Successfully ensured common dependencies were populated"
  fi
}

populate_packer_descriptions() {
  # Ensure description is populated
  if [ "$REPO_TYPE" == 'packer' ]; then
    log "Injecting description in template.json"
    local ISO_VERSION=$(jq -r '.variables.iso_version' template.json)
    local MAJOR_VERSION=$(cut -d '.' -f 1 <<< $ISO_VERSION)
    local MINOR_VERSION=$(cut -d '.' -f 2 <<< $ISO_VERSION)
    local DESCRIPTION_TEMPLATE=$(jq -r '.description_template' .blueprint.json)
    local DESCRIPTION_TEMPLATE_PACKAGE=$(jq -r '.description_template_package' .blueprint.json)
    local VERSION_DESCRIPTION=$(jq -r '.version_description' .blueprint.json)
    jq --arg a "${DESCRIPTION_TEMPLATE}" '.variables.description = $a' template.json >__jq.json && mv __jq.json template.json
    jq --arg a "${DESCRIPTION_TEMPLATE_PACKAGE}" '.description = $a' package.json >__jq.json && mv __jq.json package.json
    jq --arg a "${VERSION_DESCRIPTION}" '.variables.version_description = $a' template.json > __jq.json && mv __jq.json template.json
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak "s^MAJOR_VERSION^${MAJOR_VERSION}^g" template.json && rm template.json.bak
      sed -i .bak "s^MINOR_VERSION^${MINOR_VERSION}^g" template.json && rm template.json.bak
      sed -i .bak "s^ISO_VERSION^${ISO_VERSION}^g" template.json && rm template.json.bak
      sed -i .bak "s^MAJOR_VERSION^${MAJOR_VERSION}^g" package.json && rm package.json.bak
      sed -i .bak "s^MINOR_VERSION^${MINOR_VERSION}^g" package.json && rm package.json.bak
      sed -i .bak "s^ISO_VERSION^${ISO_VERSION}^g" package.json && rm package.json.bak
    else
      sed -i "s^MAJOR_VERSION^${MAJOR_VERSION}^g" template.json
      sed -i "s^MINOR_VERSION^${MINOR_VERSION}^g" template.json
      sed -i "s^ISO_VERSION^${ISO_VERSION}^g" template.json
      sed -i "s^MAJOR_VERSION^${MAJOR_VERSION}^g" package.json
      sed -i "s^MINOR_VERSION^${MINOR_VERSION}^g" package.json
      sed -i "s^ISO_VERSION^${ISO_VERSION}^g" package.json
    fi
    success "Populated the description in template.json"
    npx prettier --write template.json
  fi
}

remove_unused_packer_platforms() {
  log "Pruning references to build types in template.json that do not exist"
  # Hyper-V
  if ! grep -q '"type": "hyperv-iso"' template.json; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak '/SUPPORTED_OS_HYPERV/d' README.md && rm README.md.bak
      sed -i .bak '/\"build:hyperv\"/d' package.json && rm package.json.bak
    else
      sed -i '/SUPPORTED_OS_HYPERV/d' README.md
      sed -i '/\"build:hyperv\"/d' package.json
    fi
  fi

  # Parallels
  if ! grep -q '"type": "parallels-iso"' template.json; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak '/SUPPORTED_OS_PARALLELS/d' README.md && rm README.md.bak
      sed -i .bak '/\"build:parallels\"/d' package.json && rm package.json.bak
    else
      sed -i '/SUPPORTED_OS_PARALLELS/d' README.md
      sed -i '/\"build:parallels\"/d' package.json
    fi
  fi

  # QEMU/KVM
  if ! grep -q '"type": "qemu"' template.json; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak '/SUPPORTED_OS_KVM/d' README.md && rm README.md.bak
      sed -i .bak '/\"build:kvm\"/d' package.json && rm package.json.bak
    else
      sed -i '/SUPPORTED_OS_KVM/d' README.md
      sed -i '/\"build:kvm\"/d' package.json
    fi
  fi

  # VirtualBox
  if ! grep -q '"type": "virtualbox-iso"' template.json; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak '/SUPPORTED_OS_VIRTUALBOX/d' README.md && rm README.md.bak
      sed -i .bak '/\"build:virtualbox\"/d' package.json && rm package.json.bak
    else
      sed -i '/SUPPORTED_OS_VIRTUALBOX/d' README.md
      sed -i '/\"build:virtualbox\"/d' package.json
    fi
  fi

  # VMWare
  if ! grep -q '"type": "vmware-iso"' template.json; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i .bak '/SUPPORTED_OS_VMWARE/d' README.md && rm README.md.bak
      sed -i .bak '/\"build:vmware\"/d' package.json && rm package.json.bak
    else
      sed -i '/SUPPORTED_OS_VMWARE/d' README.md
      sed -i '/\"build:vmware\"/d' package.json
    fi
  fi
}

run_latestos() {
  if [ "$container" != 'docker' ]; then
    if ! command_exists latestos; then
      log "The pip package latestos is missing, installing it now.."
      pip3 install latestos
      success "latestos installed successfully"
    fi
    LATESTOS_TAG=$(jq -r '.vagrant_tag' .blueprint.json)
    if [ "$LATESTOS_TAG" != 'windows' ] && [ "$LATESTOS_TAG" != 'macos' ]; then
      log "Determining the latest OS information"
      latestos "$LATESTOS_TAG"
      success "Updated iso_url and iso_checksum to the latest version"
    fi
  fi
}

symlink_roles() {
  if [ "$REPO_TYPE" == 'ansible' ]; then
    if [ -f main.yml ]; then
      info "Project is an Ansible Playbook"
      log "Symlinking all of the roles in the roles folder to ~/.ansible/roles"
      find "$PWD/roles" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*' | while read -r ROLE_PATH
      do
        local ROLE_FOLDER=$(basename $ROLE_PATH)
        rm "$HOME/.ansible/roles/${ANSIBLE_GALAXY_USERNAME}.${ROLE_FOLDER}"
        ln -s "$ROLE_PATH" "$HOME/.ansible/roles/${ANSIBLE_GALAXY_USERNAME}.${ROLE_FOLDER}"
      done
    else
      info "Project is an Ansible role"
      log "Symlinking the current role to the local roles folder (~/.ansible/roles)"
      local ROLE_FOLDER=$(basename $PWD)
      rm -rf "$HOME/.ansible/roles/${ANSIBLE_GALAXY_USERNAME}.${ROLE_FOLDER}"
      ln -s "${PWD}" "$HOME/.ansible/roles/${ANSIBLE_GALAXY_USERNAME}.${ROLE_FOLDER}"
    fi
    success "Successfully generated symlink(s)"
  fi
}

update_docker_labels() {
  local DOCKERFILE_GROUP=https://gitlab.com/megabyte-labs/dockerfile
  local PACKAGE_DESCRIPTION=$(jq '.description' package.json)
  local SLUG=$(jq -r '.slug' .blueprint.json)
  local SUBGROUP=$(jq -r '.subgroup' .blueprint.json)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i .bak "s^.*org.opencontainers.image.description.*^LABEL org.opencontainers.image.description=${PACKAGE_DESCRIPTION}^g" Dockerfile && rm Dockerfile.bak
    sed -i .bak "s^.*org.opencontainers.image.documentation.*^LABEL org.opencontainers.image.documentation=\"${DOCKERFILE_GROUP}/${SUBGROUP}/${SLUG}/-/blob/master/README.md\"^g" Dockerfile && rm Dockerfile.bak
    sed -i .bak "s^.*org.opencontainers.image.source.*^LABEL org.opencontainers.image.source=\"${DOCKERFILE_GROUP}/${SUBGROUP}/${SLUG}.git\"^g" Dockerfile && rm Dockerfile.bak
  else
    sed -i "s^.*org.opencontainers.image.description.*^LABEL org.opencontainers.image.description=${PACKAGE_DESCRIPTION}^g" Dockerfile
    sed -i "s^.*org.opencontainers.image.documentation.*^LABEL org.opencontainers.image.documentation=\"${DOCKERFILE_GROUP}/${SUBGROUP}/${SLUG}/-/blob/master/README.md\"^g" Dockerfile
    sed -i "s^.*org.opencontainers.image.source.*^LABEL org.opencontainers.image.source=\"${DOCKERFILE_GROUP}/${SUBGROUP}/${SLUG}.git\"^g" Dockerfile
  fi
}
