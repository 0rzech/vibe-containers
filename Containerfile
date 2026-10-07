FROM quay.io/fedora/fedora-minimal:44 AS fetcher

ARG AGENT_VERSION=''

RUN <<EOF
  set -euo pipefail

  microdnf upgrade --assumeyes --setopt=install_weak_deps=0
  microdnf install --assumeyes --setopt=install_weak_deps=0 gzip tar
  microdnf clean all

  url_prefix='https://github.com/aaif-goose/goose/releases'
  if [[ -z ${AGENT_VERSION} ]]; then
    AGENT_VERSION="$(curl --fail --silent --show-error --location --head --output /dev/null --write-out "%{url_effective}" "${url_prefix}/latest")"
    AGENT_VERSION="${AGENT_VERSION#${url_prefix}/tag/v}"
  fi
  archive='goose-x86_64-unknown-linux-gnu.tar.gz'
  url="${url_prefix}/download/v${AGENT_VERSION}/${archive}"
  dest='goose'

  echo "Fetching Goose ${AGENT_VERSION}"
  curl --proto '=https' --location --max-redirs 1 "${url}" --output "${archive}"
  tar -xf "${archive}" --strip-components=1
  chmod --verbose +x "${dest}"
  rm --verbose "${archive}"
EOF

FROM quay.io/fedora/fedora-minimal:44

COPY --from=fetcher /goose /usr/bin/goose

ARG USER_NAME='agent'
ARG USER_ID='1000'

ARG GROUP_NAME='agent'
ARG GROUP_ID='1000'

ARG HOME="/home/${USER_NAME}"

RUN <<EOF
  set -euo pipefail

  microdnf upgrade --assumeyes --setopt=install_weak_deps=0
  microdnf install --assumeyes --setopt=install_weak_deps=0 \
    bat \
    fd-find \
    file \
    git \
    glibc-all-langpacks \
    python \
    ripgrep \
    tree \
    which
  microdnf clean all

  passwd --delete root
  usermod --expiredate 1 root

  mkdir --parents --verbose "${HOME}"
  cp --recursive --verbose '/etc/skel/.' "${HOME}"
  chown --recursive --verbose "${USER_ID}:${GROUP_ID}" "${HOME}"
  groupadd --gid "${GROUP_ID}" "${GROUP_NAME}"
  useradd --uid "${USER_ID}" --gid "${GROUP_ID}" --home "${HOME}" "${USER_NAME}"
EOF

ENV PATH="${PATH}:${HOME}/.local/bin"

USER "${USER_NAME}"
