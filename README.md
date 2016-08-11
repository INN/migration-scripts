# migration-scripts

Tools for migrating a single WordPress site into an existing WordPress multisite install.

# What Do These Scripts Do?

1. `prepare_standaline.sql` will help prevent data collisions during the migration process.

If your single WordPress site has 20 users (using user IDs 1-20), and your multisite  has 20 users (also using IDs 1-20), then you'll need to change your single site to use IDs 21-40 before importing.  

2. `delete_blog_users.sql`

# How to use these files

1. Look at your multisite install's database.
- What is the highest blog id? _(You'll see the blog ID listed in the table names like `wp_2_posts`)_
- What is the highest user id? _(View the `wp_users` table and sort the ID column descending)_
- What is the highest usermeta id? _(View the `wp_usermeta` table and sort the `umeta_id` column descending)_

2. Make a copy of `prepare_standalone.sql` and edit the file to update the variables at the top of the file.

```
SET @newUmetaID = Set Here;     // The highest usermeta id from above + 1
SET @newUserID = Set Here;      // The highest user id from above + 1
SET @newBlogID = Set Here;      // The highest blog id from above + 1 
```

3. Copy `prepare_standalone.sql` with your new variables and run it against the single site's database.

4. Dump the blog tables (tables with a naming structure of wp_#_) and network tables (all other tables - `wp_termmeta`, `wp_usermeta`, `wp_users`) to separate files.

You can do this manually or use the included shell script [dump_tables.sh](dump_tables.sh) with the name of your local database where you loaded the blog's data. For instance, you could run `./dump_tables.sh wordpress` if the database were named `wordpress`. Run the script without any arguments for help.

* If you're running VVV locally and want to use the `dump_tables.sh` script, ssh into your vagrant box and run the following commands:

```
sudo apt-get install mysql-client
git clone https://github.com/INN/migration-scripts.git
cd migration-scripts/
./dump_tables.sh
```

This will install mysql-client (required by this script and not included in VVV by default), clone this repository, and run `dump_tables.sh`.

5. You should now have 2 files in the directory you ran `dump_tables.sh` from: `[DB Name]_blog_tables.sql` and `[DB Name]_network_tables.sql`, where `[DB Name]` is the name of the database you exported from. Import these files into your WordPress multisite install, and you're all done!

# What if I imported my blog and now I want to undo/remove it?

1. Delete the blog tables with a naming structure of `wp_#_`, where `#` is the blog number you assigned.
2. Make a copy of `delete_blog_users.sql` and edit the file to update the variable `@newBlogID` at the top of the file, replacing `TKTK` with the blog # (same number as in step 1).
3. Copy `delete_blog_users.sql` with your new variable and run it against the multisite install's database.

## List of blog tables updated by `prepare_standalone.sql`

- wp_commentmeta is renamed to wp\_`@newBlogID`\_commentmeta
- wp_comments is renamed to wp\_`@newBlogID`\_comments
- wp_links is renamed to wp\_`@newBlogID`\_links
- wp_options is renamed to wp\_`@newBlogID`\_options
- wp_postmeta is renamed to wp\_`@newBlogID`\_postmeta
- wp_posts is renamed to wp\_`@newBlogID`\_posts
- wp_term_relationships is renamed to wp\_`@newBlogID`\_term_relationships
- wp_term_taxonomy is renamed to wp\_`@newBlogID`\_term_taxonomy
- wp_terms is renamed to wp\_`@newBlogID`\_terms
