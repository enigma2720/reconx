#!/bin/bash

# ==============================
# ReconX Elite - Recon Framework
# ==============================

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

echo -e "${BLUE}🔍 ReconX Elite - Advanced Recon Framework${NC}"

# ------------------------------
# Load Config
# ------------------------------
if [ -f config.conf ]; then
    source config.conf
else
    echo -e "${RED}[-] config.conf not found!${NC}"
fi

# ------------------------------
# Install Tools
# ------------------------------
install_tool() {
    tool=$1
    echo -e "${YELLOW}[+] Installing $tool...${NC}"

    case $tool in
        subfinder)
            go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest ;;
        assetfinder)
            go install github.com/tomnomnom/assetfinder@latest ;;
        httpx)
            go install github.com/projectdiscovery/httpx/cmd/httpx@latest ;;
        ffuf)
            go install github.com/ffuf/ffuf@latest ;;
        nmap)
            sudo apt install -y nmap ;;
        whatweb)
            sudo apt install -y whatweb ;;
        whois)
            sudo apt install -y whois ;;
        jq)
            sudo apt install -y jq ;;
    esac
}

# ------------------------------
# Check Dependencies
# ------------------------------
check_tools() {
    tools=("subfinder" "assetfinder" "httpx" "ffuf" "nmap" "whatweb" "whois" "jq")

    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}[-] $tool not found${NC}"
            install_tool $tool
        else
            echo -e "${GREEN}[✔] $tool found${NC}"
        fi
    done
}

# ------------------------------
# Subdomain Enumeration
# ------------------------------
subdomain_enum() {
    echo -e "${YELLOW}[+] Enumerating subdomains...${NC}"

    (subfinder -d $domain -silent >> $output/subdomains.txt &)
    (assetfinder --subs-only $domain >> $output/subdomains.txt &)
    wait

    sort -u $output/subdomains.txt -o $output/subdomains.txt
}

# ------------------------------
# VirusTotal Integration
# ------------------------------
vt_enum() {
    if [ -z "$VT_API_KEY" ]; then
        echo -e "${RED}[-] No VirusTotal API key${NC}"
        return
    fi

    echo -e "${YELLOW}[+] VirusTotal enumeration...${NC}"

    curl -s "https://www.virustotal.com/api/v3/domains/$domain/subdomains" \
    -H "x-apikey: $VT_API_KEY" \
    | jq -r '.data[].id' >> $output/vt_subdomains.txt

    cat $output/vt_subdomains.txt >> $output/subdomains.txt
    sort -u $output/subdomains.txt -o $output/subdomains.txt
}

# ------------------------------
# Live Domains
# ------------------------------
probe_live() {
    echo -e "${YELLOW}[+] Probing live domains...${NC}"

    cat $output/subdomains.txt | httpx -silent >> $output/live.txt
}

# ------------------------------
# Port Scanning
# ------------------------------
port_scan() {
    echo -e "${YELLOW}[+] Running Nmap scan...${NC}"

    nmap -iL $output/live.txt -T4 -Pn -oN $output/ports.txt
}

# ------------------------------
# Directory Bruteforce
# ------------------------------
dir_bruteforce() {
    echo -e "${YELLOW}[+] Running directory brute-force...${NC}"

    for url in $(cat $output/live.txt); do
        ffuf -u "$url/FUZZ" -w wordlists/common.txt -mc 200 >> $output/dirs.txt
    done
}

# ------------------------------
# Shodan Integration
# ------------------------------
shodan_scan() {
    if [ -z "$SHODAN_API_KEY" ]; then
        echo -e "${RED}[-] No Shodan API key${NC}"
        return
    fi

    echo -e "${YELLOW}[+] Shodan scan...${NC}"

    ip=$(dig +short $domain | head -n 1)

    curl -s "https://api.shodan.io/shodan/host/$ip?key=$SHODAN_API_KEY" \
    | jq '.' > $output/shodan.json
}

# ------------------------------
# Tech Detection
# ------------------------------
tech_detect() {
    echo -e "${YELLOW}[+] Detecting technologies...${NC}"

    whatweb -i $output/live.txt > $output/tech.txt
}

# ------------------------------
# DNS + WHOIS
# ------------------------------
dns_lookup() {
    echo -e "${YELLOW}[+] DNS & WHOIS...${NC}"

    for sub in $(cat $output/subdomains.txt); do
        dig +short $sub >> $output/dns.txt
    done

    whois $domain > $output/whois.txt
}

# ------------------------------
# Google Dorks
# ------------------------------
google_dorks() {
    echo -e "${YELLOW}[+] Generating Google dorks...${NC}"

    dorks=(
        "site:$domain ext:php"
        "site:$domain inurl:admin"
        "site:$domain intitle:index of"
        "site:$domain filetype:sql"
        "site:$domain ext:log"
    )

    for dork in "${dorks[@]}"; do
        echo "https://www.google.com/search?q=$dork" >> $output/dorks.txt
    done
}

# ------------------------------
# Resume Feature
# ------------------------------
resume_check() {
    if [ -f "$output/subdomains.txt" ]; then
        echo -e "${YELLOW}[!] Previous scan detected. Resuming...${NC}"
    fi
}

# ------------------------------
# Summary
# ------------------------------
summary() {
    echo -e "${GREEN}[+] Generating summary...${NC}"

    echo "Subdomains: $(wc -l < $output/subdomains.txt)" > $output/summary.txt
    echo "Live: $(wc -l < $output/live.txt)" >> $output/summary.txt
    echo "Ports scanned: $(wc -l < $output/ports.txt)" >> $output/summary.txt
}

# ------------------------------
# CLI Arguments
# ------------------------------
while getopts "d:o:" opt; do
    case $opt in
        d) domain=$OPTARG ;;
        o) output=$OPTARG ;;
    esac
done

if [ -z "$domain" ]; then
    echo -e "${RED}Usage: $0 -d domain.com [-o output/]${NC}"
    exit 1
fi

output=${output:-output/$domain}
mkdir -p $output

# ------------------------------
# Execution Flow
# ------------------------------
check_tools
resume_check
vt_enum
subdomain_enum
probe_live
port_scan
shodan_scan
google_dorks
tech_detect
dns_lookup
dir_bruteforce
summary

echo -e "${GREEN}[✔] Recon Completed! Results in $output${NC}"
