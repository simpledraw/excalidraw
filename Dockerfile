FROM node:14-alpine AS build
ARG NPM_TOKEN
ARG NODE_ENV=production
WORKDIR /opt/node_app

COPY . .
COPY package.json package-lock.json  ./
RUN npm install -g create-react-app

RUN echo "@simpledraw:registry=https://npm.pkg.github.com/" > .npmrc
RUN echo "//npm.pkg.github.com/:_authToken=$NPM_TOKEN" >> .npmrc

RUN npm ci
RUN npm run build:app:docker

FROM nginx:1.21-alpine

COPY --from=build /opt/node_app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
