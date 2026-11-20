# Gästbok på OpenShift

En liten webbapp i C# och ASP.NET Core som jag driftsätter på **Red Hat OpenShift**. Projektet är ett lärprojekt där jag går från "fungerar på min dator" till en app som körs i ett Kubernetes-kluster i molnet och går att nå via internet.

Appen bygger jag ut steg för steg till en gästbok med PostgreSQL-databas.

## Tekniker

- C# / ASP.NET Core (.NET 10)
- Red Hat OpenShift 4.22 (Developer Sandbox)
- Kubernetes-resurser: Deployment, Service, Route, BuildConfig, ImageStream
- Source-to-Image (S2I)
- Docker (Dockerfile med multi-stage build)
- `oc` (OpenShift CLI)
- Git och GitHub

## Vad jag har gjort

1. **Skapat en minimal webbapp** med `dotnet new web` som svarar med en text på `/`.
2. **Satt upp OpenShift Developer Sandbox** och loggat in från terminalen med `oc login`.
3. **Byggt och driftsatt appen med Source-to-Image.** OpenShift hämtar koden direkt från GitHub, bygger den med Red Hats .NET 10-byggbild och skapar en container utan att jag behöver skriva en Dockerfile.
4. **Gett appen en publik https-adress** med en Route (`edge` = TLS terminerat i OpenShifts router).
5. **Skrivit en egen Dockerfile** och byggt samma app en gång till i OpenShift med Docker-strategin.

## Två sätt att bygga containern

| | Source-to-Image (S2I) | Dockerfile |
|---|---|---|
| Vem skriver bygginstruktionerna? | OpenShift, via en färdig byggbild | Jag själv |
| Kontroll | Mindre, men enklare | Full kontroll över varje steg |
| Fungerar | I OpenShift | Överallt där containrar körs (Docker, Podman, Kubernetes) |
| I projektet | Appen `gastbok` | Appen `gastbok-docker` |

Dockerfilen använder en **multi-stage build**: först byggs appen i en bild med hela .NET SDK, sedan kopieras bara den färdiga appen över till en mindre bild med enbart ASP.NET-runtime. Den färdiga containern blir då mindre och innehåller inga byggverktyg.

## Så kör du projektet

### Lokalt

```bash
dotnet run
```

### I OpenShift med Source-to-Image

```bash
oc new-app registry.access.redhat.com/ubi9/dotnet-100~https://github.com/pauline8712/openshift-gastbok.git --name=gastbok
oc logs -f bc/gastbok
oc create route edge gastbok --service=gastbok
oc get route gastbok
```

### I OpenShift med Dockerfile

```bash
oc new-app https://github.com/pauline8712/openshift-gastbok.git --strategy=docker --name=gastbok-docker
oc logs -f bc/gastbok-docker
oc create route edge gastbok-docker --service=gastbok-docker
oc get route gastbok-docker
```

### Med Docker lokalt

```bash
docker build -t gastbok .
docker run -p 8080:8080 gastbok
```

## Hur det hänger ihop

```
GitHub-repo
    │  (källkod)
    ▼
BuildConfig ──► bygg-pod (S2I eller Dockerfile)
    │
    ▼
ImageStream (färdig container-image)
    │
    ▼
Deployment ──► Pod (appen körs här, på en nod i klustret)
    │
    ▼
Service (intern adress i klustret)
    │
    ▼
Route (publik https-adress) ──► Internet
```

## Skärmdumpar

<!-- Lägg skärmdumparna i mappen docs/ och ta bort kommentartecknen runt raderna nedan.
![Appen i webbläsaren](docs/app.png)
![Topology-vyn i OpenShift](docs/topology.png)
-->

## Vad jag har lärt mig

- Skillnaden mellan **kluster**, **nod**, **namespace/projekt** och **container**.
- Att Kubernetes schemaläggare väljer vilken nod en container körs på.
- Hur Source-to-Image bygger en container direkt från källkod.
- Hur man skriver en Dockerfile och varför multi-stage builds ger mindre images.
- Varför en app behöver en **Route** för att nås utanför klustret.
- Att inloggningstokens är hemliga och aldrig ska ligga i koden.

## Nästa steg

- [ ] Webhook från GitHub så att varje `git push` bygger och driftsätter automatiskt
- [ ] Gästboksfunktion med PostgreSQL, Secret för lösenordet och beständig lagring
- [ ] Health checks (liveness/readiness probes)
- [ ] CI/CD-pipeline med OpenShift Pipelines (Tekton)
