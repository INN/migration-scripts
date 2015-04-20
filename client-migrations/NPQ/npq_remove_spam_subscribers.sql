drop temporary table if exists npq_active_user_emails;
create temporary table if not exists `npq_active_user_emails` (`user_email` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '');

-- Excluding the list of email addresses to avoid personal information
-- appearing in this repository. Follow the pattern below for importing
-- email addresses that should NOT be deleted.
-- insert into npq_active_user_emails (user_email) values
-- ('email@address.org'),
-- ('another_email@address.org');

drop temporary table if exists npq_active_user_ids;
create temporary table if not exists npq_active_user_ids
  select distinct(ID) from wp_users join npq_active_user_emails
  on wp_users.user_email = npq_active_user_emails.user_email;

drop temporary table if exists npq_subscribers;
create temporary table if not exists npq_subscribers
  select distinct(user_id)
    from wp_usermeta
    where meta_key = 'wp_56_capabilities'
    and meta_value like "%subscriber%";

drop temporary table if exists npq_candidates_for_removal;
create temporary table if not exists npq_candidates_for_removal
  select distinct(user_id)
    from npq_subscribers left outer join npq_active_user_ids
    on user_id = ID
    where ID is null;

-- Users in the candidates for removal list that do not have any comments
drop temporary table if exists npq_distinct_commenters;
create temporary table if not exists npq_distinct_commenters
  select distinct(user_id) from wp_56_comments;

drop temporary table if exists npq_users_with_no_comments;
create temporary table if not exists npq_users_with_no_comments
  select distinct(npq_candidates_for_removal.user_id)
    from npq_candidates_for_removal
    left outer join npq_distinct_commenters
    on npq_candidates_for_removal.user_id = npq_distinct_commenters.user_id
    where npq_distinct_commenters.user_id is null;

-- Users in the candidates for removal list that do not have any posts
drop temporary table if exists npq_users_with_no_posts;
create temporary table if not exists npq_users_with_no_posts
  select distinct(npq_candidates_for_removal.user_id)
    from npq_candidates_for_removal
    left outer join wp_56_posts
    on npq_candidates_for_removal.user_id = wp_56_posts.post_author
    where wp_56_posts.post_author is null;

-- Users that do not have comments or posts
drop temporary table if exists npq_delete_these_users;
create temporary table if not exists npq_delete_these_users
  select npq_users_with_no_posts.user_id
    from npq_users_with_no_posts
    inner join npq_users_with_no_comments
    on npq_users_with_no_posts.user_id = npq_users_with_no_comments.user_id;

delete wp_usermeta from wp_usermeta
  inner join npq_delete_these_users
  on wp_usermeta.user_id = npq_delete_these_users.user_id;

delete wp_users from wp_users
  inner join npq_delete_these_users
  on wp_users.ID = npq_delete_these_users.user_id;
