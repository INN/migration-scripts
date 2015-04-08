#!/bin/bash
args=("$@")
if [ $# -gt 0 ]; then
    echo -n "Enter the password for you MySQL 'root' user: "
    read -s password
    mysqldump --user=root --password=$password ${args[0]} --no-create-info wp_users wp_usermeta > ${args[0]}_network_tables.sql
    mysqldump --user=root --password=$password ${args[0]} --ignore-table=${args[0]}.wp_users --ignore-table=${args[0]}.wp_usermeta > ${args[0]}_blog_tables.sql
else
    echo "This script dumps a WordPress database stored locally, split into network and blog"
    echo "tables. It uses the root MySQL user and will prompt you for the password."
    echo ""
    echo "Network tables (wp_users, wp_usermeta) output to network_tables.sql."
    echo "Blog tables (everything else) output to blog_tables.sql."
    echo ""
    echo "Syntax: ./dump_tables.sh <wordpress_database_name>"
    echo ""
    echo "Example: ./dump_tables.sh wordpress"
fi
