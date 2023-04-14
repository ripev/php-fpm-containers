FROM ripev/php-fpm-composer-node:7.3-latest

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.24.0

# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
RUN cp /root/.bashrc /var/www

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH

RUN usermod -u 1001 www-data

WORKDIR "/var/www/html"

EXPOSE 9000
