FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
#Det betyder att man startar härifrån för den har verktygen som man vill bygga med

WORKDIR /src
#Skapar mappen /src inne i containern och går in i den 

COPY . .
#Kopierar allt från din projektmapp /första punkten) till /src i containern (andra punkten)

RUN dotnet publish -c Release -o /app
#Bygger appen färdig för produktion och lägger resultatet i /app

#Nästa steg kör appen

FROM mcr.microsoft.com/dotnet/aspnet:10.0
#Börjar med en mindre bild som kan köra .NET appar, inte bygga dem
#Det är svaret på frågan om varför det finns tvp FROM: den färdiga containern blir mindre och säkrare.

WORKDIR /app
COPY --from=build /app .
#Hämtar den färdigbyggda appen från steget "buil" och lägger den här 

EXPOSE 8080
ENTRYPOINT ["dotnet", "openshift-gastbok.dll"]
#talar om att appen lyssnar på port 8080 och vilket kommando som startar appen 
