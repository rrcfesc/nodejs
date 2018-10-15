FROM python:3.5

LABEL mantainer "rrcfesc@gmail.com"

ENV USER nodeuser
ENV PORT 80
ENV NODEJSPORT 3000

RUN apt-get update && apt-get install -y --no-install-recommends locales apt-utils
RUN set -x; \
    locale-gen es_MX.UTF-8 && \
    update-locale && \
    echo 'LANG="es_MX.UTF-8"' > /etc/default/locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
RUN update-locale LANG=en_US.UTF-8
RUN echo "export LANG=en_US.UTF-8\nexport LANGUAGE=en_US.UTF-8\nexport LC_ALL=en_US.UTF-8\nexport PYTHONIOENCODING=UTF-8" | tee -a /etc/bash.bashrc
RUN apt-get install -y gcc g++ apt-utils python-pip make libxml2-dev libxslt-dev libevent-dev libsasl2-dev libldap2-dev python3-lxml libjpeg-dev \
    libssl-dev python-dev git python3-dev curl wget unzip locales tree tmux vim postgresql-client\
    build-essential libsqlite3-dev xfonts-75dpi zlib1g-dev libncurses5-dev libgdbm-dev libbz2-dev libreadline-gplv2-dev libssl-dev libdb-dev
RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
RUN chmod +x nodesource_setup.sh && ./nodesource_setup.sh && rm nodesource_setup.sh
RUN apt-get install nodejs vim yarn -y
ADD extraFiles/entrypoint.sh /usr/local/bin/entrypoint.sh
ADD extraFiles/supervisor.conf /etc/supervisord.conf
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN python2 -m pip install supervisor

RUN useradd  -m -d /home/${USER} -s /bin/bash ${USER}
RUN passwd ${USER} -d
RUN git clone --depth=1 --single-branch https://github.com/spf13/spf13-vim.git /tmp/spf13-vim
RUN su - ${USER} -c "source /etc/bash.bashrc"
RUN su - ${USER} -c "/tmp/spf13-vim/bootstrap.sh"
RUN su - ${USER} -c "mkdir -p ~/.vim/spell"
RUN su - ${USER} -c "wget -q http://ftp.vim.org/pub/vim/runtime/spell/es.utf-8.spl -O ~/.vim/spell/es.utf-8.spl"
RUN echo '"filetype plugin indent on \n"show existing tab with 4 spaces width\nset tabstop=4 \n"when indenting with >, use 4 spaces width \nset shiftwidth=4 \n"On pressing tab, insert 4 spaces \nset expandtab \ncolorscheme heliotrope\n"Disable pymode because show ImporError\nlet g:pymode=0\nset spelllang=en,es\n' >> /home/${USER}/.vimrc
RUN sed -i 's/ set mouse\=a/\"set mouse\=a/g' /home/${USER}/.vimrc
RUN sed -i "s/let g:neocomplete#enable_at_startup = 1/let g:neocomplete#enable_at_startup = 0/g" /home/${USER}/.vimrc

WORKDIR /home/${USER}

EXPOSE 80 3000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]