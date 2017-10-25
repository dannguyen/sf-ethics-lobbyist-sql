
DBNAME=sf-ethics-lobbyist-disclosures.sqlite

# Run the schemas.sql (and wipeout existing tables)
echo "Loading schemas.sql into $DBNAME"


sqlite3 ${DBNAME} < schemas.sql


######### For datasets that have dollars signs, use sed:
echo "Loading client_payments table"

cat csvs/client_payments.csv \
  | sed -E 's/\$([0-9])/\1/g' \
  | csvsql --no-create --insert \
           --db sqlite:///${DBNAME} \
           --tables client_payments


echo "Loading political_contributions table"

cat csvs/political_contributions.csv \
  | sed -E 's/\$([0-9])/\1/g' \
  | csvsql --no-create --insert \
           --db sqlite:///${DBNAME} \
           --tables political_contributions


############### load the rest of the data

echo "Loading 3 more tables..."

cat csvs/clients.csv \
  | csvsql --no-create --insert \
           --db sqlite:///${DBNAME} \
           --tables clients

cat csvs/lobbyists.csv \
  | csvsql --no-create --insert \
           --db sqlite:///${DBNAME} \
           --tables lobbyists


cat csvs/public_contacts.csv \
  | csvsql --no-create --insert \
           --db sqlite:///${DBNAME} \
           --tables public_contacts

#### index the tables
echo "Indexing the tables in ${DBNAME}"
