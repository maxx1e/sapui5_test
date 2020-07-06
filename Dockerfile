FROM debian:stable-slim

# Prepare build arguments
ARG NODE_VERSION=v12.16.1
ARG CHROME_USER_HOME=/home/chrome
#ARG REV=776090
ARG NPM_CONFIG_LOGLEVEL=info
ARG ARG_HTTP_PROXY
ARG ARG_HTTPS_PROXY
ARG ARG_NO_PROXY

# Provide environments
ENV NODE_HOME=/opt/nodejs
ENV CHROME_HOME=/opt/chrome
ENV DEBUG_ADDRESS=0.0.0.0
ENV DEBUG_PORT=9222
# Expose ports for chrome and Karma
EXPOSE 9222
EXPOSE 9876

# Install deps + add Chrome Stable + purge all the things
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	--no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
  git \
	google-chrome-stable \
	fontconfig \
	fonts-ipafont-gothic \
	fonts-wqy-zenhei \
	fonts-thai-tlwg \
	fonts-kacst \
	fonts-symbola \
	fonts-noto \
	fonts-freefont-ttf \
	--no-install-recommends \
	&& apt-get purge --auto-remove -y curl gnupg \
	&& rm -rf /var/lib/apt/lists/*
#------------------------------------------------------------------------------------------------------------------------------------
# Install Chrome headless based on the revision version.
#RUN echo "[INFO] Install Chrome $REV." && \
#    mkdir -p "${CHROME_HOME}" && \
#    wget -q -O chrome.zip https://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_x64/$REV/chrome-linux.zip \
#    && unzip chrome.zip -d "${CHROME_HOME}" \
#    && rm chrome.zip \
#    && ln -s "${CHROME_HOME}/chrome-linux/chrome" /usr/bin/google-chrome-unstable
#------------------------------------------------------------------------------------------------------------------------------------
# Install Node
RUN echo "[INFO] Install Node $NODE_VERSION." && \
    mkdir -p "${NODE_HOME}" && \
    wget -qO- "http://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz" | tar -xzf - -C "${NODE_HOME}" && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/node" /usr/local/bin/node && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/npm" /usr/local/bin/npm && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/npx" /usr/local/bin/ && \
    # Config NPM
    npm config set @sap:registry https://npm.sap.com --global  && \
    # Install plugins that your project needs:
    npm install karma --save-dev && \
    npm install karma-chrome-launcher karma-ui5 karma-junit-reporter karma-coverage karma-mocha-reporter --save-dev && \
    npm install --global @ui5/cli karma-cli && \
    ln -s "${NODE_HOME}/node-${NODE_VERSION}-linux-x64/bin/karma" /usr/local/bin/ && \
#----------------------------------------------------------------------------------------------------------------------------------
# Handle chrome user to avoid --no-sandbox key
#RUN groupadd --system chrome && \
#    useradd --system --create-home --gid chrome --groups audio,video chrome && \
#    mkdir --parents /home/chrome/reports && \
#    chown --recursive chrome:chrome /home/chrome
#----------------------------------------------------------------------------------------------------------------------------------
# Handle users permission
useradd --home-dir "${CHROME_USER_HOME}" --create-home --shell /bin/bash --user-group --uid 1000 --comment 'Chrome user' --password "$(echo weUseWeb |openssl passwd -1 -stdin)" chrome && \
# Allow anybody to write into the images HOME
chmod a+w "${CHROME_USER_HOME}"
# Run Chrome non-privileged
USER chrome
WORKDIR $CHROME_USER_HOME
# Expose port 9222
# Autorun chrome headless with no GPU
#ENTRYPOINT [ "google-chrome" ]
#CMD [ "--headless", "--disable-gpu", "--remote-debugging-address=0.0.0.0", "--remote-debugging-port=9222" ]
