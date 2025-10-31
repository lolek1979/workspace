<h1 style="color: white; background-color: red;">K REVIZI</h1>

# Repozitáře Git

Tento dokument popisuje obecná pravidla použití a nastavení Git repositářů projektu NIS.<br> 

Je vyžadováno vyplnění emailu v konfiguraci Git klienta (aktuálně pouze z domény vzp.cz), lze nastavit pomocí následujícího příkazu:
```console
git config --global user.email "jmeno.prijmeni@vzp.cz"
```

#### Branching strategy

Použitá strategie větvení vychází z GitHub Flow, přičež hlavní větev se nazývá `main`.<br>

Pro dílčí úpravy se vytvářejí větve z `main` s názvem složeným z uživatelského jména/`feature`, znaku `/` a popisu úpravy (např. číslo a popis z work item). Příklady `novaj99/1234-init-script` nebo `feature/1234-init-script`. Vzniklá větev pushnutá na server by měla být propojena s work item v Azure DevOps.<br>

Push dílčích úprav na server se provádí pravidelně.<br>

V případě, že je úprava připravena k zamergování do `main` nebo konzultaci, tak se v Azure DevOps vytváří [Pull request](#pull-request).<br>

Po sloučení úprav do `main` větve se spouštějí CI/CD pipelines sloužící k sestavení aplikace a automatickému nasazení do vývojového prostředí.<br>

#### Pull request

Úpravy se slučují do `main` větve vytvořením pull requestu (PR) v Azure DevOps. V pull requestu je vyžadované vyplnit související work item z Azure DevOps. Tato informace je do pull request automaticky doplněna, pokud byla větev již dříve propojena s nějakým work item.<br>

V případě, že je pull request vytvářen pro potřeby konzultace/zpětné vazby, tedy úprava není aktálně určena k okamžitému sloučení `main` větve a následnému nasazení, tak se označuje jako "draft".<br>

Jako metodu slučování je možné využívat pouze **Rebase and fast-forward** (Creates a linear history by replaying the source branch commits onto the target without a merge commit).<br>

Součástí pull requestu je provedení PR pipeline daného repositáře. Nelze sloučit úpravy požadované PR, pokud PR pipeline skončí s chybou.<br>

Pull request schvalují minimálně dva schvalovatelé. Aktuálně je přípustné, aby jedním ze schvalovatelů pull requestu byl zároveň žadatel. Na vybraných repositářích je pro pull request do `main` uveden povinný schvalovatel (uživatel/skupina).<br>

#### Přístupová práva

TBD

# Nastavení jednotlivých repozitářů

## Settings

- Advanced Security: **Off**

### Repository Settings

- Forks: **On**
- Commit mention linking: **On**
- Commit mention work item resolution: **On**
- Work item transition preferences: **On**
- Permissions management: **On**
- Strict Vote Mode: **On**
- Inherit PR creation mode: **On**
- Create PRs as draft by default: **On**

## Policies

- Commit author email validation: **On**, **`*@vzp.cz`**
- File path validation: **Off**
- Case enforcement: **Off**
- Maximum path length: **Off**
- Maximum file size: **Off**

### Branch Policies: **main**
- Require a minimum number of reviewers: **On**
  - Minimum number of reviewers: **2**
  - Allow requestors to approve their own changes: **On**
  - Prohibit the most recent pusher from approving their own changes: **Off**
  - Allow completion even if some reviewers vote to wait or reject: **Off**
  - When new changes are pushed: **Require at least one approval on every iteration.**
- Check for linked work items: **On** - **Required**
- Check for comment resolution: **On** - **Required**
- Limit merge types: **On** - [**Rebase and fast-forward**]

- Build Validation: 1
  - Enabled: **On**
  - Build pipeline: *PR pipeline*
  - Path filter (optional): **``**
  - Trigger: **Automatic (whenever the source branch is updated)**
  - Policy requirement: **Required**
  - Build expiration: **After 12 hours if main brahch has been updated**
- Status Checks: 0
- Automatically included reviewers: *as required*

## Security

TBD

## Approvals and checks

TBD