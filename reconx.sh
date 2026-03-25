#!/bin/bash

# ==============================
# ReconX - Auto Setup Recon Tool
# ==============================

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

echo -e "${BLUE}ReconX - Advanced Recon Toolkit${NC}"

# ------------------------------
# Install Tool Function
# ------------------------------
install_tool() {
    tool=$1

    echo -e "${YELLOW}[+] Installing $tool...${NC}"

    case $tool in
        subfinder)
            go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
            ;;
        assetfinder)
            go install github.com/tomnomnom/assetfinder@latest
            ;;
        httpx)
            go install github.com/projectdiscovery/httpx/cmd/httpx@latest
            ;;
        ffuf)
            go install github.com/ffuf/ffuf@latest
            ;;
        nmap)
            sudo apt install -y nmap
            ;;
        whatweb)
            sudo apt install -y whatweb
            ;;
        whois)
            sudo apt install -y whois
            ;;
        *)
            echo -e "${RED}[-] Unknown tool: $tool${NC}"
            ;;
    esac
}

# ------------------------------
# Dependency Check + Auto Install
# ------------------------------
check_tools() {
    tools=("subfinder" "assetfinder" "httpx" "ffuf" "nmap" "whatweb" "whois")

    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}[-] $tool not found!${NC}"
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
# Live Domains
# ------------------------------
probe_live() {
    echo -e "${YELLOW}[+] Probing live domains...${NC}"

    cat $output/subdomains.txt | httpx -silent >> $output/live.txt
}

# ------------------------------
# Port Scan
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
    echo -e "${YELLOW}[+] Running DNS & WHOIS...${NC}"

    for sub in $(cat $output/subdomains.txt); do
        dig +short $sub >> $output/dns.txt
    done

    whois $domain > $output/whois.txt
}

# ------------------------------
# Summary
# ------------------------------
summary() {
    echo -e "${GREEN}[+] Generating summary...${NC}"

    echo "Subdomains: $(wc -l < $output/subdomains.txt)" > $output/summary.txt
    echo "Live: $(wc -l < $output/live.txt)" >> $output/summary.txt
}

# ------------------------------
# Arguments
# ------------------------------
while getopts "d:o:" opt; do
    case $opt in
        d) domain=$OPTARG ;;
        o) output=$OPTARG ;;
    esac
done

if [ -z "$domain" ]; then
    echo -e "${RED}Usage: $0 -d domain.com -o output_folder${NC}"
    exit 1
fi

output=${output:-output/$domain}
mkdir -p $output

# ------------------------------
# Run
# ------------------------------
check_tools
subdomain_enum
probe_live
port_scan
dir_bruteforce
tech_detect
dns_lookup
summary

echo -e "${GREEN}[✔] Recon Completed! Results saved in $output${NC}"
