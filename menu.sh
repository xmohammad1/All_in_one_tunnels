#!/bin/bash

# Function to show the menu
show_menu() {
    echo "Please choose an option:"
    echo "1) EasyTier"
    echo "2) Haproxy"
    echo "3) Local IPV6 & V4"
    echo "4) Matrix Network"
    echo "5) WireGuard"
    echo "6) 3X-UI (Sanai)"
    echo "9) Exit"
}

# Loop until the user chooses to exit
while true; do
    show_menu
    read -p "Enter choice [1-5]: " choice
    case $choice in
        1)
            clear
            bash <(curl -Ls https://raw.githubusercontent.com/xmohammad1/easytier/main/easytier.sh)
            ;;
        2)
            clear
            bash <(curl -Ls https://raw.githubusercontent.com/xmohammad1/ipv6local/main/Haproxy.sh)
            ;;
        3)
            clear
            bash <(curl -Ls https://raw.githubusercontent.com/xmohammad1/ipv6local/main/run.sh)
            ;;
        4)
            clear
            bash <(curl -Ls https://raw.githubusercontent.com/Musixal/matrix-network/main/matrix.sh)
            ;;
        5)
            clear
            bash <(curl -LS https://raw.githubusercontent.com/xmohammad1/wireguard_tunnel/main/wireguard.sh)
            ;;
        6)
            clear
            bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
            ;;
        9)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice! Please select a valid option."
            ;;
    esac
done
