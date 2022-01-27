FROM ubuntu:20.04

ENV USER=hermes
RUN useradd -ms /bin/bash $USER
RUN su - $USER -c "touch me"

RUN apt-get update -q --fix-missing && \
    apt-get install -yq gcc g++

RUN apt-get install -y sudo
RUN echo "${USER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER

RUN cat /etc/sudoers.d/$USER

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

USER $USER

RUN sudo apt-get update -q

ENV HOME=/home/$USER

ENV PROJECT=$HOME/source
ENV INSTALL_DIR=$HOME/install
ENV SPACK_DIR=$HOME/spack
ENV MOCHI_DIR=$HOME/mochi

RUN echo $INSTALL_DIR && mkdir -p $INSTALL_DIR

ENV THALLIUM_VERSION=0.8.3
ENV CATCH2_VERSION=2.13.3
ENV ORTOOLS_VERSION=7.7
ENV SPACK_VERSION=0.16.3

RUN git clone https://github.com/spack/spack ${SPACK_DIR}
RUN (cd ${SPACK_DIR} && git checkout v${SPACK_VERSION})

ENV MOCHI_SPACK_PACKAGES_COMMIT=f015ae93717ac3b81972c55116c3b91aa9c645e4
RUN git clone https://github.com/mochi-hpc/mochi-spack-packages.git ${MOCHI_DIR}
RUN (cd ${MOCHI_DIR} && git checkout ${MOCHI_SPACK_PACKAGES_COMMIT})
RUN git clone https://github.com/HDFGroup/hermes ${PROJECT}

ENV spack=${SPACK_DIR}/bin/spack

RUN . ${SPACK_DIR}/share/spack/setup-env.sh

RUN $spack repo add ${MOCHI_DIR}
RUN $spack repo add $PROJECT/ci/hermes

RUN $spack compiler find

RUN $spack compiler list

RUN mkdir -p ${HOME}/.spack

# Configure spack to use existing libraries instead of building everything from
# scratch
RUN echo \
'packages:\n \
   mpich:\n \
     externals:\n \
     - spec: mpich@3.3\n \
       prefix: /opt/mpich-3.3-intel\n \
     buildable: False\n \
   cmake:\n \
     externals:\n \
     - spec: cmake@3.10.0\n \
       prefix: /usr/local/cmake-3.10.0\n \
     buildable: False\n \
   autoconf:\n \
     externals:\n \
     - spec: autoconf@2.69\n \
       prefix: /usr\n \
     buildable: False\n \
   automake:\n \
     externals:\n \
     - spec: automake@1.15\n \
       prefix: /usr\n \
     buildable: False\n \
   libtool:\n \
     externals:\n \
     - spec: libtool@2.4.6\n \
       prefix: /usr\n \
     buildable: False\n \
   m4:\n \
     externals:\n \
     - spec: m4@4.17\n \
       prefix: /usr\n \
     buildable: False\n \
   pkg-config:\n \
     externals:\n \
     - spec: pkg-config@0.29.1\n \
       prefix: /usr\n \
     buildable: False\n' \
> ${HOME}/.spack/packages.yaml

ENV HERMES_VERSION=master

RUN ${spack} install mochi-thallium@${THALLIUM_VERSION}~cereal ^mercury~boostsys
RUN ${spack} install gortools@${ORTOOLS_VERSION}
RUN ${spack} install catch2@${CATCH2_VERSION}

RUN echo "export PATH=${SPACK_DIR}/bin:$PATH" >> /home/$USER/.bashrc
RUN echo ". ${SPACK_DIR}/share/spack/setup-env.sh" >> /home/$USER/.bashrc

RUN ${spack} view symlink ${INSTALL_DIR} mochi-thallium gortools catch2

ENV PATH=${INSTALL_DIR}/bin:$PATH

WORKDIR $HOME
