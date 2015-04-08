-- SAVE --
-- Shows how many posts have a byline that is different form the post author's display name
-- select meta_value, display_name, wp_53_posts.ID from wp_53_posts
  -- left join wp_53_postmeta
  -- on wp_53_posts.ID = wp_53_postmeta.post_id
  -- left join wp_users
  -- on wp_53_posts.post_author = wp_users.ID
  -- where wp_53_postmeta.meta_key = 'largo_byline_text'
  -- and wp_53_posts.post_type = 'post'
  -- and wp_53_posts.post_status = 'publish'
  -- and meta_value != display_name;

-- Shows largo_byline_text with no matching user record as well as post count for each largo_byline_text
-- select meta_value, count(meta_value) as meta_count from wp_53_posts
  -- left join wp_53_postmeta
  -- on wp_53_posts.ID = wp_53_postmeta.post_id
  -- left join wp_users
  -- on wp_53_posts.post_author = wp_users.ID
  -- where wp_53_postmeta.meta_key = 'largo_byline_text'
  -- and wp_53_posts.post_type = 'post'
  -- and wp_53_posts.post_status = 'publish'
  -- and meta_value != display_name
  -- group by meta_value
  -- order by meta_count DESC;
-- SAVE --

-- Prep
update wp_53_postmeta set meta_value = 'Benjamin Mook' where meta_value = 'Ben Mook' and meta_key = 'largo_byline_text';
update wp_53_postmeta set meta_value = 'Erica Sanchez' where meta_value = 'Erica Sánchez-Vázquez' and meta_key = 'largo_byline_text';
update wp_53_postmeta set meta_value = 'Karen Everhart' where meta_value = 'Karen Everhart Bedford' and meta_key = 'largo_byline_text';
update wp_53_postmeta set meta_value = trim(meta_value) where meta_key = 'largo_byline_text';

-- Get down 2 bizness
-- Create a temporary table with largo_byline_text and ID for user record with matching display name
drop temporary table if exists largo_byline_texts_users;
create temporary table if not exists largo_byline_texts_users select distinct wp_53_postmeta.meta_value, wp_users.ID
  from wp_users
  left join wp_53_postmeta
  on wp_users.display_name = wp_53_postmeta.meta_value
  left join wp_usermeta
  on wp_users.ID = wp_usermeta.user_id
  where wp_53_postmeta.meta_key = 'largo_byline_text'
  and wp_usermeta.meta_key = 'wp_53_capabilities';

-- Create a temporary table with post IDs where the largo_byline_text field does not match the display name of the user associated with the post.
-- Includes the largo_byline_text for each post as well as the ID of the user each post should be associated with.
drop temporary table if exists largo_byline_post_id_map;
create temporary table if not exists largo_byline_post_id_map select wp_53_postmeta.meta_value, largo_byline_texts_users.ID as user_id, wp_53_posts.ID as post_id from wp_53_posts
  left join wp_53_postmeta
  on wp_53_posts.ID = wp_53_postmeta.post_id
  left join wp_users
  on wp_53_posts.post_author = wp_users.ID
  join largo_byline_texts_users
  on largo_byline_texts_users.meta_value = wp_53_postmeta.meta_value
  where wp_53_postmeta.meta_key = 'largo_byline_text'
  and wp_53_posts.post_type = 'post'
  and wp_53_posts.post_status = 'publish'
  and wp_53_postmeta.meta_value != display_name;

-- Update the posts table, setting the value of post_author to the user ID associated with the largo_byline_text
update wp_53_posts
  inner join largo_byline_post_id_map
  on wp_53_posts.ID = largo_byline_post_id_map.post_id
  set wp_53_posts.post_author = largo_byline_post_id_map.user_id;

-- Delete records from postmeta where the post ID exists in our largo_byline_post_id_map meaning it previously had a largo_byline_text field that corresponded to an actual user. This is a cleanup step.
delete wp_53_postmeta from wp_53_postmeta
  inner join largo_byline_post_id_map
  on wp_53_postmeta.meta_value = largo_byline_post_id_map.meta_value
  where wp_53_postmeta.meta_key = 'largo_byline_text';
