FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH=$MAMBA_ROOT_PREFIX/envs/bga/bin:$MAMBA_ROOT_PREFIX/bin:$PATH

# Cài XFCE + các gói cần thiết
RUN apt update && apt install -y \
    xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils xfce4-terminal \
    tigervnc-standalone-server tigervnc-common \
    curl wget bzip2 ca-certificates nano vim less igv \
    iputils-ping procps tar build-essential libz-dev \
    git sudo python3-pip net-tools \
    && apt clean && rm -rf /var/lib/apt/lists/*

# websockify & noVNC
RUN pip3 install websockify && \
    git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc_lite.html /opt/novnc/index.html

# User
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

USER docker
WORKDIR /home/docker

# Thiết lập mật khẩu VNC
RUN mkdir -p ~/.vnc && \
    echo "docker" | vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd

# Cấu hình khởi động XFCE qua VNC
RUN echo '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
export XKL_XMODMAP_DISABLE=1\n\
export DISPLAY=:1\n\
exec startxfce4' > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup

USER root
# Cài micromamba
RUN curl -L https://micromamba.snakepit.net/api/micromamba/linux-64/latest -o micromamba.tar.bz2 && \
    tar -xvjf micromamba.tar.bz2 && \
    mv bin/micromamba /usr/local/bin/ && \
    rm -rf bin micromamba.tar.bz2
# Copy file môi trường Conda
COPY env.yaml /opt/env.yaml
     extract_reordered.py /opt/conda/envs/bga/bin/
     get_pseudo.pl /opt/conda/envs/bga/bin/
     annotation_stat.py /opt/conda/envs/bga/bin/
     roary_plot.py /opt/conda/envs/bga/bin/

# Cài đặt môi trường bioinformatics qua micromamba
RUN micromamba create -y -f /opt/env.yaml -p /opt/conda/envs/bga    

USER docker

EXPOSE 5901 6080

CMD vncserver :1 -geometry 1600x900 -depth 24 && \
    websockify --web=/opt/novnc 6080 localhost:5901

