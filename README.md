# Serverless WordPress
Docker image for running WordPress on non-persistent serverless containers. Tested on Scaleway.

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
- `SSH_PATH` Path to where Unison will sync. Leave blank to use home directory. Start with `/` for absolute path.


### Default Docker WordPress
- `WORDPRESS_DB_HOST` Host and port
- `WORDPRESS_DB_NAME`
- `WORDPRESS_DB_USER`
- `WORDPRESS_DB_PASSWORD` **Set as secret**
