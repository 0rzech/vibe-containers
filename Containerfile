FROM quay.io/fedora/fedora-minimal:44

ARG USER_NAME='vibe'
ARG USER_ID='1000'

ARG GROUP_NAME='vibe'
ARG GROUP_ID='1000'

ARG HOME="/home/${USER_NAME}"
ARG VIBE_HOME="${HOME}/.vibe"

ARG VIBE_VERSION='>=2'

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
    uv \
    which
  passwd --delete root
  usermod --expiredate 1 root
  mkdir --parents --verbose "${HOME}"
  cp --recursive --verbose '/etc/skel/.' "${HOME}"
  chown --recursive --verbose "${USER_ID}:${GROUP_ID}" "${HOME}"
  groupadd --gid "${GROUP_ID}" "${GROUP_NAME}"
  useradd --uid "${USER_ID}" --gid "${GROUP_ID}" --home "${HOME}" "${USER_NAME}"
EOF

USER "${USER_NAME}"

ENV PATH="${PATH}:${HOME}/.local/bin"
ENV VIBE_HOME="${VIBE_HOME}"

RUN <<EOF
  set -euo pipefail
  vibe_install_log="${HOME}/vibe-install-log.txt"
  touch "${vibe_install_log}"
  uv tool install --no-cache "mistral-vibe${VIBE_VERSION}" 2>&1 | tee "${vibe_install_log}"
EOF
