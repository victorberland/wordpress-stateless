# Stateless WordPress
Docker image for running WordPress on non-persistent stateless containers. Tested in a Kubernetes cluster and on Scaleway serverless containers.

## Includes
- Redis
- WP Super Cache
- Akismet

## How it works

### What does this mean in practice?
- Theme changes are pushed to the image at build
- Plugins can be downloaded and updated in wp-admin as one usually would
- Media uploads are stored in object storage

## You will also need
- A MySQL database. Most cloud providers offer managed databases.
- An Object Storage provider for media uploads and a plugin to handle uploads. Tested with https://deliciousbrains.com/wp-offload-media/, but there are other similar plugins available.

## Built-in plugins
The `plugins` folder contains the `stateless` plugin which creates the API-route used for plugin syncing.
The `amazon-s3-and-cloudfront-tweaks.php` file is used to configure the WP Offload Media plugin for Scaleway Object Storage. If you're not using that plugin or Scaleway, you can remove it.
Other files added to this folder will automatically be copied to the plugins folder in the built image.

## In your project repository
Create a `Dockerfile` file with the following contents:
```dockerfile
FROM ghcr.io/victorberland/wordpress-stateless:latest
RUN get-plugins.sh https://example.com
COPY --chown=www-data:www-data wp-content /var/www/html/wp-content
```
Replace `https://example.com` with the URL of your WordPress site.

### GitHub Actions Workflow example
If you are using GitHub Actions, you can use the following workflow to build and push the image to GitHub Container Registry by creating a `.github/workflows/build.yml` file with the following contents:
```yaml
name: Build and push to registry
on:
  push:
    branches: [master]
  workflow_dispatch:
jobs:
  docker:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.run_number }}, ghcr.io/${{ github.repository }}:latest
```
This will build the image and push it to GitHub Container Registry with the tag `latest` as well as the run number for versioning.

Make sure to create a secret named `STATELESS_PLUGINS_KEY` with a random string value. This must match the value of the `STATELESS_PLUGINS_KEY` environment variable in your WordPress container.

## Environment variables
- `WORDPRESS_DB_HOST` Database host and port
- `WORDPRESS_DB_NAME`
- `WORDPRESS_DB_USER`
- `WORDPRESS_DB_PASSWORD` Database password
- `STATELESS_PLUGINS_KEY` Random string used for the plugin syncing step.
You can also specify any other environment variables supported by the official WordPress image.
