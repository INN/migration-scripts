----------------
-- Q: How is a series represented in the database?
----------------

-- Clean Water - Series
-- tag_id = 4502
-- Archive Sidebar is Series Archive Sidebar
--
-- ----------------------------------------
--
-- Clean Water 1st Post - ID 1393 in wp_posts
-- Custom Sidebar is Series Sidebar

SELECT * 
    FROM wp_23_postmeta 
    WHERE post_id = 1393;

-- +---------+---------+----------------+--------------------+
-- | meta_id | post_id | meta_key       | meta_value         |
-- +---------+---------+----------------+--------------------+
-- |    5392 |    1393 | _edit_lock     | 1430406453:2563011 |
-- |    5393 |    1393 | _edit_last     | 2563011            |
-- |    5399 |    1393 | custom_sidebar | series-sidebar     |
-- |    5401 |    1393 | top_term       | 4502               |
-- +---------+---------+----------------+--------------------+

SELECT * 
    FROM wp_23_terms 
    WHERE term_id = 4502;

-- +---------+---------------------------+--------------------------+------------+
-- | term_id | name                      | slug                     | term_group |
-- +---------+---------------------------+--------------------------+------------+
-- |    4502 | Clean Water: The Next Act | clean-water-the-next-act |          0 |
-- +---------+---------------------------+--------------------------+------------+

SELECT term_taxonomy_id, term_id, taxonomy 
    FROM wp_23_term_taxonomy 
    WHERE term_id = 4502;

-- +------------------+---------+----------+
-- | term_taxonomy_id | term_id | taxonomy |
-- +------------------+---------+----------+
-- |             4504 |    4502 | series   |
-- +------------------+---------+----------+

----------------
-- Q: How can I get a list of all series from the database?
----------------

SELECT term_taxonomy_id, term_id, taxonomy 
    FROM wp_23_term_taxonomy 
    WHERE taxonomy = "series";

-- +------------------+---------+----------+
-- | term_taxonomy_id | term_id | taxonomy |
-- +------------------+---------+----------+
-- |             4518 |    4516 | series   |
-- |             4483 |    3835 | series   |
-- |             4485 |     785 | series   |
-- |             4501 |    4499 | series   |
-- |             4495 |    4493 | series   |
-- |             4502 |    4500 | series   |
-- |             4503 |    4501 | series   |
-- |             4504 |    4502 | series   |
-- |             4505 |    4503 | series   |
-- |             4506 |    4504 | series   |
-- |             4507 |    4505 | series   |
-- |             4508 |    4506 | series   |
-- |             4509 |    4507 | series   |
-- |             4510 |    4508 | series   |
-- |             4511 |    4509 | series   |
-- |             4512 |    4510 | series   |
-- |             4513 |    4511 | series   |
-- |             4514 |    4512 | series   |
-- |             4516 |    4514 | series   |
-- |             4517 |    4515 | series   |
-- |             4543 |    4541 | series   |
-- |             4545 |    4543 | series   |
-- |             4547 |    4545 | series   |
-- +------------------+---------+----------+

SELECT wp_23_terms.* 
    FROM wp_23_terms JOIN
            wp_23_term_taxonomy
        ON wp_23_terms.term_id = wp_23_term_taxonomy.term_id
    WHERE wp_23_term_taxonomy.taxonomy = "series";

-- +---------+----------------------------------+---------------------------------+------------+
-- | term_id | name                             | slug                            | term_group |
-- +---------+----------------------------------+---------------------------------+------------+
-- |    4514 | Sidebar                          | sidebar                         |          0 |
-- |    4515 | Sexual Assault on Campus         | sexual-assault-on-campus        |          0 |
-- |     785 | Duwamish River                   | duwamish-river                  |          0 |
-- |    4516 | Capitol Environment              | capitol-environment             |          0 |
-- |    3835 | Stolen Wages                     | stolen-wages                    |          0 |
-- |    4499 | Adolescent MS                    | adolescent-ms                   |          0 |
-- |    4493 | North Pacific Fisheries          | north-pacific-fisheries         |          0 |
-- |    4500 | Biomass Energy                   | biomass-energy                  |          0 |
-- |    4501 | Center of Detention              | center-of-detention             |          0 |
-- |    4502 | Clean Water: The Next Act        | clean-water-the-next-act        |          0 |
-- |    4503 | Dateline Earth                   | dateline-earth                  |          0 |
-- |    4504 | Exhausted at School              | exhausted-at-school             |          0 |
-- |    4505 | Fish Consumption                 | fish-consumption                |          0 |
-- |    4506 | Foster Care                      | foster-care                     |          0 |
-- |    4507 | From the Field                   | from-the-field                  |          0 |
-- |    4508 | Portable Classrooms              | portable-classrooms             |          0 |
-- |    4509 | Prescription Drugs               | prescription-drugs              |          0 |
-- |    4510 | Public Parks for Sale            | public-parks-for-sale           |          0 |
-- |    4511 | Wandering                        | wandering                       |          0 |
-- |    4512 | Western Exposure                 | western-exposure                |          0 |
-- |    4541 | Redacted: Transparency in Oregon | redacted-transparency-in-oregon |          0 |
-- |    4543 | Seattle's Homeless               | seattles-homeless               |          0 |
-- |    4545 | Equal Justice                    | equal-justice                   |          0 |
-- +---------+----------------------------------+---------------------------------+------------+


----------------
-- Q: How are posts indicated as belonging to a particular series?
----------------

-- Post ID 1393 belongs to the series with term_id = 4502

SELECT * FROM wp_23_term_relationships WHERE object_id = 1393;

-- +-----------+------------------+------------+
-- | object_id | term_taxonomy_id | term_order |
-- +-----------+------------------+------------+
-- |      1393 |             4448 |          1 |
-- |      1393 |             4497 |          0 |
-- |      1393 |             4499 |          0 |
-- |      1393 |             4504 |          0 |
-- +-----------+------------------+------------+

SELECT wp_23_term_taxonomy.term_taxonomy_id, wp_23_term_taxonomy.term_id, wp_23_term_taxonomy.taxonomy 
    FROM wp_23_term_taxonomy JOIN
            wp_23_term_relationships
        ON wp_23_term_taxonomy.term_taxonomy_id = wp_23_term_relationships.term_taxonomy_id
    WHERE wp_23_term_relationships.object_id = 1393;

-- +------------------+---------+-----------+
-- | term_taxonomy_id | term_id | taxonomy  |
-- +------------------+---------+-----------+
-- |             4499 |    4497 | post-type |
-- |             4448 |    4448 | author    |
-- |             4497 |    4495 | category  |
-- |             4504 |    4502 | series    |
-- +------------------+---------+-----------+

SELECT wp_23_term_taxonomy.term_taxonomy_id, wp_23_term_taxonomy.term_id, wp_23_term_taxonomy.taxonomy 
    FROM wp_23_term_taxonomy JOIN
            wp_23_term_relationships
        ON wp_23_term_taxonomy.term_taxonomy_id = wp_23_term_relationships.term_taxonomy_id
    WHERE wp_23_term_relationships.object_id = 1393
        AND wp_23_term_taxonomy.taxonomy = "series";

-- +------------------+---------+----------+
-- | term_taxonomy_id | term_id | taxonomy |
-- +------------------+---------+----------+
-- |             4504 |    4502 | series   |
-- +------------------+---------+----------+

----------------
-- Q: How do we find all posts associated with any series?
----------------

SELECT object_id AS post_id 
    FROM wp_23_term_relationships JOIN 
            wp_23_term_taxonomy 
        ON wp_23_term_relationships.term_taxonomy_id = wp_23_term_taxonomy.term_taxonomy_id
    WHERE wp_23_term_taxonomy.taxonomy = "series";

----------------
-- Q: How are posts associated with the Series Sidebar?
----------------

SELECT *
    FROM wp_23_postmeta
    WHERE meta_key = "custom_sidebar" AND
        meta_value = "series-sidebar";

-- +---------+---------+----------------+----------------+
-- | meta_id | post_id | meta_key       | meta_value     |
-- +---------+---------+----------------+----------------+
-- |     376 |    1513 | custom_sidebar | series-sidebar |
-- |     732 |    1535 | custom_sidebar | series-sidebar |
-- |    4828 |    1559 | custom_sidebar | series-sidebar |
-- |    5399 |    1393 | custom_sidebar | series-sidebar |
-- +---------+---------+----------------+----------------+

INSERT INTO wp_23_postmeta (post_id, meta_key, meta_value)
SELECT wp_23_term_relationships.object_id, 'custom_sidebar', 'series-sidebar'
    FROM wp_23_term_relationships JOIN 
            wp_23_term_taxonomy 
        ON wp_23_term_relationships.term_taxonomy_id = wp_23_term_taxonomy.term_taxonomy_id
    WHERE wp_23_term_taxonomy.taxonomy = "series";

----------------
-- Q: How is a series archive represented in the database?
----------------



----------------
-- Q: How is the Series Archive Sidebar represented in the database?
----------------


----------------
-- Q: How are series archives associated with the Series Archive Sidebar?
----------------
