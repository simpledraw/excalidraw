FROM node:14-alpine AS build
ARG NPM_TOKEN
WORKDIR /opt/node_app

RUN echo "@simpledraw:registry=https://npm.pkg.github.com/" > .npmrc
RUN echo "//npm.pkg.github.com/:_authToken=$NPM_TOKEN" >> .npmrc

COPY package.json yarn.lock  ./
RUN yarn add create-react-app
RUN yarn --ignore-optional

ARG NODE_ENV=production

COPY . .
COPY .env.production .
RUN ls -la .
RUN yarn build:app:docker

FROM nginx:1.21-alpine

COPY --from=build /opt/node_app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
