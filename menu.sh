#!/bin/bash

EASY_CLIENT='/root/easytier/easytier-cli'
SERVICE_FILE="/etc/systemd/system/easymesh.service"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
RESET="\033[0m"
MAGENTA="\033[0;35m"
colorize() {
    local color="$1"
    local text="$2"
    local style="${3:-normal}"
    
    # Define ANSI color codes
    local black="\033[30m"
    local red="\033[31m"
    local green="\033[32m"
    local yellow="\033[33m"
    local blue="\033[34m"
    local magenta="\033[35m"
    local cyan="\033[36m"
    local white="\033[37m"
    local reset="\033[0m"
    
    # Define ANSI style codes
    local normal="\033[0m"
    local bold="\033[1m"
    local underline="\033[4m"
    # Select color code
    local color_code
    case $color in
        black) color_code=$black ;;
        red) color_code=$red ;;
        green) color_code=$green ;;
        yellow) color_code=$yellow ;;
        blue) color_code=$blue ;;
        magenta) color_code=$magenta ;;
        cyan) color_code=$cyan ;;
        white) color_code=$white ;;
        *) color_code=$reset ;;  # Default case, no color
    esac
    # Select style code
    local style_code
    case $style in
        bold) style_code=$bold ;;
        underline) style_code=$underline ;;
        normal | *) style_code=$normal ;;  # Default case, normal text
    esac

    # Print the colored and styled text
    echo -e "${style_code}${color_code}${text}${reset}"
}
install_unzip() {
    if ! command -v unzip &> /dev/null; then
        # Check if the system is using apt package manager
        if command -v apt-get &> /dev/null; then
            echo -e "${RED}unzip is not installed. Installing...${NC}"
            sleep 1
            sudo apt-get update
            sudo apt-get install -y unzip
        else
            echo -e "${RED}Error: Unsupported package manager. Please install unzip manually.${NC}"
            read -p "Press any key to continue..."
            exit 1
        fi
    fi
}
install_easytier() {
    # Define the directory and files
    DEST_DIR="/root/easytier"
    FILE1="easytier-core"
    FILE2="easytier-cli"
    URL_X86="https://github.com/EasyTier/EasyTier/releases/download/v1.1.0/easytier-x86_64-unknown-linux-musl-v1.1.0.zip"
    URL_ARM_SOFT="https://github.com/EasyTier/EasyTier/releases/download/v1.1.0/easytier-armv7-unknown-linux-musleabi-v1.1.0.zip"              
    URL_ARM_HARD="https://github.com/EasyTier/EasyTier/releases/download/v1.1.0/easytier-armv7-unknown-linux-musleabihf-v1.1.0.zip"
    
    
    # Check if the directory exists
    if [ -d "$DEST_DIR" ]; then    
        # Check if the files exist
        if [ -f "$DEST_DIR/$FILE1" ] && [ -f "$DEST_DIR/$FILE2" ]; then
            return 0
        fi
    fi
    
    # Detect the system architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        URL=$URL_X86
        ZIP_FILE="/root/easytier/easytier-x86_64-unknown-linux-musl-v1.1.0.zip"
    elif [ "$ARCH" = "armv7l" ] || [ "$ARCH" = "aarch64" ]; then
        if [ "$(ldd /bin/ls | grep -c 'armhf')" -eq 1 ]; then
            URL=$URL_ARM_HARD
            ZIP_FILE="/root/easytier/easytier-armv7-unknown-linux-musleabihf-v1.1.0.zip"
        else
            URL=$URL_ARM_SOFT
            ZIP_FILE="/root/easytier/easytier-armv7-unknown-linux-musleabi-v1.1.0.zip"
        fi
    else
        colorize red "Unsupported architecture: $ARCH" bold
        return 1
    fi


    colorize yellow "Installing EasyTier Core..." bold
    mkdir -p $DEST_DIR &> /dev/null
    curl -L $URL -o $ZIP_FILE &> /dev/null
    unzip $ZIP_FILE -d $DEST_DIR &> /dev/null
    rm $ZIP_FILE &> /dev/null

    if [ -f "$DEST_DIR/$FILE1" ] && [ -f "$DEST_DIR/$FILE2" ]; then
        return 0
    else
        colorize red "Failed to install Core..." bold
        return 1
    fi
}
generate_random_secret() {
    openssl rand -hex 16
}
connect_network_pool(){
    local use_defaults=$1
    if [ "$use_defaults" -eq 1 ]; then
        PEER_ADDRESS=""
        IP_ADDRESS="10.144.144.1"
        HOSTNAME="Main"
        NETWORK_SECRET=$(generate_random_secret)

    else
        read -p "Your Main Server Public IP: " PEER_ADDRESS
        read -e -i "10.144.144.2" -p "[*] Enter a Local IP : " IP_ADDRESS
        IP_ADDRESS=${IP_ADDRESS:-10.144.144.2}
        if [ -z $IP_ADDRESS ]; then
            colorize red "Null value. aborting..."
            return 1
        fi
        read -r -p "[*] Enter a Name (e.g., Hetnzer): " HOSTNAME
        if [ -z $HOSTNAME ]; then
            colorize red "Null value. aborting..."
            return 1
        fi
        while true; do
        read -p "[*] Enter Network Secret On Main Server: " NETWORK_SECRET
        if [[ -n $NETWORK_SECRET ]]; then
            break
        else
            colorize red "Network secret cannot be empty. Please enter a valid secret."
        fi
        done
    fi


	
	port="11010"
    DEFAULT_PROTOCOL="udp"
	ENCRYPTION_OPTION="--disable-encryption"
	
	
	if [ ! -z $PEER_ADDRESS ]; then
		PEER_ADDRESS="--peers ${DEFAULT_PROTOCOL}://${PEER_ADDRESS}:${port}"
    fi
    
    SERVICE_FILE="/etc/systemd/system/easymesh.service"
    
cat > $SERVICE_FILE <<EOF
[Unit]
Description=EasyMesh Network Service
After=network.target

[Service]
ExecStart=/root/easytier/easytier-core -i $IP_ADDRESS $PEER_ADDRESS --hostname $HOSTNAME --network-secret $NETWORK_SECRET --default-protocol $DEFAULT_PROTOCOL --multi-thread $ENCRYPTION_OPTION
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd, enable and start the service
    sudo systemctl daemon-reload &> /dev/null
    sudo systemctl enable easymesh.service &> /dev/null
    sudo systemctl start easymesh.service &> /dev/null

    colorize green "Network Service Started." bold
    if [ "$use_defaults" -eq 1 ]; then
        ipv4_address=$(curl -s https://api.ipify.org)
        echo "Server Public IPv4 is : $ipv4_address"
        colorize cyan "[✓] Generated Network Secret: $NETWORK_SECRET" bold
    fi
    echo "Server Local IPv4 created : $IP_ADDRESS"
    echo "you can select number 3 and to see these again"
    read -p "Press any key to continue..."
}

remove_easymesh_service() {
	echo ''
	if [[ ! -f $SERVICE_FILE ]]; then
		 echo "Service does not exists."
		 return 1
	fi
    echo "	Stopping Service..."
    sudo systemctl stop easymesh.service &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Service stopped successfully."
    else
        echo  "Failed to stop service."
        sleep 2
        return 1
    fi

    echo "	Disabling service..."
    sudo systemctl disable easymesh.service &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Service disabled successfully."
    else
        echo "	Failed to disable service."
        return 1
    fi

    echo "	Removing service..."
    sudo rm /etc/systemd/system/easymesh.service &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Service removed successfully."
    else
        echo "Failed to remove service."
        return 1
    fi

    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload
    if [[ $? -eq 0 ]]; then
        echo "Systemd daemon reloaded successfully."
    else
        echo "Failed to reload systemd daemon."
        sleep 2
        return 1
    fi
    
 read -p "Press any key to continue..."
}

display_routes(){

	$EASY_CLIENT route	
    read -p "Press any key to continue..."
}

show_network_secret() {
	echo ''
    if [[ -f $SERVICE_FILE ]]; then
        NETWORK_SECRET=$(grep -oP '(?<=--network-secret )[^ ]+' $SERVICE_FILE)
        
        if [[ -n $NETWORK_SECRET ]]; then
            colorize cyan "	Network Secret Key: $NETWORK_SECRET" bold
        else
            colorize red "	Network Secret key not found" bold
        fi
    else
        colorize red "Service does not exists." bold
    fi
    echo ''
    read -p "Press any key to continue..."
   
    
}

while true; do
    echo ""
    echo "1) Make Main Server Setup"
    echo "2) connect node server"
    echo "3) Display Secret Key"
    echo "4) Display Routes"
    echo "5) Remove Completely"
    echo "9) Back"
    read -p "Enter your choice : " choice

    case $choice in
        1)
            install_unzip
            install_easytier
            connect_network_pool 1
            ;;
        2)
            install_unzip
            install_easytier
            connect_network_pool 2
            ;;
        3)
            show_network_secret
            ;;
        4)
            display_routes
            ;;
        5)
            remove_easymesh_service
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
