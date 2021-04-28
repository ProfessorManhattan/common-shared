#!/bin/bash

# This file houses all the shared functions used across various
# update.sh files which are used to synchronize common files
# across many different projects. It also includes various
# functions that perform maintenance tasks.

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
                log "Debian-flavor OS specified in Dockerfile"
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

# Determines whether or not an executable is accessible
command_exists () {
    type "$1" &> /dev/null ;
}

# Logger functions
log () {
  run-func ./.modules/shared/log.js debug "$1"
}

info () {
  run-func ./.modules/shared/log.js info "$1"
}

success () {
  run-func ./.modules/shared/log.js success "$1"
}

error () {
  run-func ./.modules/shared/log.js error "$1"
}

warn () {
  run-func ./.modules/shared/log.js warn "$1"
}

# Ensures the docker pushrm plugin is installed. This is used to automatically
# update the README.md embedded on the DockerHub website.
ensure_docker_pushrm_installed () {
    log "Checking whether docker-pushrm is already installed"
    if [ "$(uname)" == "Darwin" ]; then
        # System is Mac OS X
        local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_darwin_amd64
        local DESTINATION="$HOME/.docker/cli-plugins/docker-pushrm"
        if [ ! -f "$DESTINATION" ]; then
            info "docker-pushrm is not currently installed"
            log "Ensuring the ~/.docker/cli-plugins folder exists"
            mkdir -p $HOME/.docker/cli-plugins
            log "Downloading docker-pushrm"
            wget $DOWNLOAD_URL -O $DESTINATION
            chmod +x $DESTINATION
            success "docker-pushrm successfully installed to the ~/.docker/cli-plugins folder"
        else
          info "docker-pushrm is already installed"
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # System is Linux
        local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_linux_amd64
        local DESTINATION="$HOME/.docker/cli-plugins/docker-pushrm"
        if [ ! -f "$DESTINATION" ]; then
            info "docker-pushrm is not currently installed"
            log "Ensuring the ~/.docker/cli-plugins folder exists"
            mkdir -p $HOME/.docker/cli-plugins
            log "Downloading docker-pushrm"
            wget $DOWNLOAD_URL -O $DESTINATION
            chmod +x $DESTINATION
            success "docker-pushrm successfully installed to the ~/.docker/cli-plugins folder"
        else
          info "docker-pushrm is already installed"
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        # System is Windows 32-bit
        local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_windows_386.exe
        warn "Windows support has not been added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        # System is Windows 64-bit
        local DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_windows_amd64.exe
        warn "Windows support has not been added yet"
    fi
}

# Ensures DockerSlim is installed. If it is not present, it is installed to ~/.bin for
# the current user
ensure_dockerslim_installed () {
    log "Checking whether DockerSlim is already installed"
    if [ "$(uname)" == "Darwin" ]; then
        # System is Mac OS X
        local DOWNLOAD_URL=https://downloads.dockerslim.com/releases/1.35.1/dist_mac.zip
        local DESTINATION="$HOME/.bin/docker-slim"
        local USER_BIN_FOLDER="$HOME/.bin"
        local BASH_PROFILE="$HOME/.bash_profile"
        if [ ! -f "$DESTINATION" ] && ! command_exists docker-slim; then
            info "DockerSlim is not currently installed"
            log "Downloading DockerSlim for Mac OS X"
            wget $DOCKER_SLIM_DOWNLOAD_LINK # TODO: A temporary directory should be used instead
            unzip dist_mac.zip
            log "Ensuring the ~/.bin folder exists"
            mkdir -p $USER_BIN_FOLDER
            cp ./dist_mac/* $USER_BIN_FOLDER
            rm dist_mac.zip
            rm -rf dist_mac
            chmod +x $USER_BIN_FOLDER/docker-slim
            chmod +x $USER_BIN_FOLDER/docker-slim-sensor
            success "DockerSlim successfully installed to the ~/.bin folder"
            export PATH="$USER_BIN_FOLDER:$PATH"
            # Check to see if the "export PATH" command is already present in ~/.bash_profile
            if [[ $(grep -L 'export PATH=$HOME/.bin:$PATH' "$BASH_PROFILE") ]]; then
                echo -e '\nexport PATH=$HOME/.bin:$PATH' >> $BASH_PROFILE
                success "Updated the PATH variable to include ~/.bin in the $BASH_PROFILE file"
            else
              log "The ~/.bin folder is already included in the PATH variable"
            fi
        else
          info "DockerSlim is already installed"
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # System is Linux
        local DOWNLOAD_URL=https://downloads.dockerslim.com/releases/1.35.1/dist_linux.tar.gz
        local DESTINATION="$HOME/.bin/docker-slim"
        local USER_BIN_FOLDER="$HOME/.bin"
        local BASH_PROFILE="$HOME/.bashrc"
        if [ ! -f "$DESTINATION" ] && ! command_exists docker-slim; then
            info "DockerSlim is not currently installed"
            log "Downloading DockerSlim for Linux"
            wget $DOCKER_SLIM_DOWNLOAD_LINK # TODO: A temporary directory should be used instead - same applies for all downloads to working directory
            tar -zxvf dist_linux.tar.gz
            log "Ensuring the ~/.bin folder exists"
            mkdir -p $USER_BIN_FOLDER
            cp ./dist_linux/* $USER_BIN_FOLDER
            rm dist_linux.tar.gz
            rm -rf dist_linux
            chmod +x $USER_BIN_FOLDER/docker-slim
            chmod +x $USER_BIN_FOLDER/docker-slim-sensor
            success "DockerSlim successfully installed to the ~/.bin folder"
            export PATH="$USER_BIN_FOLDER:$PATH"
            # Check to see if the "export PATH" command is already present in ~/.bashrc
            if [[ $(grep -L 'export PATH=$HOME/.bin:$PATH' "$BASH_PROFILE") ]]; then
                echo -e '\nexport PATH=$HOME/.bin:$PATH' >> $BASH_PROFILE
                success "Updated the PATH variable to include ~/.bin in the $BASH_PROFILE file"
            else
              log "The ~/.bin folder is already included in the PATH variable"
            fi
        else
          info "DockerSlim is already installed"
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        # System is Windows 32-bit
        warn "Windows support has not been added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        # System is Windows 64-bit
        warn "Windows support has not been added yet"
    fi
}

# Ensures jq is installed. If it is not present, it is installed to ~/.bin for
# the current user
ensure_jq_installed () {
    log "Checking whether jq is already installed"
    if [ "$(uname)" == "Darwin" ]; then
        # System is Mac OS X
        local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64
        local DESTINATION="$HOME/.bin/jq"
        local USER_BIN_FOLDER="$HOME/.bin"
        local BASH_PROFILE="$HOME/.bash_profile"
        if [ ! -f "$DESTINATION" ] && ! command_exists jq; then
            info "jq is not currently installed"
            log "Ensuring the ~/.bin folder exists"
            mkdir -p $USER_BIN_FOLDER
            log "Downloading jq for Mac OS X"
            wget $DOWNLOAD_URL -O $DESTINATION
            chmod +x $DESTINATION
            success "jq successfully installed to the ~/.bin folder"
            export PATH="$USER_BIN_FOLDER:$PATH"
            # Check to see if the "export PATH" command is already present in ~/.bash_profile
            if [[ $(grep -L 'export PATH=$HOME/.bin:$PATH' "$BASH_PROFILE") ]]; then
                echo -e '\nexport PATH=$HOME/.bin:$PATH' >> $BASH_PROFILE
                success "Updated the PATH variable to include ~/.bin in the $BASH_PROFILE file"
            else
              log "The ~/.bin folder is already included in the PATH variable"
            fi
        else
          info "jq is already installed"
        fi
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # System is Linux
        local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
        local DESTINATION="$HOME/.bin/jq"
        local USER_BIN_FOLDER="$HOME/.bin"
        local BASH_PROFILE="$HOME/.bashrc"
        if [ ! -f "$DESTINATION" ] && [ ! command_exists jq ]; then
            info "jq is not currently installed"
            log "Ensuring the ~/.bin folder exists"
            mkdir -p $USER_BIN_FOLDER
            log "Downloading jq for Linux"
            wget $DOWNLOAD_URL -O $DESTINATION
            chmod +x $DESTINATION
            success "jq successfully installed to the ~/.bin folder"
            export PATH="$USER_BIN_FOLDER:$PATH"
            # Check to see if the "export PATH" command is already present in ~/.bashrc
            if [[ $(grep -L 'export PATH=$HOME/.bin:$PATH' "$BASH_PROFILE") ]]; then
                echo -e '\nexport PATH=$HOME/.bin:$PATH' >> $BASH_PROFILE
                success "Updated the PATH variable to include ~/.bin in the $BASH_PROFILE file"
            else
              log "The ~/.bin folder is already included in the PATH variable"
            fi
        else
          info "jq is already installed"
        fi
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
        # System is Windows 32-bit
        local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win32.exe
        warn "Windows support has not been added yet"
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
        # System is Windows 64-bit
        local DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
        warn "Windows support has not been added yet"
    fi
}

# Ensures Node.js is installed by using nvm
ensure_node_installed () {
    if ! command_exists npx; then
        echo "A recent version of Node.js is not installed."
        echo "Installing nvm and Node.js.."
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install node
        local NODE_INSTALLED=true
    fi
    if ! command_exists run-func; then
      npm install -g @appnest/readme, prettier prettier-package-json run-func
      if [ "$NODE_INSTALLED" == true ]; then
        success "The latest version of Node.js has been successfully installed"
        info "The script will continue to use the latest version of Node.js but in order to use it yourself you will have to close/open the terminal"
        success "Successfully installed npm global dependencies (@appnest/readme, prettier, prettier-package-json, run-func)"
      fi
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
        log "Updating the docs submodule"
        cd ./.modules/docs
        git checkout master && git pull origin master
        cd ../..
        success "Successfully updated the docs submodule"
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
    fi
    jq -s '.[0] * .[1]' .blueprint.json ./.modules/docs/common.json > __bp.json
    log "Generating the CONTRIBUTING.md file"
    @appnest/readme generate --config __bp.json --input ./.modules/docs/blueprint-contributing.md --output CONTRIBUTING.md
    success "Successfully generated the CONTRIBUTING.md file"
    log "Generating the README.md file"
    @appnest/readme generate --config __bp.json --input ./.modules/docs/$README_FILE
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

# Updates package.json
copy_project_files_and_generate_package_json () {
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
        fi
        warn "Copying the $REPO_TYPE common files into the repository - this may overwrite changes to files managed by the common repository. For more information please see the CONTRIBUTING.md document."
        cp -Rf ./.modules/$REPO_TYPE/files/ .
        log "Injecting package.json with the saved name and version"
        jq --arg a "${PACKAGE_NAME}" '.name = $a' package.json > __jq.json && mv __jq.json package.json
        jq --arg a "${PACKAGE_VERSION//\/}" '.version = $a' package.json > __jq.json && mv __jq.json package.json
        if [ "$REPO_TYPE" == 'dockerfile' ] && [ "$SUBGROUP" == 'ansible-molecule' ]; then
            log "Injecting package.json with the saved name and version"
            jq --arg a "${PACKAGE_DESCRIPTION//\/}" '.description = $a' package.json > __jq.json && mv __jq.json package.json
        fi
        success "Successfully updated the package.json file and copied the shared $REPO_TYPE files into this repository"
    else
        info "Repository appears to be a new project - it does not have a package.json file"
        log "Copying base files from the common $REPO_TYPE repository"
        cp -Rf ./.modules/$REPO_TYPE/files/ .
        log "Injecting the package.json name variable with the slug variable from .blueprint.json"
        local PACKAGE_NAME=$(cat .blueprint.json | jq '.slug' | cut -d '"' -f 2)
        jq --arg a "${PACKAGE_NAME}" '.name = $a' package.json > __jq.json && mv __jq.json package.json
        success "Successfully initialized the project with the shared $REPO_TYPE files and updated the name in package.json"
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
            if [ -f slim.report.json ]; then
                info "A DockerSlim report is present in this repository"
                log "Injecting the package.json description with the container file size detailed in slim.report.json"
                local SLIM_IMAGE_SIZE=$(cat slim.report.json | jq '.minified_image_size_human' | cut -d '"' -f 2)
                sed -i .bak "s^SLIM_IMAGE_SIZE^${SLIM_IMAGE_SIZE}^g" package.json && rm package.json.bak
                success "Successfully added the container file size to the package.json description"
            else
                info "The slim.report.json file appears to be missing from this repository"
                log "Removing the container file size placeholder from the description in package.json"
                sed -i .bak "s^\w\(only\wSLIM_IMAGE_SIZE!)^^g" package.json && rm package.json.bak
                success "Successfully removed the container file size placeholder from the description in package.json"
            fi
        fi
    fi
    log "Ensuring the package.json file is Prettier-compliant"
    prettier-package-json --write
    success "Successfully ensured that the package.json file is Prettier-compliant"
}

# Miscellaneous fixes
misc_fixes () {
    # Ensure .blueprint.json is using Prettier formatting
    if [ -f .blueprint.json ]; then
        log "Ensuring .blueprint.json is properly formatted"
        prettier --write .blueprint.json
        success ".blueprint.json is Prettier-compliant"
    fi
    # Ensure slim.report.json is using Prettier formatting
    if [ -f slim.report.json ]; then
        log "Ensuring the slim.report.json is properly formatted"
        prettier --write slim.report.json
        success "slim.report.json is Prettier-compliant"
    fi
    # Ensure pre-commit hook is executable
    if [ -f .husky/pre-commit ]; then
        log "Ensuring the Husky pre-commit hook is executable"
        chmod 755 .husky/pre-commit
        success "The Husky pre-commit has the correct file permissions"
    fi
}
