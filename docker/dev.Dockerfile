FROM hdfgroup/hermes-deps:latest

RUN sudo apt-get update -q

USER ${USER}
WORKDIR ${HOME}
ENV HERMES_DIR=${HOME}/hermes

RUN echo \
    "#!/bin/bash\n \
    pushd hermes\n \
    mkdir -p build\n \
    pushd build\n \
    cmake -DCMAKE_PREFIX_PATH=${HOME}/install -DHERMES_INTERCEPT_IO=OFF ..\n \
    make -j 4\n \
    popd\n \
    popd\n " \
    > build_hermes.sh

RUN chmod +x build_hermes.sh
RUN git clone https://github.com/HDFGroup/hermes ${HERMES_DIR}

