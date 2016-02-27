FROM ghost

WORKDIR /usr/src/ghost/content/themes

RUN apt-get update && apt-get install -y git

RUN curl -sSL https://git.io/v2262 | sh

WORKDIR /usr/src/ghost 

RUN npm install
