-- This SQL file will remove all users for a specific blog from the network tables (`wp_users` and `wp_usermeta`)
-- Set the value of `@newBlogID` to the ID of the blog for which you want to remove all users.
-- Useful for reimporting content and users/rerunning a migration.
@newBlogID = TKTK;

DROP TEMPORARY TABLE IF EXISTS temp_user_ids;
CREATE TEMPORARY TABLE IF NOT EXISTS temp_user_ids SELECT user_id as ID FROM wp_usermeta WHERE meta_key = CONCAT('wp_', @newBlogID, '_capabilities');

DELETE FROM wp_users WHERE ID in (SELECT ID from temp_user_ids);
DELETE FROM wp_usermeta WHERE user_id in (SELECT ID from temp_user_ids);

DROP TEMPORARY TABLE IF EXISTS temp_user_ids;