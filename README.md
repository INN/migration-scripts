# migration-scripts
Preparing a WordPress single site database dump for use in a WordPress multi-site environment.

# How to use these files

1. Make copies of `prepare_standalone.sql` and `delete_blog_users.sql` to customize for your site migration.
2. Set the values of `@newUmetaID`, `@newUserID` and `@newBlogID` at the top your copy of `prepare_standalone.sql`.
3. Run the SQL against the standalone blog's database.
4. Dump the network and blog tables to separate files. You can use the included shell script [dump_tables.sh](dump_tables.sh) with the name of your local database where you loaded the blog's data. For instance, you could run `./dump_tables.sh wordpress` if the database were named `wordpress`. Run the script with no arguments for help.
5. If you previously loaded the standalone blog's tables into your multisite install, drop the blog's tables.
6. If you previously loaded the standalone blog's network tables into your multisite install, you can use `delete_blog_users.sql` to remove the blog's users from network tables and avoid duplicate users in your database.
7. Load the blog tables into your multisite install.
8. Load the network tables into your multisite install.
9. Done!

## List of blog tables

- wp_commentmeta is renamed to wp\_`@newBlogID`\_commentmeta
- wp_comments is renamed to wp\_`@newBlogID`\_comments
- wp_links is renamed to wp\_`@newBlogID`\_links
- wp_options is renamed to wp\_`@newBlogID`\_options
- wp_postmeta is renamed to wp\_`@newBlogID`\_postmeta
- wp_posts is renamed to wp\_`@newBlogID`\_posts
- wp_term_relationships is renamed to wp\_`@newBlogID`\_term_relationships
- wp_term_taxonomy is renamed to wp\_`@newBlogID`\_term_taxonomy
- wp_terms is renamed to wp\_`@newBlogID`\_terms
