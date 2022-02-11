#!/bin/bash

# steps to generate a functional static dump of the grav site

### SETTINGS ###
GRAV_PATH="~/testarea/nginx_letsencrypt_php/html/"
STATIC_PATH="../static"

# go to the web server root
cd $GRAV_PATH

# clear cache? doesnt seem to be needed
docker exec -it -u $(id -u) nginx_letsencrypt_php_php-fpm_1 bin/grav clearcache

# remove old static dump to get rid of deleted files
rm -r $STATIC_PATH/*

# dump site to static html using blackhole plugin https://github.com/7barry/grav-plugin-blackhole
docker exec -it -u $(id -u) nginx_letsencrypt_php_php-fpm_1 bin/plugin blackhole generate -a -d nbis-static.dahlo.se -p /static/ https://www-new.nbis.se

# generate index for client side searching using static generator plugin https://github.com/OleVik/grav-plugin-static-generator
docker exec -it -u $(id -u) nginx_letsencrypt_php_php-fpm_1 bin/plugin static-generator index "/" -c /static/

# remove localhost part from url in search index
sed -i 's/http:\\\/\\\/localhost//g' $STATIC_PATH/index.full.json

# compress json file? https://stackoverflow.com/questions/62632354/is-there-any-way-to-load-a-compressed-json-file-with-javascript
#gzip $STATIC_PATH/index.full.json

# copy entire theme directory to static location to fix missing files/fonts etc
cp -r user/themes/quark/* $STATIC_PATH/user/themes/quark/

# minify everything possible https://github.com/tdewolff/minify
#../../minify/minify -a --recursive -o /tmp/minified/ user/data/blackhole/ ; cp -r /tmp/minified/blackhole/* user/data/blackhole/ ; rm -rf /tmp/minified

# create a .nojekyll file in the root to avoid github pages trying to build the project
touch $STATIC_PATH/.nojekyll

# add CNAME file to configure custom domain
echo "nbis-static.dahlo.se" > $STATIC_PATH/CNAME

# add, commit and push changes to github
cd $STATIC_PATH/ ; git add -A ; git commit -am "update" ; git push ; cd -


