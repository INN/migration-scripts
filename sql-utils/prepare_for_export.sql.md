## Assumptions

You're familiar with [INN/deploy-tools' fabric commands](https://github.com/INN/deploy-tools/blob/master/COMMANDS.md).

You're doing this on WPEngine.

## Steps

1. Find the ID of the site in the multisite instance you desire to export. 
	1. Log into the site and go to the dashboard
	2. In the admin bar, find the site's name and hover over it. Find the "Edit site" entry. Copy the URL.
	3. The site's ID is in the URL's `id` parameter: http://example.com/wp-admin/network/site-info.php?id=**57**
2. Open phpMyAdmin for the site
	1. Go to https://my.wpengine.com
	2. Select the Account that owns the WordPress install you're extracting from
	3. Choose the install. You should be taken to a URL that looks like this: https://my.wpengine.com/installs/example
	4. Find "Links to: phpMyAdmin" somewhere on the install's page and click it.
3. Export the tables for the site with the ID
	1. In the "Structure" tab of phpMyAdmin, choose **all** tables containing the ID
	2. For example, for a site with ID of 12 choose wp_12_commentmeta, wp_12_comments, wp_12_links, wp_12_options, wp_12_postmeta, wp_12_posts, wp_12_term_relationships, wp_12_term_taxonomy, wp_12_terms
	3. At the bottom of the list, from "With these:" choose "Export"
	4. In the export page, also select `wp_users` and `wp_usermeta` from the list of tables. The `prepare_for_export.sql` script will trim these down to just tthe single site's users.
	5. Leave the defaults as they are
	6. Press go
	7. Save the database where you know where it is.
4. Load the db
	1. `fab vagrant.create_db:migration`
	2. `fab vagrant.load_db:/tmp/example.sql,migration`
5. Prepare the script
	- Replace the `##` in https://github.com/INN/migration-scripts/blob/master/sql-utils/prepare_for_export.sql with `id`
	- Add lines for any numbered tables exported that are not in the database.
	- Save the script someplace where you know where it is.
6. Run the script.
	1. Sequel Pro isn't necessary to run this script, so use whatever tool works for you.
	2. Open Sequel Pro and choose the server option for your vagrant machine
	3. From the drop-down, choose `migration`, the DB we're doing all this in
	4. Copy the script with `cat prepare_for_export.sql | pbcopy`
	5. Paste the script into Sequel Pro's query window
	6. Select all lines (Mac: Command-a)
	7. Run all lines (Mac: Command-r)
	8. In the menus, Database > Refresh tables
	9. Does everything look like a single-site instance? Everything runs with honor? Good!
7. Export the database.
	1. `fab vagrant.dump_db:/tmp/migration.sql,migration`
8. Create a new WPEngine install for the new site
8. Upload the exported post-migration database to your new site
	1. Find the phpMyAdmin page for your new site
	2. On the "Import" tab, choose the database.
	3. Proceed to upload the thing. This only works for files less than 500MB in size.
	4. In the table wp_options, replace the site URL and home URL with the enw correct values.
9. Delete the vagrant database
	1. `fab vagrant.destroy_db:migration`