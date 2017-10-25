CREATE INDEX client_on_clients ON clients(client);
CREATE INDEX lobbyist_on_clients ON clients(lobbyist);
CREATE INDEX lobbyist_firm_on_clients ON clients(lobbyist_firm);



CREATE INDEX fullname_on_lobbyists ON lobbyists(FullName);
CREATE INDEX firmname_on_lobbyists ON lobbyists(FirmName);
CREATE INDEX filerid_on_lobbyists ON lobbyists(FilerId);


CREATE INDEX date_on_political_contribs ON political_contributions(date);
CREATE INDEX lobbyist_on_political_contribs ON political_contributions(lobbyist);
CREATE INDEX lobbyist_firm_on_political_contribs ON political_contributions(lobbyist_firm);
CREATE INDEX official_on_political_contribs ON political_contributions(official);
CREATE INDEX official_dept_on_political_contribs ON political_contributions(official_department);
CREATE INDEX Payee_on_political_contribs ON political_contributions(Payee);
CREATE INDEX sourcefunds_on_political_contribs ON political_contributions(SourceOfFunds);


CREATE INDEX date_on_client_payments ON client_payments(date);
CREATE INDEX lobbyist_on_client_payments ON client_payments(lobbyist);
CREATE INDEX lobbyist_firm_on_client_payments ON client_payments(lobbyist_firm);
CREATE INDEX lobbyist_client_on_client_payments ON client_payments(Lobbyist_Client);

CREATE INDEX date_on_public_contacts ON public_contacts(date);
CREATE INDEX lobbyist_on_public_contacts ON public_contacts(lobbyist);
CREATE INDEX lobbyist_firm_on_public_contacts ON public_contacts(lobbyist_firm);
CREATE INDEX lobbyist_client_on_public_contacts ON public_contacts(Lobbyist_Client);
CREATE INDEX Official_on_public_contacts ON public_contacts(Official);
CREATE INDEX Official_Department_on_public_contacts ON public_contacts(Official_Department);
CREATE INDEX MunicipalDecision_on_public_contacts ON public_contacts(MunicipalDecision);
CREATE INDEX DesiredOutcome_on_public_contacts ON public_contacts(DesiredOutcome);
CREATE INDEX FileNumber_on_public_contacts ON public_contacts(FileNumber);
CREATE INDEX LobbyingSubjectArea_on_public_contacts ON public_contacts(LobbyingSubjectArea);


