

<a href="https://unsplash.com/photos/OCrPJce6GPk"><img src="https://i.imgur.com/0c2zPsT.png" alt="Photo from Unsplash via @gooner"></a>

# SF-Ethics Lobbyist Disclosure SQLite Database

An impromptu repo for hosting a SF lobbyist-disclosure database, as well as the code and steps I used to compile the data.

If you just want the data as a SQLite database, here it is as an easy-to-download SQLite file:

[sf-ethics-lobbyist-disclosures.sqlite](https://github.com/dannguyen/sf-ethics-lobbyist-sql/raw/master/sf-ethics-lobbyist-disclosures.sqlite)

Further down in this README [are some some sample SQL explorations](#sql-fun).

I've [also created a meta-spreadsheet](https://docs.google.com/spreadsheets/d/1E4XS3bZK_8LcDU6DymLZo1voOPushNjB1bU1lIWgfBw/edit#gid=314188485) with information, articles, and other links, including Google Sheet versions of the data tables (in case you need to practice data exploration with pivot tables).

## About the data and this repo

The lobbyist data comes from the San Francisco Ethics Committee. You can explore the data through a [searchable website](https://netfile.com/Sunlight/sf/Lobbyist/ContactOfPublicOfficialSearch), but the Ethics Committee has made the data easy to download (as CSV) and [analyze via a Socrata Portal](https://sfethics.org/disclosures/lobbyist-disclosure/lobbyist-disclosure-data).

The SF ethics lobbyist dataset has 6 somewhat vaguely named tables -- e.g. "Activity Expenses" and "Payments Promised By Clients" -- relating to lobbyists in San Francisco, their clients, and their financial activity. It's not immediately clear how all the tables relate (many columns are duplicated), so I found it helpful to [make a spreadsheet to list the tables and their features](https://docs.google.com/spreadsheets/d/1E4XS3bZK_8LcDU6DymLZo1voOPushNjB1bU1lIWgfBw/edit#gid=0) -- including their numbers of rows and columns.

And once the URLs are in a spreadsheet, automating the data-downloading and wrangling process is pretty straightforward.

## Repo contents

You can get a download the database as I've compiled it on 2017-10-24 here: [sf-ethics-lobbyist-disclosures.sqlite](https://github.com/dannguyen/sf-ethics-lobbyist-sql/raw/master/sf-ethics-lobbyist-disclosures.sqlite)

There are a couple of top-level shell scripts that you can run yourself if you have the [indispensible csvkit command-line tools installed](https://csvkit.readthedocs.io/en/1.0.2/) (particularly [csvsql](https://csvkit.readthedocs.io/en/1.0.2/scripts/csvsql.html)):

- [download.sh](download.sh) - just a bunch of `curl` calls to the datasets' Socrata endpoints. The [csvs/](csvs/) subdirectory contains the downloaded data.
- [bootstrap.sh](bootstrap.sh) - a sloppy shell script that re-creates the database from the [schemas.sql](schemas.sql) and [indexes.sql](indexes.sql) scripts, and uses `csvsql` to import the plaintext CSV into the sqlite database.

### SQL details


The [SQLite database](https://github.com/dannguyen/sf-ethics-lobbyist-sql/raw/master/sf-ethics-lobbyist-disclosures.sqlite) is nearly a straight dump from the raw text, and so most of its fields are plain text. I did some transformation of the `date` and `amount` columns -- converting into ISO date format and removing unneeded dollar-character-signs, respectively, so that those columns could be treated as `DATE` and `FLOAT`.

I set most of the text columns to be  `COLLATE NOCASE` so that string comparisons would be case-insensitive. I don't know how reliable the data values are for joining the tables. For example, in the `lobbyists` table, a certain lobbyist has two `FullName` values, `'GRUWELL, CHRIS S.'` and `'GRUWELL, CHRIS'`. But in the `clients` table, his name (in the `lobbyist` field) is in titlecase, `'Grumwell, Chris S.'`  and `'Grumwell, Chris'`.

The SQLite database contains 5 tables; I left out the ["Activity Expenses"](https://data.sfgov.org/City-Management-and-Ethics/Lobbyist-Activity-Activity-Expenses/rvdt-bv57) table for having so few records (less than 115) without interesting datapoints.




<a name="sql-fun" id="sql-fun"></a>

# Fun SQL stories


Even without firsthand knowledge of San Francisco's lobbying universe, we can still apply the same general good principles for asking questions of data with SQL. Below are assorted examples of SQL queries for understanding what the datasets contain, as well as some long-ass queries that I thought would turn out to be more interesting  `¯\_(ツ)_/¯` 




## Prop T's effects

California voters overwhelmingly [passed Prop T in 2016, which called for more restrictions on gifts and campaign money from lobbyists](https://ballotpedia.org/San_Francisco,_California,_Restrictions_on_Gifts_and_Campaign_Contributions_from_Lobbyists,_Proposition_T_(November_2016)). Is Prop T's effect noted in the `political_contributions` table?

#### What is the total amount of political contributions?

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


#### What is the aggregate of contribs by year?

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

Graphing `total_amount` by `year` seems to indicate that political contributions from SF lobbyists have fallen steeply after the 2016 elections and passage of Prop T.

![img](https://i.imgur.com/qfzUs4u.png)

#### Damned lies, statistics, and aggregations

However, this particular chart may not be evidence at all about Prop T effectiveness. In fact, I'd argue that the chart serves more as a reminder of how a particular aggregation can present a drastically different picture than another, even when using the exact same data. When an aggregation is too broad -- in this case, summing up by year -- important truth can be eradicated. 

What happens if we aggregate the contributions by *month*? The following query rounds every given date to being on the first of the month (this makes it easier to throw into a charting program):

~~~sql
SELECT 
  STRFTIME('%Y-%m-01', Date) AS month,
  SUM(Amount)
FROM political_contributions
GROUP BY month
ORDER BY month ASC;
~~~

The resulting chart shows a reality more mundane: 2016 had spikes in giving because it was an election year. Sure, it was a much bigger year than 2012. But the monthly political contributions in 2017 look no more anemic than they did in 2013. In fact, they look *stronger*:

![img](https://i.imgur.com/Tp8ezJ3.png)


Aggregating the contribution amounts at the most granular level -- by day -- confirms the suspicion that it is too early to tell if Prop T has had any real effect on lobbyists and political contributions.

~~~sql
SELECT date,
  SUM(Amount)
FROM political_contributions
GROUP BY date
ORDER BY date ASC;
~~~


![img](https://i.imgur.com/qKvinux.png)

And it's easy enough to do a query to confirm that 2017 is not at all a low post-election year for political contributions. Filter for records no later than September of each year (i.e. month `09`) and 2017 comes ahead of 3 other years:

~~~sql
SELECT 
  STRFTIME('%Y', Date) AS year,
  SUM(Amount) AS total 
FROM political_contributions
WHERE STRFTIME('%m', Date) <= '09'
GROUP BY year
ORDER BY total DESC;
~~~

| year | total  |
| ---- | ------ |
| 2016 | 660886 |
| 2015 | 451805 |
| 2010 | 302922 |
| 2014 | 296641 |
| 2017 | 120955 |
| 2012 | 75018  |
| 2013 | 32521  |
| 2011 | 21602  |

------

There's likely more to look at in `political_contributions`, especially if any of its records relate to political activity recorded in the other tables.


## Who are the top lobbyists and clients?

The `clients` and `lobbyists` tables don't contain a lot of immediately interesting info other than biographical info, certainly nothing that would let us "sort" clients and lobbyists from "best"/"most successful" to "worst".

Luckily, we have the `client_payments` table, which not only contains columns that connect client to lobbyist, but also tell us when and how much a client paid a lobbyist. Money spent is always something we can try to quantify. 


### General queries about the client_payments table


Let's start out with an easy query: the total number of payments and amount paid in the entire `client_payments` table:

~~~sql
SELECT
  COUNT(*) AS payment_count,
  SUM(Amount) AS total_payment
FROM client_payments;
~~~

| payment_count | total_payment    |
| ------------- | ---------------- |
| 19812         | 60145853.5200001 |

We can do a group count by *year* (derived from `date`) to see how far back this table spans. And to get a rough trend of lobbying spending over the years:


~~~sql
SELECT
  STRFTIME('%Y', date) AS year,
  COUNT(*) AS payment_count,
  ROUND(AVG(Amount)) AS payment_avg,
  ROUND(SUM(Amount)) AS total_payment
FROM client_payments
GROUP BY year
ORDER BY year ASC;
~~~

Being pretty ignorant of lobbying, I'm not sure what to make of the drop in average payment over the years. Maybe later we can try to count number of individual lobbyists.

| year | payment_count | payment_avg | total_payment |
| ---- | ------------- | ----------- | ------------- |
| 2010 | 1107          | 5560.0      | 6154390.0     |
| 2011 | 1217          | 4557.0      | 5546365.0     |
| 2012 | 1285          | 4886.0      | 6277893.0     |
| 2013 | 1357          | 4314.0      | 5854356.0     |
| 2014 | 1678          | 3490.0      | 5856355.0     |
| 2015 | 3660          | 2402.0      | 8793069.0     |
| 2016 | 4949          | 2301.0      | 11387222.0    |
| 2017 | 4559          | 2254.0      | 10276203.0    |

### Sorting lobbyists by total amount made

How much a lobbyist feels like a decent proxy figuring out "top" lobbyist. Here is a query to find the top 10 lobbyists by total amount received:

~~~sql
SELECT 
  Lobbyist,
  COUNT(*) AS payment_count,
  ROUND(AVG(AMOUNT)) AS avg_amount,
  SUM(AMOUNT) AS total_payment
FROM client_payments
GROUP BY Lobbyist
ORDER BY total_payment DESC
LIMIT 10;
~~~

| Lobbyist           | payment_count | avg_amount | total_payment |
| ------------------ | ------------- | ---------- | ------------- |
| Gruwell, Chris     | 3663          | 3526.0     | 12916439.0    |
| Smolens, H. Marcia | 684           | 8400.0     | 5745500.0     |
| Lauter, Samuel     | 680           | 7670.0     | 5215500.0     |
| Peterson, Rich H.  | 1014          | 5057.0     | 5128274.78    |
| Peterson, Rich     | 676           | 5922.0     | 4003027.21    |
| Johnston, Karin    | 360           | 9360.0     | 3369700.0     |
| Tourk, Alex        | 391           | 7897.0     | 3087915.1     |
| Lapointe, Denise   | 374           | 6183.0     | 2312500.0     |
| Gruwell, Chris S.  | 586           | 3728.0     | 2184365.0     |
| Noyola, David G.   | 387           | 4972.0     | 1924350.0     |
Looks like Chris Gruwell is the winner by a longshot, topping even the sum between "Peterson, Rich" and "Peterson, Rich H.", who I'm assuming is just one person (another reminder of how a single character can ruin an aggregate count).

In fact Grunwell's total playment is also split: he not only has the #1 spot but #9 as 'Grumwell, Chris S.'

| Lobbyist           | payment_count | total_payment |
| ------------------ | ------------- | ------------- |
| Gruwell, Chris     | 3663          | 12916439.0    |
| Smolens, H. Marcia | 684           | 5745500.0     |
| Lauter, Samuel     | 680           | 5215500.0     |
| Peterson, Rich H.  | 1014          | 5128274.78    |
| Peterson, Rich     | 676           | 4003027.21    |
| Johnston, Karin    | 360           | 3369700.0     |
| Tourk, Alex        | 391           | 3087915.1     |
| Lapointe, Denise   | 374           | 2312500.0     |
| Gruwell, Chris S.  | 586           | 2184365.0     |
| Noyola, David G.   | 387           | 1924350.0     |


Is Grumwell's dominance recent? By adding a `WHERE` clause, we can filter the records to see what the totals looked like 7 years ago:

~~~sql
SELECT 
  Lobbyist,
  COUNT(*) AS payment_count,
  ROUND(AVG(AMOUNT)) AS avg_amount,
  SUM(AMOUNT) AS total_payment
FROM client_payments
WHERE 
  STRFTIME('%Y', date) = '2010'
GROUP BY Lobbyist
ORDER BY total_payment DESC
LIMIT 10;
~~~

Looks like Gruwell has been a long-time winner when it comes to making a living as a lobbyist.

| Lobbyist           | payment_count | avg_amount | total_payment |
| ------------------ | ------------- | ---------- | ------------- |
| Gruwell, Chris     | 382           | 4186.0     | 1598900.0     |
| Smolens, H. Marcia | 141           | 8312.0     | 1172000.0     |
| Lauter, Samuel     | 111           | 8083.0     | 897250.0      |
| Rossi, Jaime       | 73            | 7869.0     | 574417.24     |
| Tourk, Alex        | 75            | 5547.0     | 416000.0      |
| Alberti, Adam      | 18            | 13035.0    | 234633.18     |
| Lapointe, Denise   | 34            | 6162.0     | 209500.0      |
| Clemens, Alex      | 40            | 5135.0     | 205401.3      |
| Noto, Frank        | 8             | 16960.0    | 135677.0      |
| Smith, Kimberly    | 22            | 4500.0     | 99000.0       |


Over the years, here's what Gruwell's total payments look like:

~~~sql
SELECT 
  STRFTIME('%Y', date) AS year,
    COUNT(*) AS payment_count,
  ROUND(AVG(AMOUNT)) AS avg_payment,
    SUM(AMOUNT) AS total_payment
FROM client_payments
WHERE 
  Lobbyist LIKE '%gruwell, Chris%'
GROUP BY year
ORDER BY year DESC;
~~~

| year | payment_count | avg_payment | total_payment |
| ---- | ------------- | ----------- | ------------- |
| 2017 | 467           | 3607.0      | 1684615.0     |
| 2016 | 642           | 3588.0      | 2303539.0     |
| 2015 | 698           | 2831.0      | 1976350.0     |
| 2014 | 499           | 3289.0      | 1641100.0     |
| 2013 | 528           | 3826.0      | 2020350.0     |
| 2012 | 551           | 4313.0      | 2376350.0     |
| 2011 | 482           | 3111.0      | 1499600.0     |
| 2010 | 382           | 4186.0      | 1598900.0     |

Since Gruwell is so good, it's worth asking who his clients are. Are they eager to spend? Loyal? Both?

~~~sql
SELECT
  lobbyist_client,
  COUNT(*) as payment_count,
  SUM(Amount) as total_amount 
FROM client_payments
WHERE 
  Lobbyist LIKE '%gruwell, Chris%'
GROUP BY lobbyist_client
ORDER BY total_amount DESC;
~~~

### Creative list-making with joins

I have no idea what the quality of a client says about the quality of the lobbyist, and vice versa. But let's give Gruwell the benefit of the doubt, that he's good at his job, and that clients are happy to have him.

If it's *good* to be his client, then is it *bad* not to be? Or, is at least bad to be dropped as a client?

Being able to quickly compare one list with another through the use of JOINs is one of SQL's best (if not the best) features for data programmers, both for its power and its flexibility. 

Since every result set of a query is a table, the following query "creates" a table of Gruwell's 30 most spendy clients in 2015:

~~~sql
SELECT 
  lobbyist_client,
  SUM(Amount) AS total_amount 
FROM client_payments
WHERE 
    Lobbyist LIKE '%gruwell, Chris%'
    AND SUBSTR(date, 1, 4) = '2014'
GROUP BY lobbyist_client 
ORDER BY total_amount DESC
LIMIT 30;
~~~

An excerpt of that table:

| Lobbyist_Client                       | total_amount |
| ------------------------------------- | ------------ |
| Aecom                                 | 180000.0     |
| Airbnb                                | 150000.0     |
| Webcor Builders                       | 102000.0     |
| Cb&i                                  | 100000.0     |
| Tishman Speyer                        | 96000.0      |
| Trumark Commerical                    | 90000.0      |
| Golden State Warriors                 | 88500.0      |
| Stv, Inc.                             | 60000.0      |
| University Of San Francisco           | 60000.0      |
| Veolia Water North America            | 60000.0      |


Likewise, we can create a similar table of top spending clients in 2016:

~~~sql
SELECT 
  lobbyist_client,
  SUM(Amount) AS total_amount 
FROM client_payments
WHERE 
    Lobbyist LIKE '%gruwell, Chris%'
    AND SUBSTR(date, 1, 4) = '2016'
GROUP BY lobbyist_client 
ORDER BY total_amount DESC
LIMIT 30;
~~~

| Lobbyist_Client                       | total_amount |
| ------------------------------------- | ------------ |
| Aecom                                 | 180000.0     |
| Golden State Warriors                 | 174000.0     |
| Accenture                             | 128000.0     |
| Arcadis                               | 100000.0     |
| Tishman Speyer                        | 96000.0      |
| Webcor Builders                       | 76500.0      |
| Shorenstein                           | 72500.0      |
| Trumark Urban/commerical              | 67500.0      |
| Motorola Solutions                    | 60000.0      |
| University Of San Francisco           | 60000.0      |
| Emerson Process Management            | 55000.0      |

Finding which names are missing from two lists of 30 isn't the most time-consuming task. If your life depended on it, you could probably do it pretty well. But manual matching does not scale. JOIN queries *do* scale.

#### Biggest drop in payments

Since it's the client paying the lobbyist, it doesn't make much sense that it's the lobbyist who drops the client. Oh well, I still want to see a list of Gruwell's clients, sorted in order of biggest drop in payments from 2014 to 2016.

The `JOIN` is straightforward, but creating the tables could be done in several ways. I'm going to go with my favorite technique: [Recursive Common Table Expressions](https://www.essentialsql.com/recursive-ctes-explained/)


~~~sql
WITH gclients AS (
        SELECT 
          lobbyist_client,
          STRFTIME('%Y', date) AS year,
          SUM(Amount) AS total_amount 
        FROM client_payments
        WHERE 
            Lobbyist LIKE '%gruwell, Chris%'
        GROUP BY lobbyist_client, year)
SELECT
  ty.lobbyist_client,
  ty.total_amount AS amt_2016,
  tx.total_amount AS amt_2014,
  (ty.total_amount - tx.total_amount) AS diff
FROM gclients AS ty
INNER JOIN gclients AS tx
  ON tx.lobbyist_client = ty.lobbyist_client
    AND tx.year = '2014'
    AND ty.year = '2016'

ORDER BY diff ASC
LIMIT 10;
~~~

The result:


| lobbyist_client           | amt_2016 | amt_2014 | diff      |
| ------------------------- | -------- | -------- | --------- |
| Airbnb                    | 35500.0  | 150000.0 | -114500.0 |
| Cb&i                      | 0.0      | 100000.0 | -100000.0 |
| Bay West Development      | 0.0      | 37500.0  | -37500.0  |
| Mark Cavagnero Associates | 0.0      | 30000.0  | -30000.0  |
| Webcor Builders           | 76500.0  | 102000.0 | -25500.0  |
| Salesforce.com Inc.       | 0.0      | 25000.0  | -25000.0  |
| Sfo Shuttle Bus           | 5000.0   | 30000.0  | -25000.0  |
| Zynga                     | 0.0      | 25000.0  | -25000.0  |
| Zipcar                    | 17500.0  | 36000.0  | -18500.0  |
| 1140 Folsom Llc           | 0.0      | 18000.0  | -18000.0  |
{:.table-sql}


Gruwell seems like such an outlier that there's probably more to analyze. The New York Times wrote about him in 2011, and the article sheds some insight to lobbying work in the Bay Area: [Lobbyists Play Outsize Role as Political Fund-Raisers in San Francisco](http://www.nytimes.com/2011/06/12/us/12bclobbyist.html)



## Quid pro quo

Probably the most intriguing of the lobbyist disclosure datasets is [the public_contacts table](https://sfethics.org/ethics/2012/05/lobbyist-contacts-of-public-officials-dataset.html). On a monthly basis, registered lobbyists are required to notify the City/County of every meeting had with a public official. 

Let's start with a count of contacts by year:

~~~sql
SELECT STRFTIME('%Y', date) AS year ,
  COUNT(*) AS count 
FROM public_contacts
GROUP BY year
ORDER BY year ASC;
~~~

Look at that spike from 2014 to 2015, a trend that's continued into 2017:

| year | count |
| ---- | ----- |
| 2010 | 1507  |
| 2011 | 1672  |
| 2012 | 1159  |
| 2013 | 1189  |
| 2014 | 1944  |
| 2015 | 5430  |
| 2016 | 6910  |
| 2017 | 5413  |

I'm guessing [it has something to do with this law passed in 2014](http://www.sfchronicle.com/bayarea/article/Legislation-aims-to-close-loopholes-in-S-F-5505560.php) that made it harder for lobbying-types to not register as a lobbyist (and thus keep track of their public officials contacts).


Easiest way is to do a group count by year and lobbyist and see if the lobbyist count jumped in 2014 to 2015:

~~~sql
SELECT 
  year, COUNT(*) AS lob_count
FROM
  (SELECT 
      STRFTIME('%Y', date) AS year,
      lobbyist
    FROM public_contacts
    GROUP BY year, lobbyist)
GROUP BY year
ORDER BY year;
~~~

Doesn't seem like it. Oh well.


### Popular public figures

We've looked at lobbyists, now it's time to count those on the public officials side. Let's do a group count by the `Official` field and list the top 10 officials by number of visits.


~~~sql
SELECT 
  official,
  COUNT(*) AS contact_count
FROM 
  public_contacts
GROUP BY 
  official
ORDER BY 
  contact_count DESC
LIMIT 10;
~~~

| Official         | contact_count |
| ---------------- | ------------- |
| Farrell, Mark    | 640           |
| Chiu, David      | 525           |
| Wiener, Scott    | 493           |
| Sanchez, Scott   | 411           |
| Richards, Dennis | 398           |
| Kim, Jane        | 397           |
| Rahaim, John     | 390           |
| Cohen, Malia     | 376           |
| Hillis, Rich     | 363           |
| Fong, Rodney     | 360           |


It's worth adding the `Official_Department` field to add context. Some people may have switched departments/jobs within the dataset. Even so, it makes more sense to attribute public contacts by job title than personal identity.

Adding `Official_Department` in the `SELECT` clause means we have to group by it too:

~~~sql
SELECT 
  official,
  Official_Department,
  COUNT(*) AS contact_count
FROM 
  public_contacts
GROUP BY 
  official, Official_Department
ORDER BY 
  contact_count DESC
LIMIT 10;
~~~

Looks like the vast majority of visited officials are board supervisors or planning commissioners. Makes sense:

| Official         | Official_Department     | contact_count |
| ---------------- | ----------------------- | ------------- |
| Farrell, Mark    | Board Of Supervisors    | 640           |
| Chiu, David      | Board Of Supervisors    | 525           |
| Wiener, Scott    | Board Of Supervisors    | 492           |
| Kim, Jane        | Board Of Supervisors    | 397           |
| Richards, Dennis | Planning Commission     | 395           |
| Rahaim, John     | Planning, Department Of | 385           |
| Cohen, Malia     | Board Of Supervisors    | 375           |
| Hillis, Rich     | Planning Commission     | 358           |
| Fong, Rodney     | Planning Commission     | 351           |
| Campos, David    | Board Of Supervisors    | 348           |

Always worth asking about the most visited people who *aren't* in these positions of power:

~~~sql
SELECT 
  official,
  Official_Department,
  COUNT(*) AS contact_count
FROM 
  public_contacts
WHERE 
  Official_Department NOT LIKE 'Board of Supervisors'
    AND Official_Department NOT LIKE 'Planning Commission'
GROUP BY 
  official, Official_Department
ORDER BY 
  contact_count DESC
LIMIT 10;
~~~

| Official            | Official_Department                      | contact_count |
| ------------------- | ---------------------------------------- | ------------- |
| Rahaim, John        | Planning, Department Of                  | 385           |
| Boudreaux, Marcelle | Planning, Department Of                  | 339           |
| Sider, Dan          | Planning, Department Of                  | 327           |
| Elliott, Jason      | Mayor Office Of The                      | 230           |
| Sanchez, Scott      | Planning, Department Of                  | 226           |
| Grob, Carly         | Planning, Department Of                  | 192           |
| Sanchez, Scott      | Zoning Administrator                     | 185           |
| Sucre, Rich         | Planning, Department Of                  | 178           |
| Lee, Ed             | Mayor Office Of The                      | 177           |
| Schwartz, Glen      | Retirement Board San Francisco Employees | 172           |


Let's look at the count by department:


~~~sql
SELECT 
  Official_Department,
  COUNT(*) AS contact_count
FROM 
  public_contacts
GROUP BY 
  Official_Department
ORDER BY 
  contact_count DESC
LIMIT 10;
~~~

| Official_Department                           | contact_count |
| --------------------------------------------- | ------------- |
| Board Of Supervisors                          | 7075          |
| Planning, Department Of                       | 6888          |
| Planning Commission                           | 2557          |
| Mayor Office Of The                           | 1545          |
| Retirement Board San Francisco Employees      | 1253          |
| Municipal Transportation Agency               | 741           |
| Economic And Workforce Development, Office Of | 441           |
| City Attorney Office Of The                   | 440           |
| Recreation And Parks Department               | 408           |
| Public Works Department Of                    | 363           |


Alright, it's time to look at the lobbyist and client counts:

~~~sql
SELECT 
  lobbyist,
  COUNT(*) AS contact_count
FROM 
  public_contacts
GROUP BY 
  lobbyist
ORDER BY 
  contact_count DESC
LIMIT 10;
~~~

| Lobbyist         | contact_count |
| ---------------- | ------------- |
| Frattin, Daniel  | 1555          |
| Knight, Jody     | 1209          |
| Junius, Andrew   | 966           |
| Kevlin, John     | 899           |
| Reuben, James    | 884           |
| Tourk, Alex      | 805           |
| Silverman, David | 775           |
| Bozeman, John    | 755           |
| Catalano, Tuija  | 726           |
| Loper, Mark      | 670           |


~~~sql
SELECT 
  lobbyist_client,
  COUNT(*) AS contact_count
FROM 
  public_contacts
GROUP BY 
  lobbyist_client
ORDER BY 
  contact_count DESC
LIMIT 10;
~~~

| Lobbyist_Client                            | contact_count |
| ------------------------------------------ | ------------- |
| Boma San Francisco                         | 1092          |
| San Francisco Chamber Of Commerce          | 868           |
| Tishman Speyer Properties, L.p.            | 393           |
| Pacific Gas And Electric Company           | 368           |
| Committee On Jobs                          | 367           |
| Oceanwide Center, Llc                      | 367           |
| Union Square Business Improvement District | 329           |
| Nixon Peabody Llp                          | 302           |
| Grosvenor Americas                         | 289           |
| Sustainable Living, Llc                    | 259           |


And why not try the lobbyist, client combo-group:

~~~sql
SELECT 
  lobbyist,
  lobbyist_client,
  COUNT(*) AS contact_count
FROM 
  public_contacts
GROUP BY
  lobbyist,
  lobbyist_client
ORDER BY 
  contact_count DESC
LIMIT 10;
~~~

| Lobbyist            | Lobbyist_Client                            | contact_count |
| ------------------- | ------------------------------------------ | ------------- |
| Bozeman, John       | Boma San Francisco                         | 755           |
| Lazarus, Jim        | San Francisco Chamber Of Commerce          | 488           |
| Wright, Christopher | Committee On Jobs                          | 367           |
| Workman, Dee Dee    | San Francisco Chamber Of Commerce          | 358           |
| Cleaveland, Ken     | Boma San Francisco                         | 337           |
| Flood, Karin        | Union Square Business Improvement District | 328           |
| Knight, Jody        | Sustainable Living, Llc                    | 254           |
| Knight, Jody        | 301 Sixth Street Associates, Llc           | 231           |
| Knight, Jody        | Grosvenor Americas                         | 211           |
| Frattin, Daniel     | Nixon Peabody Llp                          | 194           |


### Boma's wants

As always, it's a decent strategy to check out outliers. What is "Boma San Francisco" and why do their lobbyists have so many contacts with public officials?

~~~sql
SELECT  
  MunicipalDecision,
  COUNT(*) AS ccount
FROM 
  public_contacts
WHERE 
  Lobbyist_Client = 'Boma San Francisco'
GROUP BY MunicipalDecision
ORDER BY ccount DESC
LIMIT 10;
~~~

| MunicipalDecision                                                        | ccount |
| ------------------------------------------------------------------------ | ------ |
| Boma San Francisco Emergency Preparedness Committee                      | 76     |
| San Francisco Biological Agent Detector Ordinance                        | 46     |
| Boma San Francisco Building Tour                                         | 41     |
| Tenant Bicycle Parking In Existing Commercial Buildings                  | 36     |
| Formula Retail                                                           | 34     |
| Local Fire Codes                                                         | 29     |
| Boma San Francisco Member Building Tour                                  | 27     |
| Mobile Food Facilities - Department Of Public Works Permitting Authority | 23     |
| California Pacific Medical Center Projects                               | 22     |
| Mobile Food Trucks                                                       | 22     |

Looking at that top 10 list of concerns, we might guess that Boma is a non-profit advocacy group. Easy way to double-check -- how much have they been paying their lobbyists?

~~~sql
SELECT
  STRFTIME('%Y', date) AS year,
  lobbyist,
  SUM(amount) AS total_amount
FROM 
  client_payments
WHERE 
  lobbyist_client = 'Boma San Francisco'
 GROUP BY 
  year, lobbyist;
~~~

Looks like they aren't about to conquer San Francisco with capitalism:

| year | Lobbyist      | total_amount |
| ---- | ------------- | ------------ |
| 2016 | Bozeman, John | 4250.0       |
| 2017 | Bozeman, John | 2000.0       |


## Back to the corporate clients

Use recursive common-table expressions to define a table of most spendy clients. Use that to filter for a list of public contacts:

~~~sql
WITH spendyclients AS (SELECT 
        lobbyist_client,
        SUM(Amount) AS total_paid
      FROM
        client_payments
      WHERE STRFTIME('%Y', date) >= '2015'
      GROUP BY 
        lobbyist_client
      HAVING total_paid > 200000
      ORDER BY 
        total_paid DESC),
    
    spendyclientnames AS (
      SELECT lobbyist_client 
      FROM spendyclients
    )

SELECT *
FROM public_contacts
WHERE lobbyist_client IN spendyclientnames;
~~~

Note that the above isn't technically a JOIN. It uses a subquery to get a list of "spendy" clients. If `public_contacts.lobbyist_client` is in that list, then its `public_contact` record is included.



**ok taking nap now**


