-- Find records in wp_56_term_taxonomy
-- that have a record for term_id in wp_56_terms
-- but have no corresponding records in wp_56_term_relationships
drop temporary table if exists npq_post_tags_to_remove;
create temporary table if not exists npq_post_tags_to_remove
  select a.term_id from wp_56_term_taxonomy a
    inner join wp_56_terms b
    on a.term_id = b.term_id
    left outer join wp_56_term_relationships c
    on a.term_taxonomy_id = c.term_taxonomy_id
    where c.term_taxonomy_id is null
    and a.taxonomy = 'post_tag';

delete wp_56_terms from wp_56_terms
  join npq_post_tags_to_remove
  on wp_56_terms.term_id = npq_post_tags_to_remove.term_id;

delete wp_56_term_taxonomy from wp_56_term_taxonomy
  join npq_post_tags_to_remove
  on wp_56_term_taxonomy.term_id = npq_post_tags_to_remove.term_id;
