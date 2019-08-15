
# ベースイメージ
#FROM ubuntu:18.04
FROM nvidia/cudagl:10.1-devel-ubuntu18.04

MAINTAINER verxirtam

ARG user_name
ARG user_id
ARG group_name
ARG group_id

# user
# uid、gidはhostのものと一致させる
# uid、gidの設定、ユーザの追加、sudoersへ追加、パスワード設定
RUN groupadd -g ${group_id} ${group_name} \
    && useradd -u ${user_id} -g ${group_id} -m ${user_name} \
    && gpasswd -a ${user_name} sudo \
    && chsh -s /bin/bash ${user_name}\
    && echo ${user_name}':'${user_name} | chpasswd

# ユーザの設定
USER ${user_name}
WORKDIR /home/${user_name}
ENV HOME /home/${user_name}
RUN touch ~/.sudo_as_admin_successful
ENV TERM=xterm-256color
USER root

# volumeの設定
USER ${user_name}
RUN mkdir /home/${user_name}/test
RUN mkdir /home/${user_name}/programs
USER root
RUN mkdir /mnt/LS-VL6D2 \
	&& mkdir /mnt/LS-VL6D2/daisuke

# タイムゾーンの設定
# ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
#   && apt-get purge -y tzdata
# ロケールの設定
RUN apt-get update \
    && apt-get install -y language-pack-ja
RUN update-locale LANG=ja_JP.UTF-8
USER ${user_name}
ENV LANG=ja_JP.UTF-8
USER root


# ソフトの導入
# パッケージの最新化
RUN apt-get clean \
    && apt-get -y update

# ユーティリティ
RUN apt-get -y update \
   && apt-get -y install \
        apt-utils sudo htop dstat bash-completion make git wget cmake curl man

# ディレクトリ作成
USER ${user_name}
RUN mkdir /home/${user_name}/tools
USER root

# dotfiles
USER ${user_name}
RUN cd /home/${user_name}/tools \
    && git clone https://github.com/verxirtam/dotfiles.git \
    && cd dotfiles \
    && : "dotfilesの適用 tmuxのログフォルダの作成も行う" \
    && make
USER root

# エディタ
# vim
# vimプラグイン実行の前提となるパッケージをインストール
RUN apt-get clean \
    && apt-get -y update \
    && apt-get install -y \
        git mercurial gettext libncurses5-dev libperl-dev \
        python3-dev
RUN apt-get clean \
    && apt-get -y update \
    && apt-get install -y \
        lua5.2 \
        liblua5.2-dev \
        luajit \
        libluajit-5.1
# ユーザ切り替え
USER ${user_name}
# vimのインストール
RUN cd /home/${user_name}/tools \
    && git clone https://github.com/vim/vim.git \
    && cd vim \
    && ./configure --with-features=huge \
        --enable-perlinterp --enable-python3interp \
        --enable-luainterp --with-luajit --enable-fail-if-missing \
    && make
# ユーザ切り替え
USER root
RUN cd /home/${user_name}/tools/vim \
    && make install
# ユーザ切り替え
USER ${user_name}
# neobundleのインストール
RUN cd /home/${user_name}/tools/ \
    && mkdir neobundle \
    && cd neobundle/ \
    && curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh > install.sh \
    && sh ./install.sh
# カラースキームhybridのインストール
# vimプラグインのインストール
RUN cd ~/.vim \
    && mkdir colors \
    && cd colors/ \
    && git clone https://github.com/w0ng/vim-hybrid \
    && mv vim-hybrid/colors/hybrid.vim ~/.vim/colors \
    && /home/${user_name}/.vim/bundle/neobundle.vim/bin/neoinstall
# ユーザ切り替え
USER root

# tmux
# ctags
RUN apt-get -y update \
   && apt-get -y install tmux ctags

# C++
# g++ (gprofも入る)
RUN apt-get -y update \
   && apt-get -y install g++

# gprof2dot
USER ${user_name}
RUN cd /home/${user_name}/tools \
	&& git clone https://github.com/jrfonseca/gprof2dot.git
USER root

# cuda opengl
# nvidia/cudagl をベースとしているので既に入っている

# cuda sample
RUN sudo apt-get install -y cuda-samples-10-1
USER ${user_name}
RUN cp -ir /usr/local/cuda/samples /home/${user_name}/
USER root

# glfw
RUN apt-get install -y libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev
USER ${user_name}
RUN cd /home/${user_name}/tools \
    && git clone https://github.com/glfw/glfw.git \
    && cd glfw \
    && git checkout 3.3 \
    && cmake . \
    && make
USER root
RUN cd /home/${user_name}/tools/glfw \
    && make install

# glew
RUN apt-get -y install libglew-dev

# doxygen
# graphviz
RUN apt-get -y update \
    && apt-get -y install doxygen graphviz

# googletest
USER ${user_name}
RUN cd /home/${user_name}/tools \
    && wget https://github.com/google/googletest/archive/release-1.8.1.tar.gz \
    && tar -zxvf release-1.8.1.tar.gz \
    && cd googletest-release-1.8.1 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make
USER root
RUN cd /home/${user_name}/tools/googletest-release-1.8.1/build \
    && make install
RUN rm /home/${user_name}/tools/release-1.8.1.tar.gz

# sqlite
RUN apt-get -y update \
    && apt-get -y install sqlite3 libsqlite3-0 libsqlite3-dev

# python3
RUN apt-get -y update \
    && : "Install python3"\
    && apt-get install -y \
        python3-dev python3-doc

# miniconda
RUN apt-get -y update \
    && apt-get install -y \
        python3-venv


