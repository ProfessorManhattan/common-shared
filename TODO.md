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
sed -i "s^.*org.opencontainers.image.source.\*^LABEL org.opencontainers.image.source=\"${DOCKERFILE_GROUP}/${SUBGROUP}/${SLUG}.git\"^g" Dockerfile
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

remove_unused_packer_platforms() {
log "Pruning references to build types in template.json that do not exist"

# Hyper-V

if ! grep -q '"type": "hyperv-iso"' template.json; then
if [["$OSTYPE" == "darwin"*]]; then
sed -i .bak '/SUPPORTED_OS_HYPERV/d' README.md && rm README.md.bak
sed -i .bak '/\"build:hyperv\"/d' package.json && rm package.json.bak
else
sed -i '/SUPPORTED_OS_HYPERV/d' README.md
sed -i '/\"build:hyperv\"/d' package.json
fi
fi

# Parallels

if ! grep -q '"type": "parallels-iso"' template.json; then
if [["$OSTYPE" == "darwin"*]]; then
sed -i .bak '/SUPPORTED_OS_PARALLELS/d' README.md && rm README.md.bak
sed -i .bak '/\"build:parallels\"/d' package.json && rm package.json.bak
else
sed -i '/SUPPORTED_OS_PARALLELS/d' README.md
sed -i '/\"build:parallels\"/d' package.json
fi
fi

# QEMU/KVM

if ! grep -q '"type": "qemu"' template.json; then
if [["$OSTYPE" == "darwin"*]]; then
sed -i .bak '/SUPPORTED_OS_KVM/d' README.md && rm README.md.bak
sed -i .bak '/\"build:kvm\"/d' package.json && rm package.json.bak
else
sed -i '/SUPPORTED_OS_KVM/d' README.md
sed -i '/\"build:kvm\"/d' package.json
fi
fi

# VirtualBox

if ! grep -q '"type": "virtualbox-iso"' template.json; then
if [["$OSTYPE" == "darwin"*]]; then
sed -i .bak '/SUPPORTED_OS_VIRTUALBOX/d' README.md && rm README.md.bak
sed -i .bak '/\"build:virtualbox\"/d' package.json && rm package.json.bak
else
sed -i '/SUPPORTED_OS_VIRTUALBOX/d' README.md
sed -i '/\"build:virtualbox\"/d' package.json
fi
fi

# VMWare

if ! grep -q '"type": "vmware-iso"' template.json; then
if [["$OSTYPE" == "darwin"*]]; then
sed -i .bak '/SUPPORTED_OS_VMWARE/d' README.md && rm README.md.bak
sed -i .bak '/\"build:vmware\"/d' package.json && rm package.json.bak
else
sed -i '/SUPPORTED_OS_VMWARE/d' README.md
sed -i '/\"build:vmware\"/d' package.json
fi
fi
}

populate_packer_descriptions() {

# Ensure description is populated

if [ "$REPO_TYPE" == 'packer' ]; then
log "Injecting description in template.json"
local ISO_VERSION=$(jq -r '.variables.iso_version' template.json)
    local MAJOR_VERSION=$(cut -d '.' -f 1 <<<$ISO_VERSION)
    local MINOR_VERSION=$(cut -d '.' -f 2 <<<$ISO_VERSION)
    local DESCRIPTION_TEMPLATE=$(jq -r '.description_template' .blueprint.json)
local DESCRIPTION_TEMPLATE_PACKAGE=$(jq -r '.description_template_package' .blueprint.json)
    local VERSION_DESCRIPTION=$(jq -r '.version_description' .blueprint.json)
jq --arg a "${DESCRIPTION_TEMPLATE}" '.variables.description = $a' template.json >__jq.json && mv __jq.json template.json
    jq --arg a "${DESCRIPTION_TEMPLATE_PACKAGE}" '.description = $a' package.json >__jq.json && mv __jq.json package.json
    jq --arg a "${VERSION_DESCRIPTION}" '.variables.version_description = $a' template.json >__jq.json && mv __jq.json template.json
    if [[ "$OSTYPE" == "darwin"\* ]]; then
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
if command_exists packer; then
log "Running packer fix"
packer fix template.json >**template.json
mv **template.json template.json
fi
log "Formatting fixed template with Prettier"
npx prettier --write template.json
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
        (echo "---" && cat requirements.yml) >_reqs.yml && mv _reqs.yml requirements.yml
      fi
    fi
    log "Ensuring community.general collection is in meta requirements (if necessary)"
    local COMMUNITY_REFS=$(grep -Ril "community.general" ./tasks)
if [ "$COMMUNITY_REFS" ]; then
local COMMUNITY_REQ_REFS=$(yq eval '.collections' requirements.yml)
      if [[ ! $COMMUNITY_REQ_REFS =~ "community.general" ]]; then
        yq eval -i -P '.collections = .collections + {"name": "community.general", "source": "https://galaxy.ansible.com"}' requirements.yml
        (echo "---" && cat requirements.yml) >_reqs.yml && mv _reqs.yml requirements.yml
      fi
    fi
    log "Ensuring professormanhattan.homebrew role is in meta requirements (if necessary)"
    local HOMEBREW_REFS=$(grep -Ril "community.general.homebrew" ./tasks)
if [ "$HOMEBREW_REFS" ]; then
local HOMEBREW_META_REFS=$(yq eval '.dependencies' meta/main.yml)
      if [[ ! $HOMEBREW_META_REFS =~ "professormanhattan.homebrew" ]]; then
        yq eval -i -P '.dependencies = .dependencies + {"role": "professormanhattan.homebrew", "when": "ansible_os_family == \"Darwin\""}' meta/main.yml
        (echo "---" && cat meta/main.yml) >_meta_dash.yml && mv _meta_dash.yml meta/main.yml
      fi
    fi
    log "Ensuring professormanhattan.nodejs role is in meta requirements (if necessary)"
    local NODEJS_REFS=$(grep -Ril "community.general.npm" ./tasks)
if [ "$NODEJS_REFS" ]; then
local NODEJS_META_REFS=$(yq eval '.dependencies' meta/main.yml)
      if [[ ! $NODEJS_META_REFS =~ "professormanhattan.nodejs" ]]; then
        yq eval -i -P '.dependencies = .dependencies + {"role": "professormanhattan.nodejs"}' meta/main.yml
        (echo "---" && cat meta/main.yml) >_meta_dash.yml && mv _meta_dash.yml meta/main.yml
      fi
    fi
    log "Ensuring professormanhattan.ruby role is in meta requirements (if necessary)"
    local RUBY_REFS=$(grep -Ril "community.general.gem" ./tasks)
if [ "$RUBY_REFS" ]; then
local RUBY_META_REFS=$(yq eval '.dependencies' meta/main.yml)
      if [[ ! $RUBY_META_REFS =~ "professormanhattan.ruby" ]]; then
        yq eval -i -P '.dependencies = .dependencies + {"role": "professormanhattan.ruby"}' meta/main.yml
        (echo "---" && cat meta/main.yml) >_meta_dash.yml && mv _meta_dash.yml meta/main.yml
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
(echo "---" && cat meta/main.yml) >\_meta_dash.yml && mv \_meta_dash.yml meta/main.yml
fi
fi
fi
log "Ensuring all the dependencies in meta/main.yml are also in the requirements.yml file"
yq eval -j '.dependencies' meta/main.yml >\_meta-deps.json
local REQ_REFS=$(yq eval '.roles' requirements.yml)
    jq -rc '.[] .role' _meta-deps.json | while read ROLE_NAME; do
      if [[ ! $REQ_REFS =~ $ROLE_NAME ]]; then
        ROLE_NAME=$ROLE_NAME yq eval -i -P '.roles = .roles + {"name": env(ROLE_NAME)}' requirements.yml
(echo "---" && cat requirements.yml) >\_reqs.yml && mv \_reqs.yml requirements.yml
fi
done
rm \_meta-deps.json
success "Successfully ensured common dependencies were populated"
fi
}

if [ -f slim.report.json ]; then
log "Ensuring the slim.report.json is properly formatted"
npx prettier --write slim.report.json
success "slim.report.json is Prettier-compliant"
fi

generate_vagrantfile() {
log "Generating Vagrantfile"
local OS_BOX_BASENAME=$(jq -r '.variables.box_basename' template.json)
  local OS_DESCRIPTION=$(jq -r '.variables.description' template.json)
local OS_HOSTNAME=$(jq -r '.hostname' .blueprint.json)
  local OS_TAG=$(jq -r '.vagrant_tag' .blueprint.json)
local VAGRANTUP_USER=$(jq -r '.variables.vagrantup_user' template.json)
  if [[ "$OSTYPE" == "darwin"\* ]]; then
sed -i .bak "s^OS_BOX_BASENAME^${OS_BOX_BASENAME}^g" Vagrantfile && rm Vagrantfile.bak
    sed -i .bak "s^OS_DESCRIPTION^${OS_DESCRIPTION}^g" Vagrantfile && rm Vagrantfile.bak
sed -i .bak "s^OSHOSTNAME^${OS_HOSTNAME}^g" Vagrantfile && rm Vagrantfile.bak
    sed -i .bak "s^OSPLACEHOLDER^${OS_TAG}^g" Vagrantfile && rm Vagrantfile.bak
sed -i .bak "s^VAGRANTUP_USER^${VAGRANTUP_USER}^g" Vagrantfile && rm Vagrantfile.bak
  else
    sed -i "s^OS_BOX_BASENAME^${OS_BOX_BASENAME}^g" Vagrantfile
sed -i "s^OS_DESCRIPTION^${OS_DESCRIPTION}^g" Vagrantfile
    sed -i "s^OSHOSTNAME^${OS_HOSTNAME}^g" Vagrantfile
sed -i "s^OSPLACEHOLDER^${OS_TAG}^g" Vagrantfile
    sed -i "s^VAGRANTUP_USER^${VAGRANTUP_USER}^g" Vagrantfile
fi
success "Generated Vagrantfile"
}
