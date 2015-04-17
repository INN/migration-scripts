-- Set all posts that have a post_author ID that does not exist in
-- wp_users to user ID 2581029 (The Editors)
drop temporary table if exists npq_posts_with_no_author;
create temporary table if not exists npq_posts_with_no_author
  select wp_56_posts.ID
  from wp_56_posts left join wp_users
  on post_author = wp_users.ID
  where wp_users.ID is null
  order by wp_56_posts.ID;

update wp_56_posts set post_author = 2581029 where ID in (select ID from npq_posts_with_no_author);
