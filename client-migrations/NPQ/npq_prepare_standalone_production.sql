-- REMEMBER: After loading the prepared tables into vagrant, staging or production --
-- Check siteurl, home, upload_url_path in wp_NEWBLOGID_options table.
-- Change wp_user_roles to wp_NEWBLOGID_user_roles in wp_NEWBLOGID_options table.

-- Prefixes are needed to push the new users/usermeta values outside of the range already populated
-- in the database, usually for a site with an ID of 40 using 40,000 will work pretty well (unless
-- some of your sites have a lot of users).

-- Set the `@newUserID` and `@newUmetaID` to something sufficiently high.
-- Try running:
-- SELECT max(umeta_id) FROM wp_usermeta;
-- and
-- SELECT max(ID) FROM wp_users;
-- to get an idea of where to start.
SET @newUmetaID = 5760723;
SET @newUserID = 2563112;
SET @newBlogID = 56;

-- DON'T CHANGE STUFF BELOW THIS LINE ---

-- Rename tables
SET @renameTablesStatement = CONCAT('RENAME TABLE wp_commentmeta TO wp_', @newBlogID, '_commentmeta;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_comments TO wp_', @newBlogID, '_comments;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

-- SET @renameTablesStatement = CONCAT('RENAME TABLE wp_links TO wp_', @newBlogID, '_links;');
-- PREPARE renameTablesStatement FROM @renameTablesStatement;
-- EXECUTE renameTablesStatement;
-- DEALLOCATE PREPARE renameTablesStatement;

-- SET @renameTablesStatement = CONCAT('RENAME TABLE wp_options TO wp_', @newBlogID, '_options;');
-- PREPARE renameTablesStatement FROM @renameTablesStatement;
-- EXECUTE renameTablesStatement;
-- DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_postmeta TO wp_', @newBlogID, '_postmeta;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_posts TO wp_', @newBlogID, '_posts;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_term_relationships TO wp_', @newBlogID, '_term_relationships;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_term_taxonomy TO wp_', @newBlogID, '_term_taxonomy;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_terms TO wp_', @newBlogID, '_terms;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

 -- Add two columns to the end of the wp_users table, spam and deleted. Both are TINYINT(2).
ALTER TABLE wp_users ADD spam tinyint(2) default 0;
ALTER TABLE wp_users ADD deleted tinyint(2) default 0;

-- Update the user ID's
UPDATE wp_users SET ID = ID + @newUserID;
UPDATE wp_usermeta SET user_id = user_id + @newUserID;

-- Update the user meta ID's
UPDATE wp_usermeta SET umeta_id = umeta_id + @newUmetaID;
UPDATE wp_usermeta SET meta_key = CONCAT('wp_', @newBlogID, '_user_level') WHERE meta_key = 'wp_user_level';
UPDATE wp_usermeta SET meta_key = CONCAT('wp_', @newBlogID, '_capabilities') WHERE meta_key = 'wp_capabilities';

-- Set the post author ID's
SET @postAuthorStatement = CONCAT('UPDATE wp_', @newBlogID, '_posts SET post_author = post_author + ', @newUserID);
PREPARE postAuthorStatement FROM @postAuthorStatement;
EXECUTE postAuthorStatement;
DEALLOCATE PREPARE postAuthorStatement;

-- Usually you'll need to update links to uploaded files in the posts table,
-- depends on your configuration and version of WP
SET @postContentStatement = CONCAT(
  'UPDATE wp_', @newBlogID, '_posts SET post_content = replace(post_content, \'wp-content/uploads/\', \'wp-content/blogs.dir/', @newBlogID, '/files/\')');
PREPARE postContentStatement FROM @postContentStatement;
EXECUTE postContentStatement;
DEALLOCATE PREPARE postContentStatement;

SET @commentAuthorStatement = CONCAT('UPDATE wp_', @newBlogID, '_comments SET user_id = user_id + ', @newUserID);
PREPARE commentAuthorStatement FROM @commentAuthorStatement;
EXECUTE commentAuthorStatement;
DEALLOCATE PREPARE commentAuthorStatement;
