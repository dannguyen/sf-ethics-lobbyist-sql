# SF-Ethics Lobbyist Disclosure data

This is an impromptu repo that contains a lobbyist-disclosure database, as well as the code and steps I used to compile it. 

If you just want the data as a SQLite database, here it is as a downloadable file:

[sf-ethics-lobbyist-disclosures.sqlite](sf-ethics-lobbyist-disclosures.sqlite)

You can [also check out this meta-spreadsheet I've put together](https://docs.google.com/spreadsheets/d/1E4XS3bZK_8LcDU6DymLZo1voOPushNjB1bU1lIWgfBw/edit#gid=314188485) with information and links, including Google Sheet versions of the data tables (in case you need to practice data exploration with pivot tables).

## About the data and this repo

The lobbyist data comes from the San Francisco Ethics Committee. You can explore the data through a [searchable website](https://netfile.com/Sunlight/sf/Lobbyist/ContactOfPublicOfficialSearch), but the Ethics Committee has made the data easy to download (as CSV) and [analyze via a Socrata Portal](https://sfethics.org/disclosures/lobbyist-disclosure/lobbyist-disclosure-data).

That said, as someone who doesn't know much about lobbying especially in SF, I didn't put much effort into looking at this data. The jargon alone was intimidating enough. However, I'm currently teaching the power of SQL joins to my [computational journalism class](http://2017.padjo.org) and I wanted real-world datasets for which knowing SQL joins would be an obvious advantage for journalistic exploration.

The SF ethics lobbyist data consists of 6 tables with confusingly vague names -- e.g. "Activity Expenses" and "Payments Promised By Clients". But I found that even for just 6 items, [making a spreadsheet to enumerate and understand the meaning of each table](https://docs.google.com/spreadsheets/d/1E4XS3bZK_8LcDU6DymLZo1voOPushNjB1bU1lIWgfBw/edit#gid=0) -- including their numbers of rows and columns  -- made it much easier to understand and appreciate the potential of the datasets.

And once the URLs are in a spreadsheet, automating the data-downloading and wrangling process is pretty straightforward.

## Repo contents

You can get a download the database as I've compiled it on 2017-10-24 here: [sf-ethics-lobbyist-disclosures.sqlite](sf-ethics-lobbyist-disclosures.sqlite)

There are a couple of top-level shell scripts that you can run yourself if you have the [indispensible csvkit command-line tools installed](https://csvkit.readthedocs.io/en/1.0.2/) (particularly [csvsql](https://csvkit.readthedocs.io/en/1.0.2/scripts/csvsql.html)):

- [download.sh](download.sh) - just a bunch of `curl` calls to the datasets' Socrata endpoints. The [csvs/](csvs/) subdirectory contains the downloaded data.
- [bootstrap.sh](bootstrap.sh) - a sloppy shell script that re-creates the database from the [schemas.sql](schemas.sql) and [indexes.sql](indexes.sql) scripts, and uses `csvsql` to import the plaintext CSV into the sqlite database.


# Fun with SQL stories

The [SQLite database is more-or-less a straight dump from the raw text](sf-ethics-lobbyist-disclosures.sqlite). I made a few changes for sanity: the `date` and `amount` columns were formatted to be more data-friendly -- e.g. converted to ISO format and removed dollar signs from the dollar amounts.

I also defined most of the text columns as `COLLATE NOCASE` so that comparisons would be case-insensitive. I don't know how reliable the common-fields are between the tables. For example, in the `lobbyists` table, a certain lobbyist has two `FullName` values, `'GRUWELL, CHRIS S.'` and `'GRUWELL, CHRIS'`. But in the `clients` table, his name (in the `lobbyist` field) is in titlecase, `'Grumwell, Chris S.'`  and `'Grumwell, Chris'`.


But even without knowing much about San Francisco's lobbying universe, some SQL concepts work just as effectively as with any topic. 

## Prop T's effects

California voters overwhelmingly [passed Prop T in 2016, which called for more restrictions on gifts and campaign money from lobbyists](https://ballotpedia.org/San_Francisco,_California,_Restrictions_on_Gifts_and_Campaign_Contributions_from_Lobbyists,_Proposition_T_(November_2016)). Is Prop T's effect noted in the `political_contributions` table?

##### What is the total amount of political contributions?

~~~sql
SELECT
  COUNT(*) AS total_contribs,
  SUM(Amount) AS total_amount 
FROM 
  political_contributions;
~~~

| total_contribs | total_amount |
| -------------- | ------------ |
| 2454           | 4163983.47   |


##### What is the aggregate of contribs by year?

~~~sql
SELECT
  STRFTIME('%Y', date) AS year,
  COUNT(*) AS total_contribs,
  CAST(SUM(Amount) AS INTEGER) AS total_amount 
FROM 
  political_contributions
GROUP BY year
ORDER BY year DESC;
~~~

| year | total_contribs | total_amount |
| ---- | -------------- | ------------ |
| 2017 | 168            | 120955       |
| 2016 | 475            | 1804094      |
| 2015 | 897            | 763804       |
| 2014 | 315            | 706376       |
| 2013 | 136            | 134368       |
| 2012 | 143            | 111306       |
| 2011 | 124            | 80640        |
| 2010 | 196            | 442436       |

Graphing `total_amount` by `year` seems to indicate that political contributions from SF lobbyists have fallen steeply:

![img](https://i.imgur.com/qfzUs4u.png)


## Who are the top lobbyists and clients?

The `client_payments` table contains the fees clients owe their lobbyists. Let's aggregate which lobbyists earn/clients pay the most:


SELECT 
  lobbyist_client,
  
  COUNT(*) AS total_payments,
  SUM(amount) as total_amount








