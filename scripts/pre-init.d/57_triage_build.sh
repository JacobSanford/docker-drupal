#!/usr/bin/env sh
# Triage the build to determine how to deploy.

# Remove old file markers to eliminate false positives
rm -rf /tmp/DRUPAL_DB_LIVE
rm -rf /tmp/DRUPAL_FILES_LIVE

# Check if the Drupal database has been populated with data.
RESULT=`mysqlshow -h ${MYSQL_HOSTNAME} -P ${MYSQL_PORT} --user=${DRUPAL_SITE_ID}_user --password=$DRUPAL_DB_PASSWORD | grep -v Wildcard | grep -o ${DRUPAL_SITE_ID}_db`
if [ "$RESULT" == "${DRUPAL_SITE_ID}_db" ]; then
  touch /tmp/DRUPAL_DB_LIVE
  echo "Triage : Found Drupal Database."
fi

# Determine if the site was previously built by checking for a settings.php file.
if [ -f ${DRUPAL_ROOT}/sites/default/settings.php ]; then
  touch /tmp/DRUPAL_FILES_LIVE
  echo "Triage : Found Drupal Filesystem."
fi
