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

-- NOTE: SET POST ID
-- Set all ID's to an appropriate offset
-- select max(ID) from wp_56_posts;
SET @newPostID = 34797 + 100;
UPDATE wp_posts SET ID = ID + @newPostID;

-- NOTE: SET COMMENT ID
-- select max(comment_ID) from wp_56_comments;
SET @newCommentID = 12413 + 100;
UPDATE wp_comments SET comment_ID = comment_ID + @newCommentID;
UPDATE wp_comments SET comment_post_ID = comment_post_ID + @newPostID;

-- NOTE: Update object_id where object_id matches an ID in posts table
UPDATE wp_term_relationships a INNER JOIN wp_posts b
  ON b.ID = (a.object_id + @newPostID)
  SET a.object_id = (a.object_id + @newPostID);

-- NOTE: Delete records from wp_56_term_relationships that do not have a match in wp_56_posts
-- Helps avoid duplicate key errors when importing.
DELETE a.* FROM wp_term_relationships a
  LEFT OUTER JOIN wp_posts b
  ON b.ID = a.object_id WHERE b.ID IS NULL;

-- Delete records for posts they've added tags to since the post migration was imported.
DELETE FROM wp_56_term_relationships WHERE object_id in (61201,
61199,
61198,
61196,
61195,
61193,
60888,
60882,
60754,
60687,
60641);

-- NOTE: SET TERM TAX ID
-- select max(term_taxonomy_id) from wp_56_term_taxonomy;
SET @newTermTaxID = 14920 + 100;
UPDATE wp_term_taxonomy SET term_taxonomy_id = term_taxonomy_id + @newTermTaxID order by term_taxonomy_id desc;
UPDATE wp_term_relationships SET term_taxonomy_id = term_taxonomy_id + @newTermTaxID order by term_taxonomy_id desc;

-- NOTE: SET TERM ID
-- select max(term_id) from wp_56_terms;
SET @newTermID = 48143 + 100;
UPDATE wp_terms SET term_id = term_id + @newTermID order by term_id desc;
UPDATE wp_term_taxonomy set term_id = term_id + @newTermID order by term_id desc;


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

-- NOTE: We don't need to add these, since we're dealing with a SQL patch the tables must
-- be created with `sql-utils/wpdb_default_tables.sql`, which includes those columns.
-- Add two columns to the end of the wp_users table, spam and deleted. Both are TINYINT(2).
-- ALTER TABLE wp_users ADD spam tinyint(2) default 0;
-- ALTER TABLE wp_users ADD deleted tinyint(2) default 0;

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

-- Find the users that are not authors, editors or admins
-- and store their ID's in a temporary table. We'll delete
-- these user records.
DROP temporary TABLE IF EXISTS npq_delete_these_users;
CREATE TEMPORARY TABLE IF NOT EXISTS npq_delete_these_users
    SELECT ID FROM wp_users JOIN wp_usermeta ON ID = user_id
    WHERE meta_key = CONCAT('wp_', @newBlogID, '_capabilities')
    AND NOT (
        meta_value LIKE "%author%"
        OR meta_value LIKE "%editor%"
        OR meta_value LIKE "%administrator%"
    );

-- Delete user records where their ID exists in the
-- to-be-delete temporary table created above.
DELETE wp_users FROM wp_users JOIN npq_delete_these_users ON wp_users.ID = npq_delete_these_users.ID;

-- Also delete any user meta associated with the users
-- we want to scrub.
DELETE wp_usermeta FROM wp_usermeta join npq_delete_these_users on user_id = ID;

-- Go back through and delete user meta for records
-- that have no match in the wp_users table.
DELETE wp_usermeta FROM wp_usermeta
    LEFT OUTER JOIN wp_users ON user_id = ID
    WHERE ID IS NULL;
