-- This script sets the '_wp_post_template' to 'single-two-column.php' for
-- any posts in the Columns taxonomy (which is used for RNS' Columns/Blogs).
drop temporary table if exists term_tax_ids;
create temporary table if not exists term_tax_ids
	select wp_term_taxonomy.term_taxonomy_id
	from wp_terms inner join wp_term_taxonomy
	on wp_terms.term_id = wp_term_taxonomy.term_id
	and wp_term_taxonomy.taxonomy = 'columns';

drop temporary table if exists object_ids;
create temporary table if not exists object_ids
	select object_id
	from wp_term_relationships join term_tax_ids
	on term_tax_ids.term_taxonomy_id = wp_term_relationships.term_taxonomy_id;

drop temporary table if exists post_ids;
create temporary table if not exists post_ids
	select ID from wp_posts join object_ids
	on ID = object_id and post_type = 'post';

delete wp_postmeta from wp_postmeta join post_ids
	on wp_postmeta.post_id = post_ids.ID
	and wp_postmeta.meta_key = '_wp_post_template'
	and wp_postmeta.meta_value = 'single-two-column.php';

insert into wp_postmeta (post_id, meta_key, meta_value)
	select ID, '_wp_post_template', 'single-two-column.php'
	from post_ids;
