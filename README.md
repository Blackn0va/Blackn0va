<div align="center">

# Hi, ich bin Blackn0va 👋

### Entwickler von 🧙 **StreamWizard** · Streaming-Automatisierung · IT-Administration

*Tools, die Streams laufen lassen – rund um die Uhr, sicher und ohne Babysitting.*

[![Website](https://img.shields.io/badge/streamwizard.de-6D28D9?style=for-the-badge&logo=googlechrome&logoColor=white)](https://streamwizard.de)
[![E-Mail](https://img.shields.io/badge/E--Mail-blacknovaa%40gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:blacknovaa@gmail.com)

</div>

---

## 🧙 StreamWizard

StreamWizard ist meine Plattform für Streaming-Automatisierung auf **Twitch**, **Kick** und **Discord**:
ein 24/7-Streambot direkt in OBS, eine zentrale Discord-Runtime für Gewinnspiele und Statistiken,
Werkzeuge für Support und Tokens – und dahinter eine Website mit Login, Lizenzen und Zahlung.

> 🔒 StreamWizard ist proprietär. Der Quellcode ist nicht öffentlich – bei Fragen einfach schreiben.

<div align="center">

| Baustein | Was es tut | Technik |
|:---|:---|:---|
| 🎬 **OBS-Plugin** | 24/7-Streambot als Modul **direkt in OBS Studio** – Playlisten, Ansage des laufenden Videos im Chat, kein Zusatzprogramm | C++17 · Qt 6 · libobs |
| 🤖 **DiscordServer** | Zentrale Runtime: Discord-Gateway, RaffleBot, Giveaways und Streamstats über einen gemeinsamen Twitch-IRC-Hub | Java 21 · JDA · Twitch4J · kick4j |
| 🌐 **streamwizard.de** | Website, REST-API, Login über Discord/Twitch/Kick, Lizenzen und Zahlung | PHP 8.5 · MariaDB · Stripe |
| 💬 **Admintool** | Oberfläche für den Supportchat | Java 21 · JavaFX |
| 🔑 **TokenTool** | OAuth-Tokens für Twitch und Discord einrichten und prüfen | Java 21 · JavaFX |
| 📥 **SE-Import** | Punkte und Watchtime aus StreamElements übernehmen | Java 21 |
| 🔄 **Updater** | Updates und Wartung | Java 21 |

</div>

### 🔄 Aus alt wird neu

Die früheren Einzel-Bots sind zusammengewachsen – weniger Prozesse, weniger Fehlerquellen:

- **RaffleBot Java**, **StreamStats Java** und **EventTool** → aufgegangen im zentralen **DiscordServer**
- **OBS Bot Java** (über obs-websocket) → ersetzt durch das native **C++-OBS-Plugin** *(seit September 2026)*

---

## 🛠️ Tech-Stack

<div align="center">

**Sprachen & Frameworks**

![C++](https://img.shields.io/badge/C%2B%2B17-00599C?style=flat-square&logo=cplusplus&logoColor=white)
![Java](https://img.shields.io/badge/Java%2021-ED8B00?style=flat-square&logo=openjdk&logoColor=white)
![PHP](https://img.shields.io/badge/PHP%208.5-777BB4?style=flat-square&logo=php&logoColor=white)
![Qt](https://img.shields.io/badge/Qt%206-41CD52?style=flat-square&logo=qt&logoColor=white)
![JavaFX](https://img.shields.io/badge/JavaFX-007396?style=flat-square&logo=openjdk&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat-square)

**Plattformen & Dienste**

![OBS Studio](https://img.shields.io/badge/OBS%20Studio-302E31?style=flat-square&logo=obsstudio&logoColor=white)
![Twitch](https://img.shields.io/badge/Twitch-9146FF?style=flat-square&logo=twitch&logoColor=white)
![Kick](https://img.shields.io/badge/Kick-53FC18?style=flat-square&logo=kick&logoColor=black)
![Discord](https://img.shields.io/badge/Discord-5865F2?style=flat-square&logo=discord&logoColor=white)
![Stripe](https://img.shields.io/badge/Stripe-635BFF?style=flat-square&logo=stripe&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)

**Build & Tools**

![CMake](https://img.shields.io/badge/CMake-064F8C?style=flat-square&logo=cmake&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=flat-square&logo=apachemaven&logoColor=white)
![Inno Setup](https://img.shields.io/badge/Inno%20Setup-264DE4?style=flat-square)
![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)

</div>

---

## 🔐 Worauf ich Wert lege

- **Sicherheit zuerst** – OWASP Top 10 und ASVS als Maßstab; Login, Lizenz und Zahlung auf Level 2
- **Fail-closed** – bei Fehlern wird angehalten, nicht stillschweigend weitergemacht
- **Signierte Releases** – Updates und Downloads mit eigener Signatur, Signierschlüssel auf Hardware-Token
- **Signierte Schnittstellen** – die Kommunikation zwischen den Diensten ist per HMAC abgesichert
- **Belegen statt raten** – jeder Fix braucht einen Test, der ohne ihn scheitert

---

## 🖥️ Nebenbei: IT-Administration

Windows-Clients und -Server, Automatisierung mit **PowerShell**, Geräteverwaltung mit **Intune**,
**Azure** und **Microsoft 365**.

---

<div align="center">

### 📬 Kontakt

Idee für ein Stream-Tool, Frage zu StreamWizard oder einfach Austausch?
Schreib mir: **[blacknovaa@gmail.com](mailto:blacknovaa@gmail.com)**

<sub>Made with ❤️ for the Streaming Community</sub>

</div>
