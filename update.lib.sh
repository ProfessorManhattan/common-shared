#!/bin/bash

# This file houses all the shared functions used across various
# update.sh files which are used to synchronize common files
# across many different projects. It also includes various
# functions that perform maintenance tasks.

##############################################
############## COMMON FUNCTIONS ##############
##############################################

# Logs an error message
error () {
  run-func ./.modules/shared/log.js error "$1"
}

# Logs an info message
info () {
  run-func ./.modules/shared/log.js info "$1"
}

# Logs a regular log message
log () {
  run-func ./.modules/shared/log.js debug "$1"
}

# Logs a success message
success () {
  run-func ./.modules/shared/log.js success "$1"
}

# Logs a warning message
warn () {
  run-func ./.modules/shared/log.js warn "$1"
}

# Determines whether or not an executable is accessible
command_exists () {
    type "$1" &> /dev/null ;
}

# Verifies the SHA256 checksum of a file
# Usage: sha256 <file> <checksum>
sha256 () {
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
ensure_docker_pushrm_installed () {
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
}

# Ensures DockerSlim is installed. If it is not present, it is installed to ~/.local/bin for
# the current user
ensure_dockerslim_installed () {
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
            unzip $DOWNLOAD_DESTINATION
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
                echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >> $BASH_PROFILE
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
                echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >> $BASH_PROFILE
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
}

# Ensures jq is installed. If it is not present, it is installed to ~/.local/bin for
# the current user
ensure_jq_installed () {
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
                echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >> $BASH_PROFILE
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
                echo -e '\nexport PATH=$HOME/.local/bin:$PATH' >> $BASH_PROFILE
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
}

# Ensures Node.js is installed by using nvm
ensure_node_installed () {
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
    if ! command_exists run-func; then
      npm install -g run-func
      if [ "$NODE_INSTALLED" == true ]; then
        success "The latest version of Node.js has been successfully installed"
        info "The script will continue to use the latest version of Node.js but in order to use it yourself you will have to close/open the terminal"
        success "Successfully installed npm global dependency (run-func)"
      fi
    fi
}

ensure_python3_installed () {
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
          echo -e '\nexport PATH=$HOME/.local/miniconda/bin:$PATH' >> $BASH_PROFILE
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
          echo -e '\nexport PATH=$HOME/.local/miniconda/bin:$PATH' >> $BASH_PROFILE
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
}

missing_virtualization_platforms_notice () {
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
}

##############################################
############### BUSINESS LOGIC ###############
##############################################

# Copies a file into the working directory for Dockerfiles that rely on
# the initctl polyfill
add_initctl () {
    log "Checking whether initctl needs to be copied to the project's root"
    if [ "$REPO_TYPE" == 'dockerfile' ]; then
        # Determine type of Dockerfile project
        local SUBGROUP=$(cat .blueprint.json | jq '.subgroup' | cut -d '"' -f 2)
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
ensure_bento_submodule_latest () {
  if [ ! -d "./.modules/bento" ]; then
    log "Adding the chef/bento repository as a submodule"
    mkdir -p ./.modules
    git submodule add -b master https://github.com/chef/bento.git ./.modules/bento
    success "Successfully added the chef/bento submodule"
  else
    log "Updating the chef/bento submodule"
    cd ./.modules/bento
    git checkout master && git pull origin master
    cd ../..
    success "Successfully updated the chef/bento submodule"
  fi
}

# Ensures the project's documentation partials submodule is added to the project
ensure_project_docs_submodule_latest () {
    if [ ! -d "./.modules/docs" ]; then
        log "Adding a new submodule for the documentation partials"
        mkdir -p ./.modules
        git submodule add -b master https://gitlab.com/megabyte-space/documentation/$REPO_TYPE.git ./.modules/docs
        success "Successfully added the docs submodule"
    else
        log "Updating the documentation submodule"
        cd ./.modules/docs
        git checkout master && git pull origin master
        cd ../..
        success "Successfully updated the docs submodule"
    fi
}

ensure_windows_submodule_latest () {
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
      git checkout main && git pull origin main
      cd ../..
      success "Successfully updated the packer-windows submodule"
    fi
  fi
}

# TODO: Add ensure_wget_installed and make it so that it can be installed without sudo password

# Generates the README.md and CONTRIBUTING.md with documentation partials using
# the Node.js library @appnest/readme
generate_documentation () {
    # Assign README_FILE the appropriate value based on the repository type
    log "Detecting the appropriate README.md template file to use"
    local README_FILE=blueprint-readme.md
    if [ "$REPO_TYPE" == 'dockerfile' ]; then
        local SUBGROUP=$(cat .blueprint.json | jq '.subgroup' | cut -d '"' -f 2)
        if [ "$SUBGROUP" == 'ansible-molecule' ]; then
            local README_FILE='blueprint-readme-ansible-molecule.md'
        elif [ "$SUBGROUP" == 'apps' ]; then
            local README_FILE='blueprint-readme-apps.md'
        elif [ "$SUBGROUP" == 'ci-pipeline' ]; then
            local README_FILE='blueprint-readme-ci.md'
        elif [ "$SUBGROUP" == 'software' ]; then
            local README_FILE='blueprint-readme-software.md'
        fi
    elif [ "$REPO_TYPE" == 'ansible' ]; then
      if [ -f ./main.yml ]; then
        README_FILE=blueprint-readme-playbooks.md
      fi
    fi
    jq -s '.[0] * .[1]' .blueprint.json ./.modules/docs/common.json > __bp.json
    log "Generating the CONTRIBUTING.md file"
    npx -y @appnest/readme generate --config __bp.json --input ./.modules/docs/blueprint-contributing.md --output CONTRIBUTING.md
    success "Successfully generated the CONTRIBUTING.md file"
    log "Generating the README.md file"
    npx -y @appnest/readme generate --config __bp.json --input ./.modules/docs/$README_FILE
    success "Successfully generated the README.md file"
    rm __bp.json

    # Remove formatting error
    log "Fixing a quirk in the README.md and CONTRIBUTING.md files"
    sed -i .bak 's/](#-/](#/g' README.md && rm README.md.bak
    sed -i .bak 's/](#-/](#/g' CONTRIBUTING.md && rm CONTRIBUTING.md.bak
    success "Successfully updated the README.md and CONTRIBUTING files"

    # Inject DockerSlim build command into README.md for ci-pipeline projects
    log "Determining whether anything needs to be injected into the README.md file"
    if [ "$REPO_TYPE" == 'dockerfile' ]; then
        local SUBGROUP=$(cat .blueprint.json | jq '.subgroup' | cut -d '"' -f 2)
        if [ "$SUBGROUP" == "ci-pipeline" ]; then
            log "Injecting a DockerSlim command from the package.json into the README.md"
            local PACKAGE_SLIM_BUILD=$(cat package.json | jq '.scripts."build:slim"' | cut -d '"' -f 2)
            sed -i .bak "s^DOCKER_SLIM_BUILD_COMMAND^${PACKAGE_SLIM_BUILD}^g" README.md && rm README.md.bak
            success "Successfully updated the README.md with the DockerSlim command"
        else
          log "Project is a Dockerfile project but no changes to the README.md are necessary"
        fi
    else
      log "No changed to the README.md necessary"
    fi
}

install_requirements () {
  # Install Python 3 requirements if requirements.txt is present
  if [ -f requirements.txt ]; then
    pip3 install -r requirements.txt
  fi

  # Install Ansible Galaxy requirements if requirements.yml is present
  if [ -f requirements.yml ]; then
    ansible-galaxy install -r requirements.yml
  fi
}

# Updates package.json
copy_project_files_and_generate_package_json () {
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
        local PACKAGE_NAME=$(cat package.json | jq '.name' | cut -d '"' -f 2)
        local PACKAGE_VERSION=$(cat package.json | jq '.version' | cut -d '"' -f 2)
        if [ "$REPO_TYPE" == 'dockerfile' ]; then
            local SUBGROUP=$(cat .blueprint.json | jq '.subgroup' | cut -d '"' -f 2)
            # The ansible-molecule subgroup does not store its template in .blueprint.json so it is retained
            if [ "$SUBGROUP" == "ansible-molecule" ]; then
                log "Backing up the package.json description"
                local PACKAGE_DESCRIPTION=$(cat package.json | jq '.description' | cut -d '"' -f 2)
            fi
        elif [ "$REPO_TYPE" == 'ansible' ] || [ "$REPO_TYPE" == 'packer' ]; then
          log "Backing up the package.json description"
          local PACKAGE_DESCRIPTION=$(cat package.json | jq '.version' | cut -d '"' -f 2)
        fi
        warn "Copying the $REPO_TYPE common files into the repository - this may overwrite changes to files managed by the common repository. For more information please see the CONTRIBUTING.md document."
        if [ "$REPO_TYPE" == 'ansible' ] && [ -f ./main.yml ]; then
          cp -Rf ./.modules/$REPO_TYPE/files/.gitlab . # TODO: Figure out how to combine these cp statements
          cp -Rf ./.modules/$REPO_TYPE/files/.husky .
          cp -Rf ./.modules/$REPO_TYPE/files/.vscode .
          cp -Rf ./.modules/$REPO_TYPE/files/molecule .
          cp ./.modules/$REPO_TYPE/files/.ansible-lint .ansible-lint
          cp ./.modules/$REPO_TYPE/files/.gitignore .gitignore
          cp ./.modules/$REPO_TYPE/files/LICENSE LICENSE
          cp ./.modules/$REPO_TYPE/files/package.json package.json
          cp ./.modules/$REPO_TYPE/files/requirements.txt requirements.txt
        else
          cp -Rf ./.modules/$REPO_TYPE/files/ .

          # Reset ./.modules/ansible if appropriate
          if [ "$REPO_TYPE" == 'ansible' ] && [ ! -f ./main.yml ]; then
            log "Resetting Ansible submodule to HEAD"
            cd ./.modules/ansible
            git reset --hard HEAD
            cd ../..
          fi
        fi
        log "Injecting package.json with the saved name and version"
        jq --arg a "${PACKAGE_NAME}" '.name = $a' package.json > __jq.json && mv __jq.json package.json
        jq --arg a "${PACKAGE_VERSION//\/}" '.version = $a' package.json > __jq.json && mv __jq.json package.json
        if [ "$REPO_TYPE" == 'dockerfile' ] && [ "$SUBGROUP" == 'ansible-molecule' ]; then
            log "Injecting package.json with the saved description"
            jq --arg a "${PACKAGE_DESCRIPTION//\/}" '.description = $a' package.json > __jq.json && mv __jq.json package.json
        elif [ "$REPO_TYPE" == 'ansible' ] || [ "$REPO_TYPE" == 'packer' ]; then
            log "Injecting package.json with the saved description"
            jq --arg a "${PACKAGE_DESCRIPTION//\/}" '.description = $a' package.json > __jq.json && mv __jq.json package.json
        fi
        success "Successfully updated the package.json file and copied the shared $REPO_TYPE files into this repository"
    else
        info "Repository appears to be a new project - it does not have a package.json file"
        if [ "$REPO_TYPE" == 'ansible' ] && [ -f main.yml ]; then
          # The project type is an Ansible playbook
          log "Copying Ansible Playbook files since the main.yml file is present in the root directory"
          cp -Rf ./.modules/$REPO_TYPE/files/.gitlab . # TODO: Figure out how to combine these copy statements
          cp -Rf ./.modules/$REPO_TYPE/files/.husky .
          cp -Rf ./.modules/$REPO_TYPE/files/.vscode .
          cp -Rf ./.modules/$REPO_TYPE/files/molecule .
          cp ./.modules/$REPO_TYPE/files/.ansible-lint .ansible-lint
          cp ./.modules/$REPO_TYPE/files/.gitignore .gitignore
          cp ./.modules/$REPO_TYPE/files/LICENSE LICENSE
          cp ./.modules/$REPO_TYPE/files/package.json package.json
          cp ./.modules/$REPO_TYPE/files/requirements.txt requirements.txt
        else
          log "Copying base files from the common $REPO_TYPE repository"
          cp -Rf ./.modules/$REPO_TYPE/files/ .
          if [ "$REPO_TYPE" == 'dockerfile' ] && [ "$SUBGROUP" == 'ci-pipeline' ]; then
            log "Injecting the package.json name variable with the slug variable from .blueprint.json"
            local PACKAGE_NAME=$(cat .blueprint.json | jq '.slug' | cut -d '"' -f 2)
            jq --arg a "${PACKAGE_NAME}" '.name = $a' package.json > __jq.json && mv __jq.json package.json
            success "Successfully initialized the project with the shared $REPO_TYPE files and updated the name in package.json"
          fi
        fi
    fi

    # Run dockerfile-subgroup specific tasks
    if [ "$REPO_TYPE" == 'dockerfile' ]; then
        # Copies name value from package.json to other locations that should match the string
        log "Performing tasks specific to Dockerfile projects"
        log "Replacing all instances of the string 'dockerfile-project' in package.json with the package.json name"
        sed -i .bak "s^dockerfile-project^${PACKAGE_NAME}^g" package.json && rm package.json.bak
        success "Successfully updated the 'dockerfile-project' string to the package.json name"

        # Ensures the scripts.build:slim value matches the value in .blueprint.json
        log "Ensuring the 'build:slim' variable in package.json is updated"
        local DOCKERSLIM_COMMAND=$(cat .blueprint.json | jq '.dockerslim_command' | cut -d '"' -f 2)
        sed -i .bak "s^DOCKER_SLIM_COMMAND_HERE^${DOCKERSLIM_COMMAND}^g" package.json && rm package.json.bak
        success "Successfully ensured that the right 'build:slim' value is included in package.json"

        # Updates the description from .blueprint.json
        local SUBGROUP=$(cat .blueprint.json | jq '.subgroup' | cut -d '"' -f 2)
        if [ "$SUBGROUP" == 'ci-pipeline' ]; then
            log "Ensuring the package.json description is updated, using a value specified in .blueprint.json"
            local DESCRIPTION_TEMPLATE=$(cat .blueprint.json | jq '.description_template' | cut -d '"' -f 2)
            jq --arg a "${DESCRIPTION_TEMPLATE}" '.description = $a' package.json > __jq.json && mv __jq.json package.json
            success "Successfully copied the .blueprint.json description to the package.json description"
            local SLUG=$(cat .blueprint.json | jq '.slug' | cut -d '"' -f 2)
            local CONTAINER_STATUS=$(docker images -q megabytelabs/${SLUG}:slim)

        fi
    fi
    log "Ensuring the package.json file is Prettier-compliant"
    npx prettier-package-json --write
    success "Successfully ensured that the package.json file is Prettier-compliant"
}

# Miscellaneous fixes
misc_fixes () {
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
}

update_docker_labels () {
  local DOCKERFILE_GROUP=https://gitlab.com/megabyte-labs/dockerfile
  local PACKAGE_DESCRIPTION=$(cat package.json | jq '.description')
  local SLUG=$(cat .blueprint.json | jq '.slug' | cut -d '"' -f 2)
  local SUBGROUP=$(cat .blueprint.json | jq '.subgroup' | cut -d '"' -f 2)
  sed -i .bak "s^.*org.opencontainers.image.description.*^LABEL org.opencontainers.image.description=${PACKAGE_DESCRIPTION}^g" Dockerfile && rm Dockerfile.bak
  sed -i .bak "s^.*org.opencontainers.image.documentation.*^LABEL org.opencontainers.image.documentation=\"${DOCKERFILE_GROUP}/${SUBGROUP}/${SLUG}/-/blob/master/README.md\"^g" Dockerfile && rm Dockerfile.bak
  sed -i .bak "s^.*org.opencontainers.image.source.*^LABEL org.opencontainers.image.source=\"${DOCKERFILE_GROUP}/${SUBGROUP}/${SLUG}.git\"^g" Dockerfile && rm Dockerfile.bak
}
