#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

GITHUB_RAW_IP="185.199.108.133"
grep -q "raw.githubusercontent.com" /etc/hosts
if [ $? -ne 0 ]; then
  echo "$GITHUB_RAW_IP raw.githubusercontent.com" >> /etc/hosts
fi
while true; do
    sleep 1.5
    clear
    echo "1) Local IPv6 AND IPv4"
    echo "2) HAProxy"
    echo "3) 3X-UI"
    echo "4) Rathole"
    echo "5) Reality Reverse Tunnel"
    echo "6) Direct Reality Tunnel"
    echo "9) Exit"
    read -p "Enter your choice [1-5]: " choice

    case $choice in
        1)
            bash <(curl -Ls https://raw.githubusercontent.com/xmohammad1/ipv6local/main/run.sh)
            ;;
        2)
            bash <(curl -Ls https://raw.githubusercontent.com/xmohammad1/ipv6local/main/Haproxy.sh)
            ;;
        3)
            bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
            ;;
        4)
            bash <(curl -Ls https://raw.githubusercontent.com/Musixal/rathole-tunnel/main/rathole.sh)
            ;;
        5)
            bash <(curl -Ls https://raw.githubusercontent.com/xmohammad1/Waterwall-RRT/main/setup.sh)
            ;;
        6)
            bash <(curl -Ls https://raw.githubusercontent.com/xmohammad1/Waterwall-RRT/main/RDT.sh)
            ;;
        9)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
