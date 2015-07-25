# unblibraries/drupal
Simple, extensible Drupal docker container. Leverages the phusion/baseimage my_init system.

This image builds and installs Drupal using the embedded profile from scratch if a database and filesystem is not found.

If a persistent filesystem is used and a previous build and database is found, the image defined makefile is built and applied to the current instance, overwriting the existing filesystem. This allows in-place upgrades only by updating the makefile.

## Usage
```
docker run \
       --rm \
       --name drupal \
       -e MYSQL_HOSTNAME= \
       -e MYSQL_ROOT_PASSWORD= \
       -v /local/dir:/usr/share/nginx \
       -p 80:80 \
       unblibraries/drupal
```

## Runtime/Environment Variables

### Standard Deployment and Updates
* `MYSQL_HOSTNAME` - (Required) The hostname of the MySQL server for the Drupal site
* `MYSQL_ROOT_PASSWORD` - (Required) The root password for the above server

### Cloning an Existing Instance
If key based access SSH is enabled on the server of an existing Drupal instance, the init process can clone that instance to the docker container. All of the following environment variables must be set, or the init script will not attempt to clone that instance. Please ensure that the makefile and profiles defined for the container match that of the existing instance, or erratic behavior will occur within the container.
* `DRUSH_TRANSFER_USER` - (Optional) The user account on the existing server.
* `DRUSH_TRANSFER_KEY` - (Optional) The contents of the private keyfile used to authenticate to the existing server.
* `DRUSH_TRANSFER_HOST` - (Optional) The hostname of the existing server.
* `DRUSH_TRANSFER_PATH` - (Optional) The path on the server to the existing Drupal installation.
* `DRUSH_TRANSFER_URI` - (Optional) The URI (usually 'default') of the existing instance.

## License
- unblibraries/drupal is licensed under the MIT License:
  - [http://opensource.org/licenses/mit-license.html](http://opensource.org/licenses/mit-license.html)
- Attribution is not required, but much appreciated:
  - `Drupal Docker Container by UNB Libraries`
