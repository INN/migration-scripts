-- Delete spam comments for a blog ID
set @blogID = ##;

-- Create temporary table to hold spam comment IDs
drop temporary table if exists spam_comment_ids;
SET @temporaryTableCreate = CONCAT(
  'create temporary table if not exists spam_comment_ids select comment_ID from wp_',
  @blogID, '_comments where comment_approved = "spam";'
);
PREPARE temporaryTableCreate FROM @temporaryTableCreate;
EXECUTE temporaryTableCreate;
DEALLOCATE PREPARE temporaryTableCreate;

-- Delete comment meta for spam comments
SET @deleteCommentMeta = CONCAT(
  'delete wp_', @blogID, '_commentmeta from wp_', @blogID,
  '_commentmeta where comment_id in (select comment_ID from spam_comment_ids);');
PREPARE deleteCommentMeta FROM @deleteCommentMeta;
EXECUTE deleteCommentMeta;
DEALLOCATE PREPARE deleteCommentMeta;

-- Delete spam comments
SET @deleteComments = CONCAT(
  'delete wp_', @blogID, '_comments from wp_', @blogID,
  '_comments where comment_ID in (select comment_ID from spam_comment_ids);');
PREPARE deleteComments FROM @deleteComments;
EXECUTE deleteComments;
DEALLOCATE PREPARE deleteComments;

-- Clean up
drop temporary table if exists spam_comment_ids;
