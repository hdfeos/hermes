FROM ubuntu:20.04

ENV USER=hermes
RUN useradd -ms /bin/bash $USER

RUN apt-get update -q --fix-missing && \
    apt-get install -yq gcc g++

RUN apt-get install -y sudo
RUN echo "${USER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    ca-certificates \
    curl \
    environment-modules \
    git \
    build-essential \
    python \
    python-dev \
    python3-dev \
    vim \
    sudo \
    unzip \
    cmake \
    zlib1g-dev \
    libsdl2-dev \
    gfortran \
    graphviz \
    doxygen \
    libtool \
    libtool-bin \
    mpich \
    libmpich-dev

ENV HOME=/home/$USER
ENV INSTALL_DIR=$HOME/install

WORKDIR $HOME

RUN mkdir -p ${INSTALL_DIR}
RUN mkdir -p ${HOME}/ci

COPY ci/packages.yaml ${HOME}/ci/
COPY ci/hermes/ ${HOME}/ci/hermes/
COPY ci/install_deps.sh ${HOME}/

RUN LOCAL=install ${HOME}/install_deps.sh no-staging
RUN rm -rf hdf5
RUN rm install_deps.sh
RUN chown -R hermes.hermes /home/hermes

USER $USER
ENV PATH=${INSTALL_DIR}/bin:$PATH
ENV SPACK_DIR=${INSTALL_DIR}/spack
RUN echo ". ${SPACK_DIR}/share/spack/setup-env.sh" >> /home/$USER/.bashrc

