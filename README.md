# Serverless WordPress
Docker image for running WordPress on non-persistent serverless containers. Tested on Scaleway.
Includes Redis and has WP_CACHE enabled.

Uses Unison with an external server (connection over SSH, server must have the Unison package installed) for syncing files.

Still a WIP, but feedback is appreciated.

Minimum usable resource plan on Scaleway is 512 MB - 280 mVCPU plan, but could do with more CPU power for a nicer admin experience. A frontend caching plugin must be used for a good user experience.

# Usage
Either build the image yourself or pull from `rg.fr-par.scw.cloud/4x0-net/wordpress-serverless:latest`

## Environment variables

### Serverless specific
- `SSH_HOST` Your SSH endpoint with Unison installed
- `SSH_PORT`
- `SSH_USERNAME`
- `SSH_PASSWORD` **Set as secret**


### Default Docker WordPress
- `WORDPRESS_DB_HOST` Host and port
- `WORDPRESS_DB_NAME`
- `WORDPRESS_DB_USER`
- `WORDPRESS_DB_PASSWORD` **Set as secret**
