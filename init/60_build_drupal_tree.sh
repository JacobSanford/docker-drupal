#!/usr/bin/env bash

# Here, we default to using the address from a linked container named 'mysql', falling back to using the
# details provided through MYSQL_HOSTNAME and MYSQL_PORT environment variables.
MYSQL_PORT_3306_TCP_ADDR="${MYSQL_PORT_3306_TCP_ADDR:-$(echo $MYSQL_HOSTNAME)}"
MYSQL_PORT_3306_TCP_PORT="${MYSQL_PORT_3306_TCP_PORT:-$(echo $MYSQL_PORT)}"

# Check if this is a new deployment.
if [[ ! -f /tmp/DRUPAL_DB_LIVE && ! -f /tmp/DRUPAL_FILES_LIVE ]];
then
  # Site needs building and site-install.
  rm -rf ${DRUPAL_ROOT}/*
  cd ${DRUPAL_ROOT}
  drush make --concurrency=${DRUSH_MAKE_CONCURRENCY} --yes "/tmp/drupal_build/$DRUPAL_SITE_ID.makefile" ${DRUSH_MAKE_OPTIONS}

  # Create Database.
  mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_PORT_3306_TCP_ADDR} -P ${MYSQL_PORT_3306_TCP_PORT} -e "DROP DATABASE IF EXISTS ${DRUPAL_SITE_ID}_db; CREATE DATABASE ${DRUPAL_SITE_ID}_db; GRANT ALL PRIVILEGES ON ${DRUPAL_SITE_ID}_db.* TO '${DRUPAL_SITE_ID}_user'@'%' IDENTIFIED BY '$DRUPAL_DB_PASSWORD'; FLUSH PRIVILEGES;"

  # Perform site-install.
  cd ${DRUPAL_ROOT}
  cp -r /tmp/drupal_build/$DRUPAL_SITE_ID/ profiles/
  drush site-install $DRUPAL_SITE_ID -y --account-name=${DRUPAL_ADMIN_ACCOUNT_NAME} --account-pass=${DRUPAL_ADMIN_ACCOUNT_PASS} --db-url="mysqli://${DRUPAL_SITE_ID}_user:$DRUPAL_DB_PASSWORD@${MYSQL_PORT_3306_TCP_ADDR}:${MYSQL_PORT_3306_TCP_PORT}/${DRUPAL_SITE_ID}_db"

# See if the instance appears to have previously been deployed
elif [[ -f /tmp/DRUPAL_DB_LIVE && -f /tmp/DRUPAL_FILES_LIVE ]];
then
  # Site Needs Upgrade
  echo "Database Exists and Files Found, Updating Existing Site"

  # Ensure the database details are still valid.
  sed -i "s|'host' => '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}',|'host' => '$MYSQL_PORT_3306_TCP_ADDR',|g" ${DRUPAL_ROOT}/sites/default/settings.php
  sed -i "s|'port' => '[0-9]\{2,4\}',|'port' => '$MYSQL_PORT_3306_TCP_PORT',|g" ${DRUPAL_ROOT}/sites/default/settings.php

  rm -rf /tmp/html
  mkdir /tmp/html
  cd /tmp/html

  # Make the site to a temporary build location
  drush make --yes "/tmp/drupal_build/$DRUPAL_SITE_ID.makefile"

  # Copy the install profile to the live dir. Since this isn't used in a existing deployment, this is mainly to be tidy.
  cp -r /tmp/drupal_build/$DRUPAL_SITE_ID/ /tmp/html/profiles/
  cd ..

  # Rsync newly deployed site files on top of one one.
  chown ${WEBSERVER_USER_ID}:${WEBSERVER_USER_ID} -R /tmp/html
  rsync --verbose --recursive --exclude=sites/default/files/ --exclude=sites/default/settings.php --exclude=profiles/$DRUPAL_SITE_ID --perms --delete --omit-dir-times --chmod=o+r /tmp/html/ ${DRUPAL_ROOT}

  # Apply database updates, if they exist.
  drush --yes --root=${DRUPAL_ROOT} --uri=default updb

else
  # Inconsistency detected, do nothing to avoid data loss.
  echo "Something seems odd with the Database and Filesystem, cowardly refusing to do anything"
fi
