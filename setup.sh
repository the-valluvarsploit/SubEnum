#!/bin/bash
#
# bash script to install SubEnum's dependencies 
#

# TOOLS_PATH="$HOME/bb/tools"
# WORKING_DIR=$(pwd)

GOlang() {
	printf "                                \r"
	sys=$(uname -m)
	LATEST=$(curl -s 'https://go.dev/VERSION?m=text')
	[ $sys == "x86_64" ] && wget https://golang.org/dl/$LATEST.linux-amd64.tar.gz -O golang.tar.gz &>/dev/null || wget https://golang.org/dl/$LATEST.linux-386.tar.gz -O golang.tar.gz &>/dev/null
	sudo tar -C /usr/local -xzf golang.tar.gz
	echo "export GOROOT=/usr/local/go" >> $HOME/.zshrc
	echo "export GOPATH=$HOME/go" >> $HOME/.zshrc
	echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> $HOME/.zshrc
	
	printf "[+] Golang Installed !.\n"
}

Findomain() {
	printf "                                \r"
	wget https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip &>/dev/null
	unzip findomain-linux.zip
	chmod +x findomain
	./findomain -h &>/dev/null && { sudo mv findomain /usr/local/bin/; printf "[+] Findomain Installed !.\n"; } || printf "[!] Install Findomain manually: https://github.com/Findomain/Findomain/blob/master/docs/INSTALLATION.md\n"
}

Subfinder() {
	printf "                                \r"
	# GO111MODULE=on go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder &>/dev/null
	go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null
	printf "[+] Subfinder Installed !.\n"
}

Amass() {
	printf "                                \r"
	# GO111MODULE=on go get -v github.com/OWASP/Amass/v3/... &>/dev/null
	go install -v github.com/OWASP/Amass/v3/...@master
	printf "[+] Amass Installed !.\n"
}

Assetfinder() {
	printf "                                \r"
	go get -u github.com/tomnomnom/assetfinder &>/dev/null
	printf "[+] Assetfinder Installed !.\n"
}

Crobat() {
	printf "                                \r"
	go install github.com/cgboal/sonarsearch/cmd/crobat@latest &>/dev/null
	printf "[+] Crobat Installed !.\n"
}

Waybackurls() {
	printf "                                \r"
	go install github.com/tomnomnom/waybackurls@latest &>/dev/null
	printf "[+] Waybackurls Installed !.\n"
}

Unfurl() {
	printf "                                \r"
	go install github.com/tomnomnom/unfurl@latest &>/dev/null
	printf "[+] Unfurl Installed !.\n"
}

Httprobe() {
	printf "                                \r"
	go get -u github.com/tomnomnom/httprobe
	printf "[+] Httprobe Installed !.\n"
}

Parallel() {
	printf "                                \r"
	sudo apt-get install parallel -y
	printf "[+] Parallel Installed !.\n"
}

hash go 2>/dev/null && printf "[!] Golang is already installed.\n" || { printf "[+] Installing GOlang!" && GOlang; } 

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

hash findomain 2>/dev/null && printf "[!] Findomain is already installed.\n" || { printf "[+] Installing Findomain!" && Findomain; }
hash subfinder 2>/dev/null && printf "[!] subfinder is already installed.\n" || { printf "[+] Installing subfinder!" && Subfinder; }
hash amass 2>/dev/null && printf "[!] Amass is already installed.\n" || { printf "[+] Installing Amass!" && Amass; }
hash assetfinder 2>/dev/null && printf "[!] Assetfinder is already installed.\n" || { printf "[+] Installing Assetfinder!" && Assetfinder; }
hash crobat 2>/dev/null && printf "[!] Crobat is already installed.\n" || { printf "[+] Installing Crobat!" && Crobat; }
hash waybackurls 2>/dev/null && printf "[!] Waybackurls is already installed.\n" || { printf "[+] Installing Waybackurls!" && Waybackurls; }
# [ -d "$TOOLS_PATH/OneForAll" ] && printf "[!] OneForAll is already installed.\n" || { printf "[+] Installing OneForAll!" && OneForAll; }
hash unfurl 2>/dev/null && printf "[!] Unfurl is already installed.\n" || { printf "[+] Installing Unfurl!" && Unfurl; }
hash httprobe 2>/dev/null && printf "[!] Httprobe is already installed.\n" || { printf "[+] Installing Httprobe!" && Httprobe; }
hash parallel 2>/dev/null && printf "[!] Parallel is already installed.\n" || { printf "[+] Installing Parallel!" && Parallel; }

list=(
	go
	findomain
	subfinder
	amass
	assetfinder
	crobat
	waybackurls
	unfurl
	httprobe
	Parallel
	)

r="\e[31m"
g="\e[32m"
e="\e[0m"

for prg in ${list[@]}
do
        hash $prg 2>/dev/null && printf "[$prg]$g Done$e\n" || printf "[$prg]$r Something Went Wrong! Try Again Manually.$e\n"
done
