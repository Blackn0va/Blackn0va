<div align="center">

<img src="assets/header.svg" width="100%" alt="Hi, ich bin Blackn0va – StreamWizard, Streaming-Automatisierung. Werkzeuge, die Streams rund um die Uhr laufen lassen.">

[![Website](https://img.shields.io/badge/streamwizard.de-6D28D9?style=for-the-badge&logo=googlechrome&logoColor=white)](https://streamwizard.de)
[![E-Mail](https://img.shields.io/badge/E--Mail-blacknovaa%40gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:blacknovaa@gmail.com)

*Tools, die Streams laufen lassen – rund um die Uhr, sicher und ohne Babysitting.*

</div>

---

## 📊 GitHub in Zahlen

<!-- stats:start -->
<!-- Dieser Block wird von scripts/Statistik-aktualisieren.ps1 geschrieben – Änderungen hier gehen beim nächsten Lauf verloren. -->
<div align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/stats-dark.svg">
  <img src="assets/stats-light.svg" width="400" alt="GitHub in Zahlen, Stand 15.11.2026: 2.128 Commits, davon 1.613 im Jahr 2026; 23 Projekte, davon 13 privat; auf GitHub seit 2015.">
</picture>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/languages-dark.svg">
  <img src="assets/languages-light.svg" width="400" alt="Sprachen nach Codeumfang: C++ 38,1 %, Java 30,2 %, PHP 21,0 %, Python 2,8 %, PowerShell 2,5 %, Sonstige 5,4 %.">
</picture>
</div>
<!-- stats:end -->

<div align="center">
<sub>Gezählt werden meine Commits auf den Hauptzweigen aller eigenen Repositories – öffentlicher und privater.<br>
Der Code von StreamWizard bleibt privat, die Zahlen nicht.</sub>
</div>

---

## 🧙 StreamWizard

StreamWizard ist meine Plattform für Streaming-Automatisierung auf **Twitch**, **Kick** und **Discord**:
ein 24/7-Streambot direkt in OBS, Live-Untertitel mit Übersetzung, eine zentrale Runtime für Discord,
Gewinnspiele und Statistiken – und dahinter eine Website mit Login, Lizenzen und Zahlung.

> 🔒 StreamWizard ist proprietär. Der Quellcode ist nicht öffentlich – bei Fragen einfach schreiben.

| Baustein | Was es tut | Technik |
|:---|:---|:---|
| 🎬 **OBS-Plugin** | 24/7-Streambot als Modul **direkt in OBS Studio** – Playlisten, Ansage des laufenden Videos im Chat, signierte Selbst-Updates | C++20 · Qt 6 · libobs |
| 💬 **CaptionBridge** | Live-Untertitel: erkennt die gesprochene Sprache lokal auf dem Streaming-PC und übersetzt sie – für die Twitch-Extension und als Overlay in OBS | C++20 · Qt 6 |
| 🤖 **StreamwizardNode** | Zentrale Runtime: Discord-Gateway, Gewinnspiele und Streamstatistik über einen gemeinsamen Twitch-IRC-Hub | Java 21 · JDA · Twitch4J · kick4j |
| 🌐 **streamwizard.de** | Website und REST-API, Login über Discord, Twitch und Kick, Lizenzen und Zahlung | PHP 8.5 · MariaDB · Stripe |
| 🔐 **Loginserver** | Login für Zuschauer über Twitch | Java 21 |
| 💼 **Admintool** | Oberfläche für den Supportchat | Java 21 · Swing · FlatLaf |
| 🔑 **TokenTool** | OAuth-Tokens für Twitch und Discord einrichten und prüfen | Java 21 · Swing · FlatLaf |
| 📥 **SE-Import** | Punkte und Watchtime aus StreamElements übernehmen | Java 21 · Swing · FlatLaf |

### 🔄 Aus alt wird neu

Die früheren Einzel-Bots sind zusammengewachsen – weniger Prozesse, weniger Fehlerquellen:

- **RaffleBot Java**, **StreamStats Java** und **EventTool** → aufgegangen im zentralen **StreamwizardNode**
- **OBS Bot Java** (über obs-websocket) → ersetzt durch das native **C++-OBS-Plugin** *(seit September 2026)*
- **Updater** → eingestellt, das OBS-Plugin aktualisiert sich selbst *(seit September 2026)*

---

## 🌍 Öffentliche Projekte

| Projekt | Worum es geht | Technik |
|:---|:---|:---|
| 🧱 **[Baumeister](https://github.com/Blackn0va/baumeister)** | Minecraft-Plugin: ein Baumeister, der auf Zuruf baut, und Vera, eine Begleiterin, die mit dir spricht – lokale KI, Schematics, Redstone, Städte aus OpenStreetMap | Java 21 · Paper · llama.cpp · C++20 |
| 💡 **[LichtDuell](https://github.com/Blackn0va/LED_Game)** | Farbduell auf dem WLAN-LED-Streifen – der Computer schießt, du schießt zurück, Endgegner inklusive | C++20 · Govee · WLED · Art-Net · sACN |
| 📡 **[Marauder Control Center](https://github.com/Blackn0va/ESP32_Control_Center)** | Steuerung und Firmware-Flasher für den ESP32 Marauder direkt im Browser – für autorisierte Sicherheitstests | HTML · JavaScript · Web Serial |
| 🐬 **[Flipper BadUSB Wrapper](https://github.com/Blackn0va/Flipper_BadUSB_Wrapper)** | Verpackt PowerShell-Skripte als BadUSB- und JavaScript-Payload für den Flipper Zero | C# |
| 🤖 **[Discord Bot](https://github.com/Blackn0va/Discord_Bot)** | Discord-Bot mit OpenAI-Chat, Befehlen, Rollenvergabe und Musik | Java |
| 🖨️ **[RICOH-Benutzerliste](https://github.com/Blackn0va/RICOH_userlist_csv_ActiveDirectory)** | Erzeugt die CSV-Benutzerliste für RICOH-Drucker aus dem Active Directory | C# |
| 📝 **[Übergabeprotokoll](https://github.com/Blackn0va/Uebergabeprotokoll)** | Übergabeprotokoll als PDF zum Unterschreiben, mit SQLite-Datenbank | C# |

---

## 🧰 Tech-Stack

<div align="center">

**Sprachen & Frameworks**

![C++](https://img.shields.io/badge/C%2B%2B20-00599C?style=flat-square&logo=cplusplus&logoColor=white)
![Java](https://img.shields.io/badge/Java%2021-ED8B00?style=flat-square&logo=openjdk&logoColor=white)
![PHP](https://img.shields.io/badge/PHP%208.5-777BB4?style=flat-square&logo=php&logoColor=white)
![C#](https://img.shields.io/badge/C%23-512BD4?style=flat-square&logo=dotnet&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell%207-5391FE?style=flat-square)
![Qt](https://img.shields.io/badge/Qt%206-41CD52?style=flat-square&logo=qt&logoColor=white)
![Swing](https://img.shields.io/badge/Swing%20%C2%B7%20FlatLaf-2F3B4C?style=flat-square)

**Plattformen & Dienste**

![OBS Studio](https://img.shields.io/badge/OBS%20Studio-302E31?style=flat-square&logo=obsstudio&logoColor=white)
![Twitch](https://img.shields.io/badge/Twitch-9146FF?style=flat-square&logo=twitch&logoColor=white)
![Kick](https://img.shields.io/badge/Kick-53FC18?style=flat-square&logo=kick&logoColor=black)
![Discord](https://img.shields.io/badge/Discord-5865F2?style=flat-square&logo=discord&logoColor=white)
![Stripe](https://img.shields.io/badge/Stripe-635BFF?style=flat-square&logo=stripe&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)
![llama.cpp](https://img.shields.io/badge/Lokale%20KI%20%C2%B7%20llama.cpp-1F2937?style=flat-square)

**Build & Tools**

![CMake](https://img.shields.io/badge/CMake-064F8C?style=flat-square&logo=cmake&logoColor=white)
![MSVC](https://img.shields.io/badge/MSVC-5C2D91?style=flat-square)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=flat-square&logo=apachemaven&logoColor=white)
![Inno Setup](https://img.shields.io/badge/Inno%20Setup-264DE4?style=flat-square)
![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)

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
