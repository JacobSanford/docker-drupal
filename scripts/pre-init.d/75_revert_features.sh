#!/usr/bin/env sh
if [ "$DRUPAL_REVERT_FEATURES" == "TRUE" ]; then
  drush --root=${DRUPAL_ROOT} --uri=default --yes fra
fi;
