
DROP TABLE IF EXISTS lobbyists;
DROP TABLE IF EXISTS political_contributions;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS client_payments;
DROP TABLE IF EXISTS public_contacts;


CREATE TABLE lobbyists (
  "FullName" VARCHAR COLLATE NOCASE,
  "FirmName" VARCHAR COLLATE NOCASE,
  "FilerId" VARCHAR COLLATE NOCASE,
  "AddressLine1" VARCHAR COLLATE NOCASE,
  "AddressLine2" VARCHAR COLLATE NOCASE,
  "AddressCity" VARCHAR COLLATE NOCASE,
  "AddressState" VARCHAR,
  "AddressZip" VARCHAR,
  "PhoneBusiness" VARCHAR,
  "Email" VARCHAR COLLATE NOCASE,
  "FirstName" VARCHAR COLLATE NOCASE,
  "LastName" VARCHAR COLLATE NOCASE,
  "Picture" VARCHAR COLLATE NOCASE,
  "Latest_Report_Year" INTEGER,
  "TerminationDate" DATE,
  "Location" VARCHAR
);



CREATE TABLE political_contributions (
  "Date" DATE,
  "Lobbyist" VARCHAR COLLATE NOCASE,
  "Lobbyist_Firm" VARCHAR COLLATE NOCASE,
  "Official" VARCHAR COLLATE NOCASE,
  "Official_Department" VARCHAR COLLATE NOCASE,
  "Payee" VARCHAR COLLATE NOCASE,
  "SourceOfFunds" VARCHAR COLLATE NOCASE,
  "Amount" FLOAT
);


CREATE TABLE clients (
  "Client" VARCHAR COLLATE NOCASE,
  "Lobbyist" VARCHAR COLLATE NOCASE,
  "Lobbyist_Firm" VARCHAR COLLATE NOCASE,
  "Client_Phone" VARCHAR,
  "Client_Address" VARCHAR COLLATE NOCASE,
  "Client_Address_2" VARCHAR COLLATE NOCASE,
  "Client_City" VARCHAR COLLATE NOCASE,
  "Client_State" VARCHAR COLLATE NOCASE,
  "Client_Zip" VARCHAR COLLATE NOCASE,
  "Client_Location" VARCHAR
);

CREATE TABLE client_payments (
  "Date" DATE,
  "Lobbyist" VARCHAR COLLATE NOCASE,
  "Lobbyist_Firm" VARCHAR COLLATE NOCASE,
  "Amount" FLOAT,
  "Lobbyist_Client" VARCHAR COLLATE NOCASE
);

CREATE TABLE public_contacts (
  "Date" DATE,
  "Lobbyist" VARCHAR COLLATE NOCASE,
  "Lobbyist_Firm" VARCHAR COLLATE NOCASE,
  "Official" VARCHAR COLLATE NOCASE,
  "Official_Department" VARCHAR COLLATE NOCASE,
  "Lobbyist_Client" VARCHAR COLLATE NOCASE,
  "MunicipalDecision" VARCHAR COLLATE NOCASE,
  "DesiredOutcome" VARCHAR COLLATE NOCASE,
  "FileNumber" VARCHAR COLLATE NOCASE,
  "LobbyingSubjectArea" VARCHAR
);
