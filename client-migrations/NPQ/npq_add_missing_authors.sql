-- In `npq_update_patch_2015_06_12.sql` we removed all subscribers.
-- However, some of those subscribers had somehow authored posts.
-- So, here we add back the two subscribers with posts and correct the
-- post_author ID for their posts.

-- Checked for new max user meta id and user id.
-- NOTE: These are different from those specified in `npq_prepare_standalone_production.sql`
-- and `npq_update_patch_2015_06_12.sql`.
SET @newUmetaID = 5760723 + 10000;
SET @newUserID = 2563112 + 1000;

-- Insert missing authors
INSERT INTO `wp_users` (`ID`, `user_login`, `user_pass`, `user_nicename`, `user_email`, `user_url`, `user_registered`, `user_activation_key`, `user_status`, `display_name`, `spam`, `deleted`)
VALUES
(56671 + @newUserID, 'Nadia Pflaum', '$P$DLVSq4prYq2MONk/YfcRUal96c5iUf/', 'NadiaPflaum', 'nadiapflaum@gmail.com', '', '2015-04-15 16:41:52', '', 0, 'Nadia Pflaum', 0, 0),
(56845 + @newUserID, 'Debbie Laskey', '$P$DWPZb82TcmPjsOn92fYoHZVivDfzdM.', 'DLaskey', 'brandczar@att.net', '', '2015-05-14 15:15:18', '', 0, 'Debbie Laskey', 0, 0);

-- Insert missing author meta
INSERT INTO `wp_usermeta` (`umeta_id`, `user_id`, `meta_key`, `meta_value`)
VALUES
	(75531 + @newUmetaID, 56671 + @newUserID, 'first_name', ' '),
	(75532 + @newUmetaID, 56671 + @newUserID, 'last_name', ' '),
	(75533 + @newUmetaID, 56671 + @newUserID, 'nickname', 'Nadia Pflaum'),
	(75534 + @newUmetaID, 56671 + @newUserID, 'wp_capabilities', 'a:1:{s:10:\"subscriber\";s:1:\"1\";}'),
	(76216 + @newUmetaID, 56845 + @newUserID, 'first_name', ' '),
	(76217 + @newUmetaID, 56845 + @newUserID, 'last_name', ' '),
	(76218 + @newUmetaID, 56845 + @newUserID, 'nickname', 'Debbie Laskey'),
	(76219 + @newUmetaID, 56845 + @newUserID, 'wp_capabilities', 'a:1:{s:10:\"subscriber\";s:1:\"1\";}');

-- Assign Debbie's posts to the right user
update wp_56_posts set post_author = @newUserID + 56845 where post_author = 2619957;
-- Assign Nadia's posts to the right user
update wp_56_posts set post_author = @newUserID + 56671 where post_author = 2619783;
