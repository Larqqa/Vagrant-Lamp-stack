# Get the Database name from the Vagrantfile
DB=$(sed -n '/"DB" => .*/p' Vagrantfile | sed 's/^ *"DB" => //' | tr -d '",')

# Make a Database dump to shared folder
echo "-- Making database dump of $DB --" 
vagrant ssh -c "sudo mysqldump $DB > /var/www/db_dump.sql"

echo "-- Finished --"