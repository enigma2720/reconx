# 🔍 ReconX Elite – Advanced Bash Recon Framework

<p align="center">
  <img src="https://img.shields.io/badge/Bash-Scripting-green">
  <img src="https://img.shields.io/badge/Security-Recon-red">
  <img src="https://img.shields.io/badge/Status-Active-success">
  <img src="https://img.shields.io/badge/License-MIT-blue">
</p>

---

## 🛡️ Overview

**ReconX Elite** is a powerful, modular Bash-based reconnaissance framework designed for ethical hackers, penetration testers, and bug bounty hunters.

It automates the complete reconnaissance workflow:

```
Recon → Subdomain Enum → Live Detection → Port Scan → OSINT → Analysis → Report
```

---

## ⚡ Features

### 🔍 Core Recon

* Subdomain Enumeration (**subfinder**, **assetfinder**)
* Live Domain Detection (**httpx**)
* Port Scanning (**nmap automation**)
* Directory Bruteforce (**ffuf**)

### 🌐 OSINT & Intelligence

* VirusTotal API Integration (subdomain intelligence)
* Shodan API Integration (open ports & services)
* Google Dorking Automation

### 🧠 Analysis & Detection

* Technology Detection (**whatweb**)
* DNS Resolution & WHOIS Lookup

### ⚙️ Advanced Capabilities

* Auto-installation of missing tools
* Parallel execution for faster scanning
* Resume interrupted scans
* Organized output structure
* Summary report generation

---

## 📦 Installation

### 1. Clone Repository

```bash
git clone https://github.com/enigma2720/reconx.git
cd reconx
```

---

### 2. Make Script Executable

```bash
chmod +x reconx.sh
```

---

### 3. Configure API Keys

Create a file:

```bash
nano config.conf
```

Add:

```bash
VT_API_KEY="your_virustotal_api_key"
SHODAN_API_KEY="your_shodan_api_key"
```

---

### 4. Run Tool

```bash
./reconx.sh -d example.com
```

---

## 🚀 Usage

```bash
# Basic Scan
./reconx.sh -d example.com

# Custom Output Directory
./reconx.sh -d example.com -o output/example
```

---

## 📁 Output Structure

```
output/example.com/
├── subdomains.txt
├── vt_subdomains.txt
├── live.txt
├── ports.txt
├── dirs.txt
├── tech.txt
├── dns.txt
├── whois.txt
├── shodan.json
├── dorks.txt
└── summary.txt
```

---

## 📊 Sample Output

```
Subdomains: 150
Live Domains: 45
Open Ports: 20
```

---

## ⚠️ Legal Disclaimer

This tool is strictly for **educational purposes and authorized penetration testing only**.

* Do NOT scan systems without permission
* Unauthorized usage is illegal
* The developer is not responsible for misuse

---

## 💡 Why ReconX Elite?

ReconX Elite demonstrates:

* Real-world reconnaissance workflow used in bug bounty
* Strong Bash scripting and automation skills
* Integration of multiple security tools & APIs
* Structured and scalable output design
* Practical offensive security methodology

---

## 🧱 Tech Stack

* Bash Scripting
* Nmap
* Subfinder / Assetfinder
* Httpx
* FFUF
* WhatWeb
* VirusTotal API
* Shodan API

---

## 🛣️ Roadmap

* [ ] Screenshot automation (Aquatone / EyeWitness)
* [ ] Vulnerability detection (XSS, SQLi patterns)
* [ ] Telegram alert integration
* [ ] Web dashboard (Flask)

---

## 🤝 Contributing

Contributions are welcome!

* Fork the repo
* Create a new branch
* Submit a pull request

---

## ⭐ Author

**Abhishek Patyal**
Cybersecurity Enthusiast | Penetration Tester

---

## 💬 Support

If you found this useful:

⭐ Star the repository
🍴 Fork it
📢 Share with the community

---
