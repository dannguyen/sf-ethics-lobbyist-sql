

mkdir -p csvs

curl -o csvs/lobbyists.csv \
  'https://data.sfgov.org/api/views/exbu-si57/rows.csv?accessType=DOWNLOAD'

curl -o csvs/clients.csv \
  https://data.sfgov.org/api/views/u4y3-k4vs/rows.csv?accessType=DOWNLOAD

curl -o csvs/client_payments.csv \
  'https://data.sfgov.org/api/views/s2fy-y3my/rows.csv?accessType=DOWNLOAD'

curl -o csvs/political_contributions.csv \
  'https://data.sfgov.org/api/views/sa8r-purn/rows.csv?accessType=DOWNLOAD'

curl -o csvs/activity_expenses.csv \
  'https://data.sfgov.org/api/views/rvdt-bv57/rows.csv?accessType=DOWNLOAD'

curl -o csvs/public_official_contacts.csv \
  'https://data.sfgov.org/api/views/hr5m-xnxc/rows.csv?accessType=DOWNLOAD'
