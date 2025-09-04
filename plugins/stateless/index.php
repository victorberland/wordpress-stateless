<?php
/*
 * Plugin Name: Stateless WP
 * Description: Functions to make WordPress work in a stateless environment
 * Version: 1.0
 * Author: 4x0
 */

function stateless_get_plugins() {
  require_once( dirname( dirname( dirname( dirname( __FILE__ ) ) ) ) . '/wp-load.php' );

  // zip up all plugins in the plugins directory
  $plugins = glob( WP_PLUGIN_DIR . '/*', GLOB_ONLYDIR );
  $zip = new ZipArchive();
  $zip_name = 'plugins.zip';
  $zip->open( $zip_name, ZipArchive::CREATE );

  // add all php files in the root of wp-content/plugins to the root of the zip
  $files = glob( WP_PLUGIN_DIR . '/*.php' );
  foreach ( $files as $file ) {
    $zip->addFile( $file, basename( $file ) );
  }

  // folders
  foreach ( $plugins as $plugin ) {
    $zip->addEmptyDir( basename( $plugin ) );
    $files = new RecursiveIteratorIterator(
      new RecursiveDirectoryIterator( $plugin ),
      RecursiveIteratorIterator::LEAVES_ONLY
    );
    foreach ( $files as $name => $file ) {
      if ( ! $file->isDir() ) {
        $filePath = $file->getRealPath();
        $relativePath = substr( $filePath, strlen( $plugin ) + 1 );
        $zip->addFile( $filePath, basename( $plugin ) . '/' . $relativePath );
      }
    }
  }
  $zip->close();

  // stream the file to the client
  if ( headers_sent() ) {
    echo 'HTTP header already sent';
  } else {
    if ( ! is_file( $zip_name ) ) {
      header( $_SERVER['SERVER_PROTOCOL'] . ' 404 Not Found' );
      echo 'File not found';
    } else if ( ! is_readable( $zip_name ) ) {
      header( $_SERVER['SERVER_PROTOCOL'] . ' 403 Forbidden' );
      echo 'File not readable';
    } else {
      header( $_SERVER['SERVER_PROTOCOL'] . ' 200 OK' );
      header( "Content-Type: application/zip" );
      header( "Content-Transfer-Encoding: Binary" );
      header( "Content-Length: " . filesize( $zip_name ) );
      header( "Content-Disposition: attachment; filename=\"" . basename( $zip_name ) . "\"" );
      readfile( $zip_name );
      unlink( $zip_name );
    }
  }
  exit;
}

if ( isset( $_GET['stateless_get_plugins'] ) && $_GET['stateless_get_plugins'] === getenv( 'STATELESS_PLUGINS_KEY' ) ) {
  stateless_get_plugins();
}
