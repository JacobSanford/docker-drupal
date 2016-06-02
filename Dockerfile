FROM unblibraries/nginx-php:alpine-php7
MAINTAINER Jacob Sanford <libsystems_at_unb.ca>

ENV DRUPAL_ADMIN_ACCOUNT_NAME admin
ENV DRUPAL_CONFIGURATION_DIR ${APP_ROOT}/configuration
ENV DRUPAL_CONFIGURATION_EXPORT_SKIP devel
ENV DRUPAL_DEPLOY_CONFIGURATION FALSE
ENV DRUPAL_REBUILD_ON_REDEPLOY TRUE
ENV DRUPAL_REVERT_FEATURES FALSE
ENV DRUPAL_ROOT $APP_WEBROOT
ENV DRUPAL_SITE_ID defaultd
ENV DRUPAL_SITE_UUID FALSE
ENV DRUPAL_TESTING_TOOLS FALSE
ENV DRUSH_MAKE_CONCURRENCY 5
ENV DRUSH_MAKE_OPTIONS="--shallow-clone"
ENV DRUSH_VERSION 8.x
ENV TERM dumb
ENV TMP_DRUPAL_BUILD_DIR /tmp/drupal_build

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk --update add php7-mysqlnd@testing php7-session@testing php7-pdo@testing php7-pdo_mysql@testing php7-pcntl@testing php7-dom@testing php7-posix@testing php7-ctype@testing php7-gd@testing php7-xml@testing php7-opcache@testing php7-mbstring@testing git unzip mysql-client rsync && \
  rm -f /var/cache/apk/*

# Install Drush
RUN git clone https://github.com/drush-ops/drush.git /usr/local/src/drush && \
  cd /usr/local/src/drush && \
  git checkout ${DRUSH_VERSION} && \
  ln -s /usr/local/src/drush/drush /usr/bin/drush && \
  rm -rf /usr/local/src/drush/.git && \
  composer install

# Add nginx and PHP conf.
COPY conf/nginx/app.conf /etc/nginx/conf.d/app.conf
COPY conf/php/php.ini /etc/php7/php.ini
COPY conf/php/php-fpm.conf /etc/php7/php-fpm.conf
COPY conf/php/www.conf /etc/php7/php-fpm.d/www.conf

# Deploy the default makefile and install profile to the container
RUN mkdir -p ${TMP_DRUPAL_BUILD_DIR}
COPY build/ ${TMP_DRUPAL_BUILD_DIR}
COPY tests/behat.yml ${TMP_DRUPAL_BUILD_DIR}/behat.yml
COPY tests/features ${TMP_DRUPAL_BUILD_DIR}/features

# Drush-make the site.
ENV DRUSH_MAKE_TMPROOT ${TMP_DRUPAL_BUILD_DIR}/webroot
RUN drush make --concurrency=${DRUSH_MAKE_CONCURRENCY} --yes ${DRUSH_MAKE_OPTIONS} "${TMP_DRUPAL_BUILD_DIR}/${DRUPAL_SITE_ID}.yml" ${DRUSH_MAKE_TMPROOT} && \
  mv ${TMP_DRUPAL_BUILD_DIR}/${DRUPAL_SITE_ID} ${DRUSH_MAKE_TMPROOT}/profiles/ && \
  mkdir -p ${DRUSH_MAKE_TMPROOT}/sites/all && \
  mv ${TMP_DRUPAL_BUILD_DIR}/settings ${DRUSH_MAKE_TMPROOT}/sites/all/ && \
  rm -rf ~/.drush/*

COPY scripts /scripts
COPY scripts/drupalCron.sh /etc/periodic/15min/drupalCron
