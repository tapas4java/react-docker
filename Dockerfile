############################################
## Docker file to build React application ##
## and package/run within ngnix container ##
############################################

## Use nginx alpine base image
FROM nginx:1.13.5-alpine

## Copy app specific nginx config
COPY nginx/default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## Install nodejs package from alpine repo
RUN apk add --no-cache nodejs

## Copy application package.json file
COPY package.json package-lock.json ./

## npm performance nits
RUN npm set progress=false &&\
    npm config set depth 0 &&\
    npm cache clean --force

## Storing node modules on a separate layer will prevent unnecessary npm installs for each build
RUN npm i &&\
    mkdir react-app &&\
    cp -rf node_modules react-app

## Set react-app as working directory
WORKDIR react-app

## Copy all source code from your host machine into container
COPY . .

## Build the react app in production mode and store the artifacts in build folder
RUN npm run build

## Copy over the artifacts in build folder to default nginx public folder
RUN cp -rf build/* /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]

# Expose ports.
EXPOSE 80 443
