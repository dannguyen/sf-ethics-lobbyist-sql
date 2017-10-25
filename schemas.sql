
DROP TABLE IF EXISTS lobbyists;
DROP TABLE IF EXISTS political_contributions;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS client_payments;
DROP TABLE IF EXISTS public_contacts;


CREATE TABLE lobbyists (
  "FullName" VARCHAR,
  "FirmName" VARCHAR,
  "FilerId" VARCHAR,
  "AddressLine1" VARCHAR,
  "AddressLine2" VARCHAR,
  "AddressCity" VARCHAR,
  "AddressState" VARCHAR,
  "AddressZip" VARCHAR,
  "PhoneBusiness" VARCHAR,
  "Email" VARCHAR,
  "FirstName" VARCHAR,
  "LastName" VARCHAR,
  "Picture" VARCHAR,
  "Latest_Report_Year" INTEGER,
  "TerminationDate" DATE,
  "Location" VARCHAR
);



CREATE TABLE political_contributions (
  "Date" DATE,
  "Lobbyist" VARCHAR,
  "Lobbyist_Firm" VARCHAR,
  "Official" VARCHAR,
  "Official_Department" VARCHAR,
  "Payee" VARCHAR,
  "SourceOfFunds" VARCHAR,
  "Amount" FLOAT
);


CREATE TABLE clients (
  "Client" VARCHAR,
  "Lobbyist" VARCHAR,
  "Lobbyist_Firm" VARCHAR,
  "Client_Phone" VARCHAR,
  "Client_Address" VARCHAR,
  "Client_Address_2" VARCHAR,
  "Client_City" VARCHAR,
  "Client_State" VARCHAR,
  "Client_Zip" VARCHAR,
  "Client_Location" VARCHAR
);

CREATE TABLE client_payments (
  "Date" DATE,
  "Lobbyist" VARCHAR,
  "Lobbyist_Firm" VARCHAR,
  "Amount" FLOAT,
  "Lobbyist_Client" VARCHAR
);

CREATE TABLE public_contacts (
  "Date" DATE,
  "Lobbyist" VARCHAR,
  "Lobbyist_Firm" VARCHAR,
  "Official" VARCHAR,
  "Official_Department" VARCHAR,
  "Lobbyist_Client" VARCHAR,
  "MunicipalDecision" VARCHAR,
  "DesiredOutcome" VARCHAR,
  "FileNumber" VARCHAR,
  "LobbyingSubjectArea" VARCHAR
);
