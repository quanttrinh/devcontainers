ARG TEXDIR="/usr/local/texlive"
ARG TEXUSERDIR="~/.texlive"

ARG SCHEME="scheme-full"
ARG DOCFILES=0
ARG SRCFILES=0

FROM mcr.microsoft.com/devcontainers/base:debian

ARG TEXDIR
ARG TEXUSERDIR
ARG SCHEME
ARG DOCFILES
ARG SRCFILES

COPY <<EOF /tmp/texlive/profile
selected_scheme ${SCHEME}
instopt_adjustpath 1
tlpdbopt_autobackup 0
tlpdbopt_desktop_integration 0
tlpdbopt_file_assocs 0
tlpdbopt_install_docfiles ${DOCFILES}
tlpdbopt_install_srcfiles ${SRCFILES}
EOF

RUN  <<EOF
set -eoux pipefail
mkdir -p /tmp/texlive
cd /tmp/texlive
MIRROR=$(curl -sIL -o /dev/null -w '%{url_effective}' https://mirror.ctan.org/systems/texlive/tlnet/)
if [ -z "$MIRROR" ]; then
  MIRROR="https://mirror.ctan.org/systems/texlive/tlnet/"
fi
wget -q "${MIRROR}install-tl-unx.tar.gz"
wget -q "${MIRROR}install-tl-unx.tar.gz.sha512"
sha512sum -c install-tl-unx.tar.gz.sha512
tar -xzf install-tl-unx.tar.gz --strip-components=1
export TEXLIVE_INSTALL_ENV_NOCHECK=1
perl install-tl \
  --no-interaction \
  --profile=/tmp/texlive/profile \
  --texdir=${TEXDIR} \
  --texuserdir=${TEXUSERDIR}
tlmgr install latexmk latexindent
rm -rf /tmp/texlive
EOF

ENV PATH="${TEXDIR}/bin/x86_64-linux:${PATH}"
