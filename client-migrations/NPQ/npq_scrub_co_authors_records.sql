-- Remove Co-Authors Plus entries from `wp_56_terms`
-- where the `term_id` does not exist in `wp_56_term_taxonomy`.
-- This fixes an issue with the ajax search functionality of the
-- CAP plugin.
drop temporary table if exists npq_coauthor_terms_to_delete;
create temporary table if not exists npq_coauthor_terms_to_delete
  select a.term_id
    from wp_56_terms as a left outer join wp_56_term_taxonomy as b
    on a.term_id = b.term_id
    where b.term_id is null;

delete a from wp_56_terms as a join npq_coauthor_terms_to_delete as b
  on a.term_id = b.term_id;
