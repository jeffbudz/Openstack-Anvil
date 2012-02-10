## Based off of split glance-api-paste.ini commit 30439a6dc4
## And split glance-api.conf commit 30439a6dc4

[DEFAULT]
# Show more verbose log output (sets INFO log level output)
verbose = True

# Show debugging output in logs (sets DEBUG log level output)
debug = False

# Which backend store should Glance use by default is not specified
# in a request to add a new image to Glance? Default: 'file'
# Available choices are 'file', 'swift', and 's3'
default_store = file

# Address to bind the API server
bind_host = 0.0.0.0

# Port the bind the API server to
bind_port = 9292

# Address to find the registry server
registry_host = 0.0.0.0

# Port the registry server is listening on
registry_port = 9191

# Log to this file. Make sure you do not set the same log
# file for both the API and registry servers!
#log_file = %DEST%/glance/api.log

# Send logs to syslog (/dev/log) instead of to file specified by `log_file`
use_syslog = %SYSLOG%

# ============ Notification System Options =====================

# Notifications can be sent when images are create, updated or deleted.
# There are three methods of sending notifications, logging (via the
# log_file directive), rabbit (via a rabbitmq queue) or noop (no
# notifications sent, the default)
notifier_strategy = noop

# Configuration options if sending notifications via rabbitmq (these are
# the defaults)
rabbit_host = localhost
rabbit_port = 5672
rabbit_use_ssl = false
rabbit_userid = guest
rabbit_password = guest
rabbit_virtual_host = /
rabbit_notification_topic = glance_notifications

# ============ Filesystem Store Options ========================

# Directory that the Filesystem backend store
# writes image data to
filesystem_store_datadir = %DEST%/glance/images/

# ============ Swift Store Options =============================

# Address where the Swift authentication service lives
swift_store_auth_address = 127.0.0.1:8080/v1.0/

# User to authenticate against the Swift authentication service
swift_store_user = jdoe

# Auth key for the user authenticating against the
# Swift authentication service
swift_store_key = a86850deb2742ec3cb41518e26aa2d89

# Container within the account that the account should use
# for storing images in Swift
swift_store_container = glance

# Do we create the container if it does not exist?
swift_store_create_container_on_put = False

# What size, in MB, should Glance start chunking image files
# and do a large object manifest in Swift? By default, this is
# the maximum object size in Swift, which is 5GB
swift_store_large_object_size = 5120

# When doing a large object manifest, what size, in MB, should
# Glance write chunks to Swift? This amount of data is written
# to a temporary disk buffer during the process of chunking
# the image file, and the default is 200MB
swift_store_large_object_chunk_size = 200

# Whether to use ServiceNET to communicate with the Swift storage servers.
# (If you aren't RACKSPACE, leave this False!)
#
# To use ServiceNET for authentication, prefix hostname of
# `swift_store_auth_address` with 'snet-'.
# Ex. https://example.com/v1.0/ -> https://snet-example.com/v1.0/
swift_enable_snet = False

# ============ S3 Store Options =============================

# Address where the S3 authentication service lives
s3_store_host = 127.0.0.1:8080/v1.0/

# User to authenticate against the S3 authentication service
s3_store_access_key = <20-char AWS access key>

# Auth key for the user authenticating against the
# S3 authentication service
s3_store_secret_key = <40-char AWS secret key>

# Container within the account that the account should use
# for storing images in S3. Note that S3 has a flat namespace,
# so you need a unique bucket name for your glance images. An
# easy way to do this is append your AWS access key to "glance".
# S3 buckets in AWS *must* be lowercased, so remember to lowercase
# your AWS access key if you use it in your bucket name below!
s3_store_bucket = <lowercased 20-char aws access key>glance

# Do we create the bucket if it does not exist?
s3_store_create_bucket_on_put = False

# ============ Image Cache Options ========================

image_cache_enabled = False

# Directory that the Image Cache writes data to
# Make sure this is also set in glance-pruner.conf
image_cache_datadir = /var/lib/glance/image-cache/

# Number of seconds after which we should consider an incomplete image to be
# stalled and eligible for reaping
image_cache_stall_timeout = 86400

# ============ Delayed Delete Options =============================

# Turn on/off delayed delete
delayed_delete = False

# Delayed delete time in seconds
scrub_time = 43200

# Directory that the scrubber will use to remind itself of what to delete
# Make sure this is also set in glance-scrubber.conf
scrubber_datadir = /var/lib/glance/scrubber

## SPLIT HERE ##
## SPLIT HERE ##
## SPLIT HERE ##

[pipeline:glance-api]
#pipeline = versionnegotiation context apiv1app
# NOTE: use the following pipeline for keystone
pipeline = versionnegotiation authtoken auth-context apiv1app

# To enable Image Cache Management API replace pipeline with below:
# pipeline = versionnegotiation context imagecache apiv1app
# NOTE: use the following pipeline for keystone auth (with caching)
# pipeline = versionnegotiation authtoken auth-context imagecache apiv1app

[app:apiv1app]
paste.app_factory = glance.common.wsgi:app_factory
glance.app_factory = glance.api.v1.router:API

[filter:versionnegotiation]
paste.filter_factory = glance.common.wsgi:filter_factory
glance.filter_factory = glance.api.middleware.version_negotiation:VersionNegotiationFilter

[filter:cache]
paste.filter_factory = glance.common.wsgi:filter_factory
glance.filter_factory = glance.api.middleware.cache:CacheFilter

[filter:cachemanage]
paste.filter_factory = glance.common.wsgi:filter_factory
glance.filter_factory = glance.api.middleware.cache_manage:CacheManageFilter

[filter:context]
paste.filter_factory = glance.common.wsgi:filter_factory
glance.filter_factory = glance.common.context:ContextMiddleware

[filter:authtoken]
paste.filter_factory = keystone.middleware.auth_token:filter_factory
service_host = %KEYSTONE_SERVICE_HOST%
service_port = %KEYSTONE_SERVICE_PORT%
service_protocol = %KEYSTONE_SERVICE_PROTOCOL%
auth_host = %KEYSTONE_AUTH_HOST%
auth_port = %KEYSTONE_AUTH_PORT%
auth_protocol = %KEYSTONE_AUTH_PROTOCOL%
auth_uri = %KEYSTONE_SERVICE_PROTOCOL%://%KEYSTONE_SERVICE_HOST%:%KEYSTONE_SERVICE_PORT%/
admin_token = %SERVICE_TOKEN%

[filter:auth-context]
paste.filter_factory = glance.common.wsgi:filter_factory
glance.filter_factory = keystone.middleware.glance_auth_token:KeystoneContextMiddleware
