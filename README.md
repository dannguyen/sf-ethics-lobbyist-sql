

<a href="https://unsplash.com/photos/OCrPJce6GPk"><img src="https://i.imgur.com/0c2zPsT.png" alt="Photo from Unsplash via @gooner"></a>

# SF-Ethics Lobbyist Disclosure SQLite Database

An impromptu repo for hosting a SF lobbyist-disclosure database, as well as the code and steps I used to compile the data.

If you just want the data as a SQLite database, here it is as an easy-to-download SQLite file:

[sf-ethics-lobbyist-disclosures.sqlite](sf-ethics-lobbyist-disclosures.sqlite)

Further down in this README [are some some sample SQL explorations](#sql-fun).

I've [also created a meta-spreadsheet](https://docs.google.com/spreadsheets/d/1E4XS3bZK_8LcDU6DymLZo1voOPushNjB1bU1lIWgfBw/edit#gid=314188485) with information, articles, and other links, including Google Sheet versions of the data tables (in case you need to practice data exploration with pivot tables).

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

### SQL details


The [SQLite database](sf-ethics-lobbyist-disclosures.sqlite) is nearly a straight dump from the raw text, and so most of its fields are plain text. I did some transformation of the `date` and `amount` columns -- converting into ISO date format and removing unneeded dollar-character-signs, respectively, so that those columns could be treated as `DATE` and `FLOAT`.

I set most of the text columns to be  `COLLATE NOCASE` so that string comparisons would be case-insensitive. I don't know how reliable the data values are for joining the tables. For example, in the `lobbyists` table, a certain lobbyist has two `FullName` values, `'GRUWELL, CHRIS S.'` and `'GRUWELL, CHRIS'`. But in the `clients` table, his name (in the `lobbyist` field) is in titlecase, `'Grumwell, Chris S.'`  and `'Grumwell, Chris'`.



<a name="sql-fun" id="sql-fun"></a>

# Fun with SQL stories


Even without knowing much about San Francisco's lobbying universe, we can still find interesting insights by following principles for good SQL queries and data thinking.



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








