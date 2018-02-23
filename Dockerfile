# Image make by Annalect UK Data Management

FROM ubuntu:latest

LABEL maintainer="data.management-uk@annalect.com"

USER root

RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
     wget \
     bzip2 \
     ca-certificates \
     sudo \
     locales \
     fonts-liberation \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
# Install requirements for mapnik and boost
 
RUN	apt-get update -y && \ 
	apt-get install -y software-properties-common python3-software-properties && \
	add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
	add-apt-repository ppa:jonathonf/python-3.6 -y && \
	apt-get update -y && \
	apt-get install -y gcc-6 g++-6 python3.6 python3.6-dev python3-pip icu-devtools && \
	ln -s -f /usr/bin/python3.6 /usr/bin/python
	
RUN cd /tmp && \
	wget https://dl.bintray.com/boostorg/release/1.66.0/source/boost_1_66_0.tar.gz  && \
	tar -zxvf boost_1_66_0.tar.gz  && \
	rm boost_1_66_0.tar.gz  && \
	cd boost_1_66_0  && \
	./bootstrap.sh --with-python=python  && \
	./b2  && \
	./b2 install

ENV BOOST_PYTHON=boost_python3

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    echo "1361527f39190a7338a0b434bd8c88ff7233ce7b9a4876f3315c22fce7eca1b0 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \ 
    chmod +x /usr/local/bin/tini

ENV NB_USER=${LOCAL_USER:-jovyan}

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

ADD fix-permissions /usr/local/bin/fix-permissions

# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

RUN apt-get update -y && \
    apt-get upgrade -y

CMD ["/bin/bash"]

