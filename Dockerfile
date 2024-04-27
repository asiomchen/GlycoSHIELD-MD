FROM mambaorg/micromamba:1.5.8-jammy as base

USER root

RUN apt-get update && apt-get install -y wget gcc g++ make cmake

ARG GMX_VERSION=2021.7
ARG BUILD_JOBS=8

RUN wget https://ftp.gromacs.org/gromacs/gromacs-$GMX_VERSION.tar.gz  -O /tmp/gromacs-$GMX_VERSION.tar.gz

RUN tar -xzf /tmp/gromacs-$GMX_VERSION.tar.gz -C /tmp && \
    cd /tmp/gromacs-$GMX_VERSION && \
    mkdir build && cd build && \
    cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DGMX_MPI=OFF && \
    make -j $BUILD_JOBS && make install && \
    cd /tmp && rm -rf gromacs-$GMX_VERSION.*



RUN echo "source /usr/local/gromacs/bin/GMXRC" >> /root/.bashrc
WORKDIR /app

COPY environment-app.yaml .

ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN micromamba install -n base -y -f environment-app.yaml

COPY . /app

RUN pip install --upgrade pip setuptools wheel

RUN pip install .

COPY entrypoint.sh /usr/local/bin/gmx_entrypoint.sh

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "/usr/local/bin/gmx_entrypoint.sh"]

