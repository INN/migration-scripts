<?php
/**
 * Apply the 0.5 update to sites with current `largo_version` of 0.4
 */

if ($_SERVER['REQUEST_METHOD'] !== 'GET')
	print "Invalid request method.";

include_once dirname(__FILE__) . '/inc/load.php';

function main() {
	header('HTTP/1.1 200 OK', true, 200);
	$blogs = wp_get_sites();
	include_once WP_CONTENT_DIR . '/themes/largo-dev/inc/custom-less-variables.php';

	foreach ($blogs as $idx => $blog) {
		switch_to_blog($blog['blog_id']);

		if (function_exists('largo_version')) {
			$stored_version = of_get_option('largo_version');

			if ($stored_version == '0.4' && largo_version() == '0.5') {
				$ret = largo_perform_update();
				if (!empty($ret))
					print "Succesfully updated: " . $blog['domain'] . "\n";
				else
					print "Error updating: " . $blog['domain'] . "\n";
			}
		}

		restore_current_blog();
	}

	die();
}

main();
