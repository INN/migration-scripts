-- WARNING: THIS SCRIPT IS DESRTUCTIVE. DO NOT RUN AGAINST ANY PRODUCTION DATABASES (OR ANY
-- OTHER DATABASE YOU CARE ABOUT PRESERVING).
--
-- This script is meant to prepare a blog's tables to be moved to a
-- standalone WP install. It requires on the blogs tables and the network
-- tables (wp_users and wp_usermeta) be present in the database.
--
-- It does two things:
--
-- 1. Renames all of the blog tables to standard WordPress blog tables (e.g., wp_16_posts to wp_posts)
-- 2. Deletes all user data from wp_users and wp_usermeta that are not added to the multisite blog
--    which is being prepped for export.
--
-- Set the @blogID variable and away you go!
SET @blogID = '##';

-- Rename all the wp_##_* tables to wp_ tables
-- Depending on the site, you may need to rename other tables (e.g., redirection tables, other
-- plugin tables, etc.)
SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_commentmeta TO wp_commentmeta;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_comments TO wp_comments;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_links TO wp_links;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_options TO wp_options;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_postmeta TO wp_postmeta;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_posts TO wp_posts;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_term_relationships TO wp_term_relationships;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_term_taxonomy TO wp_term_taxonomy;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_termmeta TO wp_termmeta;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

SET @renameTablesStatement = CONCAT('RENAME TABLE wp_', @blogID, '_terms TO wp_terms;');
PREPARE renameTablesStatement FROM @renameTablesStatement;
EXECUTE renameTablesStatement;
DEALLOCATE PREPARE renameTablesStatement;

-- Change the wp_##_user_roles key in wp_options
update wp_options set option_name = 'wp_user_roles' where option_name like 'wp_%_user_roles';

-- Drop users that don't belong to this blog
drop temporary table if exists blog_user_ids;
SET @blogUserIDTable = CONCAT(
  'create temporary table if not exists blog_user_ids select user_id from wp_usermeta where meta_key = "wp_', @blogID, '_capabilities"');
PREPARE blogUserIDTable FROM @blogUserIDTable;
EXECUTE blogUserIDTable;
DEALLOCATE PREPARE blogUserIDTable;

delete wp_users from wp_users
  left outer join blog_user_ids
  on wp_users.ID = blog_user_ids.user_id
  where blog_user_ids.user_id is null;

delete wp_usermeta from wp_usermeta
  left outer join blog_user_ids
  on wp_usermeta.user_id = blog_user_ids.user_id
  where blog_user_ids.user_id is null;

-- this needs to have `##` replaced, and should probably be using the statement syntax from above so we can use @blogID
DELETE from wp_usermeta where meta_key LIKE 'wp\_%' and meta_key NOT LIKE 'wp\_##%';
UPDATE `wp_usermeta` SET `meta_key` = REPLACE(`meta_key`, 'wp_##_', 'wp_') WHERE `meta_key` LIKE '%wp_##_%';
