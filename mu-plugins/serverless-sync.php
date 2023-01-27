<?php

/*
Plugin Name:  Serverless dataportal sync
Description:  Dataportal sync
Version:      1.0
Author:       4x0
*/

// add five_minutes cron interval
// add_filter( 'cron_schedules', function( $schedules ) {
// 		$schedules['five_minutes'] = array(
// 				'interval' => MINUTE_IN_SECONDS,
// 				'display'  => esc_html__( 'Once every five minutes' ),
// 		);
// 		return $schedules;
// });

// add cron job that runs every 5 minutes and runs the unison command
// add_action('init', function() {
// 		if (!wp_next_scheduled( 'serverless_sync')) {
// 				wp_schedule_event( time(), 'five_minutes', 'serverless_sync' );
// 		}
// });

add_action('serverless_sync', function() {
	$cmd = 'sshpass -p $SSH_PASSWORD unison -batch /var/www/html/wp-content ssh://$SSH_USERNAME@$SSH_HOST:$SSH_PORT/ -auto -dontchmod -ignorearchives -prefer newer -perms 0 -maxerrors 1000 >> /var/www/unison.log';
	shell_exec($cmd);
});


add_action('admin_menu', function() {
	add_menu_page('Serverless sync', 'Serverless sync', 'manage_options', 'serverless-sync', function() {
?>
<div class="wrap">
	<h1>Serverless sync</h1>
	<p>Syncs the uploads folder with the dataportal s3 bucket</p>

	<?php do_action('serverless_sync'); ?>

	<!-- list the contents of the unison log file in scrollable div -->
	<code style="overflow: scroll; height: 300px; width: 100%; max-width: 700px; display: block;">
		<?php
			$unison_log = file_get_contents('/var/www/unison.log');
			echo nl2br($unison_log);
		?>
	</code>
</div>
<?php
	});
});

?>
