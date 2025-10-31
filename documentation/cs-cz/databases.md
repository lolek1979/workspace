<h1 style="color: white; background-color: red;">K REVIZI</h1>

# Databáze

Tento dokument popisuje obecná pravidla použití a nastavení databází projektu NIS.<br>

## PostgreSQL databáze

Použité řešení Azure Database for PostgreSQL - Flexible Server (PostgreSQL verze 16.4)<br> 
<br>
Pro každou komponentu projektu NIS se používá dedikovaná databáze. Komponenty tedy nesdílejí data přes nějakou sdílenou databáze, ale pomocí svých aplikačních rozhraní. Název databáze vychází z pojmenování komponenty v Git repozitáři. Např. pro komponentu `component-codelists` se jméno databáze nazývá `codelists`. V této databázi je pak vytvořeno schéma se stejným názvem, jako je jméno databáze (přechodně u existujících databází schéma `public`), ve kterém jsou umístěny objekty pro danou komponentu. Použité schéma se ovlivňuje parametrem v connection stringu, nikoliv ve zdrojových kódech aplikace, uváděním názvu tabulky včetně schématu.

### Kodová stránka a porovnávání

Výchozí kódová stránka pro nové databáze: UTF8<br>
Výchozí porovnávání: cs-CZ (citlivost na malá a velká písměna, citlivost na akcent)<br>
<br>
Kódovou stránku a porovnávání je možno specifikovat před založením databáze [dle možností Azure Database for PostgreSQL - Flexible Server (PostgreSQL verze 16.4)].  

### Oprávnění

Komponenta má CRUD oprávnění na tabulky daném schématu jako výchozí. CD Pipeline pro danou komponentu má oprávnění v daném schématu provádět i  Data Definition Language (DDL) dotazy. Požadavky na oprávnění většího rozsahu je nutno explicitně specifikovat při požadavku na vytvoření databáze nebo později. 

### Síťový přístup k PostgreSQL v Azure

Přímý síťový prostup z uživatelské stanice k PostgreSQL serveru v Azure je aktuálně možný pouze z centrály/poboček VZP nikoliv přes VPN. Případně je možný přístup z Azure Portal nebo z terminálového serveru týmu Azure Cloud infrastruktury.

### DDL dotazy

Změny struktury v PostgreSQL databázích jsou prováděny v rámci CD pipeline pomocí nástroje Liquibase (https://www.liquibase.com/), konfigurace v repozitářích Git jednotlivých komponent se předpokládá v souboru `resources\liquibase\db.changelog.xml`. V databázích v Azure se aktuálně nepředpokládá provádění DDL dotazů jinak než z CD pipelines. Při zavedení správy databázových schémat pomocí vlastností Entity Framework bude pravděpodobně požadovaná oprávnění a CD pipelines nutné přepracovat.

### Vytváření databází

Databáze v Azure aktuálně zakládá Infra team na základě požadavku v Azure DevOps NIS projektu (https://dev.azure.com/vzp/NIS). V budoucnou pravděpodobně přejde odpovědnost na databázové administrátory v rámci NIS.

## Azure Cosmos DB

TODO - Tento dokument aktuálně nepokrývá otázku Azure Cosmos DB
