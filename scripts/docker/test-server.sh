#!/bin/sh

MONICADIR=/var/www/monica
ARTISAN="php ${MONICADIR}/artisan"

if [[ -z ${APP_KEY:-} || "$APP_KEY" == "ChangeMeBy32KeyLengthOrGenerated" ]]; then
  ${ARTISAN} key:generate --no-interaction
else
  echo "APP_KEY already set"
fi
${ARTISAN} migrate --force
${ARTISAN} storage:link
${ARTISAN} db:seed --class ActivityTypesTableSeeder --force
${ARTISAN} db:seed --class CountriesSeederTable --force

# Ensure storage directories are present
STORAGE=${MONICADIR}/storage
mkdir -p ${STORAGE}/logs
mkdir -p ${STORAGE}/app/public
mkdir -p ${STORAGE}/framework/views
mkdir -p ${STORAGE}/framework/cache
mkdir -p ${STORAGE}/framework/sessions
chown -R monica:apache ${STORAGE}
chmod -R g+rw ${STORAGE}

# Run cron
crond -b &

# Run apache2
rm -f /run/apache2/httpd.pid
httpd -DFOREGROUND
