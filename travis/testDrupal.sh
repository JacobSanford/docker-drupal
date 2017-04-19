#!/usr/bin/env bash
# Runs Drupal tests.
docker exec dockerdrupal_drupal_1 drush --root=/app/html --uri=default en --yes simpletest
docker exec dockerdrupal_drupal_1 su nginx -s /bin/sh -c 'php /app/html/core/scripts/run-tests.sh --url http://127.0.0.1 --php /usr/bin/php --die-on-fail --class "\Drupal\user\Tests\UserLoginTest"'
docker exec dockerdrupal_drupal_1 su nginx -s /bin/sh -c 'php /app/html/core/scripts/run-tests.sh --url http://127.0.0.1 --php /usr/bin/php --die-on-fail --class "\Drupal\Tests\node\Functional\PageViewTest"'
docker exec dockerdrupal_drupal_1 su nginx -s /bin/sh -c 'php /app/html/core/scripts/run-tests.sh --url http://127.0.0.1 --php /usr/bin/php --die-on-fail --class "\Drupal\KernelTests\Core\File\UrlRewritingTest"'
docker exec dockerdrupal_drupal_1 su nginx -s /bin/sh -c 'php /app/html/core/scripts/run-tests.sh --url http://127.0.0.1 --php /usr/bin/php --die-on-fail --class "\Drupal\file\Tests\FilePrivateTest"'
docker exec dockerdrupal_drupal_1 drush --root=/app/html --uri=default pm-uninstall --yes simpletest
