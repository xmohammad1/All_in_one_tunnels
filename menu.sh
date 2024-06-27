#!/bin/bash

# Function to show the menu
show_menu() {
    echo "Please choose an option:"
    echo "1) VPNCloud"
    echo "2) Haproxy"
    echo "3) Local IPV6 & V4"
    echo "4) Matrix Network"
    echo "5) Local Tun"
    echo "6) 3X-UI (Sanai)"
    echo "7) VXLAN"
    echo "9) Exit"
}

# Loop until the user chooses to exit
while true; do
    show_menu
    read -p "Enter choice [1-5]: " choice
    case $choice in
        1)
            clear
            bash <(curl -LS https://raw.githubusercontent.com/xmohammad1/VCloud/main/vcloud.sh)
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
            bash <(curl -Ls https://raw.githubusercontent.com/persian-michael-scott/LocalTun_TCP_Script/main/Azumi_TUN.sh)
            clear
            ;;
        6)
            clear
            bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
            ;;
        7)
            bash <(curl -LS https://raw.githubusercontent.com/xmohammad1/vxlan/main/vxlan.sh)
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
