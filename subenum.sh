#!/bin/bash
#
# script for subdomain enumeration using 4 of the best tools and some online services:
#   * findomain: https://github.com/Edu4rdSHL/findomain
#   * SubFinder: https://github.com/projectdiscovery/subfinder
#   * Amass: https://github.com/OWASP/Amass
#   * AssetFinder: https://github.com/tomnomnom/assetfinder
#

bold="\e[1m"
Underlined="\e[4m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
end="\e[0m"
VERSION="2022-03-20"
# TOOLS_PATH="$HOME/bb/tools"

PRG=${0##*/}


Usage(){
	while read -r line; do
		printf "%b\n" "$line"
	done <<-EOF
	\r
	\r# ${bold}${blue}Options${end}:
	\r    -d, --domain       - Domain To Enumerate
	\r    -l, --list         - List of domains
	\r    -u, --use          - Tools To Be Used ex(Findomain,Subfinder,...,etc)
	\r    -e, --exclude      - Tools To Be Excluded ex(Findomain,Amass,...,etc)
	\r    -o, --output       - The output file to save the Final Results (Default: <TargetDomain>-DATE-TIME.txt)
	\r    -s, --silent       - The Only output will be the found subdomains - (Results saved: subenum-<DOMAIN>.txt).
	\r    -k, --keep         - To Keep the TMPs files (the results from each tool).
	\r    -r, --resolve      - To Probe For Working HTTP and HTTPS Subdomains, (Output: resolved-<DOMAIN>.txt).
	\r    -t, --thread       - Threads for Httprobe - works with -r/--resolve option (Default: 40)
	\r    -p, --parallel     - To Use Parallel For Faster Results, Doesn't Work With -e/--exclude or -u/--use. 
	\r    -h, --help         - Displays this help message and exit.
	\r    -v, --version      - Displays the version and exit.

	\r# ${bold}${blue}Available Tools${end}:
	\r	  Waybackurls,Findomain,Subfinder,Amass,Assetfinder,Crobat

	\r# ${bold}${blue}Examples${end}:
	\r    - To use a specific Tool(s):
	\r       $PRG -d hackerone.com -u Findomain,Waybackurls,Subfinder
	\r    - To exclude a specific Tool(s):
	\r       $PRG -d hackerone.com -e Amass,Assetfinder
	\r    - To use all the Tools:
	\r       $PRG -d hackerone.com 
	\r    - To run SubEnum.sh against a list of domains:
	\r       $PRG -l domains.txt
	\r    - Run with parallel for faster results, (Doesn't work with -e/--exclude or -u/--use).
	\r       1- $PRG --domain target.com --parallel
	\r       2- $PRG --list domains.txt --parallel
EOF
	exit 1
}


spinner(){
	processing="${1}"
	while true; 
	do
		dots=(
			"/"
			"-"
			"\\"
			"|"
			)
		for dot in ${dots[@]};
		do
			printf "[${dot}] ${processing} \U1F50E"
			printf "                                    \r"
			sleep 0.3
		done
		
	done
}

Waybackurls() {
	[ "$silent" == True ] && waybackurls $domain | unfurl -u domain | anew subenum-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${bold}Waybackurls${end}" &
			PID="$!"
		}
		waybackurls $domain | unfurl -u domain > tmp-waybackurls-$domain
		kill ${PID} 2>/dev/null
		echo -e "$bold[*] Waybackurls$end: $(wc -l < tmp-waybackurls-$domain)"
	}	
}

Findomain() {
	[ "$silent" == True ] && findomain -t $domain -q 2>/dev/null | anew subenum-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${bold}Findomain${end}" &
			PID="$!"
		}
		findomain -t $domain -u tmp-findomain-$domain &>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$bold[*] Findomain$end: $(wc -l tmp-findomain-$domain 2>/dev/null | awk '{print $1}')"
	}
}

Subfinder() {
	[ "$silent" == True ] && subfinder -all -silent -d $domain 2>/dev/null | anew subenum-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${bold}SubFinder${end}" &
			PID="$!"
		}
		subfinder -all -silent -d $domain 1> tmp-subfinder-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$bold[*] SubFinder$end: $(wc -l < tmp-subfinder-$domain)"
	}
}

Amass() {
	# amass is with "-passive" option to make it faster, but it may cuz less results
	[ "$silent" == True ] && amass enum -passive -norecursive -noalts -d $domain 2>/dev/null | anew subenum-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${bold}Amass${end}" &
			PID="$!"
		}
		amass enum -passive -norecursive -noalts -d $domain 1> tmp-amass-$domain 2>/dev/null
		[[ ${PARALLEL} == True ]] || kill ${PID} 2>/dev/null
		echo -e "$bold[*] Amass$end: $(wc -l < tmp-amass-$domain)"
	}
}

Assetfinder() {
	[ "$silent" == True ] && assetfinder --subs-only $domain | anew subenum-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${bold}AssetFinder${end}" &
			PID="$!"
		}
		assetfinder --subs-only $domain > tmp-assetfinder-$domain
		kill ${PID} 2>/dev/null
		echo -e "$bold[*] AssetFinder$end: $(wc -l < tmp-assetfinder-$domain)"
	}
}

Crobat() {
	[ "$silent" == True ] && crobat -s $domain | anew subenum-$domain.txt || {
		[[ ${PARALLEL} == True ]] || { spinner "${bold}Crobat${end}" &
			PID="$!"
		}
		crobat -s $domain > tmp-crobat-$domain
		kill ${PID} 2>/dev/null
		echo -e "$bold[*] Crobat$end: $(wc -l < tmp-crobat-$domain)"
	}	
}

USE() {
	for i in $lu; do
		$i
	done
	[[ $out != False ]] && OUT $out || out
}


EXCLUDE() {
	for i in ${list[@]}; do
		if [[ " ${le[@]} " =~ " ${i} " ]]; then
			continue
		else
			$i
		fi
	done
	[[ $out != False ]] && OUT $out || out
}

OUT(){
	[ "$silent" == False ] && { 
		[ -n "$1" ] && out="$1" || out="$domain-$(date +'%Y-%m-%d').txt"
		result=$(sort -u tmp-* | wc -l)
		sort -u tmp-* >> $out
		echo -e $green"[+] The Final Results:$end ${result}"
		[ $resolve == True ] && ALIVE "$out" "$domain"

		[ $delete == True ] && rm tmp-*	
	}
}


ALIVE(){
	[ "$silent" == False ] && printf "$bold[+] Resolving $end"
	printf "                        \r"
	cat $1 | httprobe -c $thread > "resolved-$2.txt"
	[ "$silent" == False ] && echo -e $green"[+] Resolved:$end $(wc -l < resolved-$2.txt)"

}


LIST() {
	lines=$(wc -l < $hosts)
	count=1
	while read domain; do
		[ "$silent" == False ] && echo -e "\n${Underlined}${bold}${green}[+] Domain ($count/$lines):${end} ${domain}"
		[ $prv == "a" ] && {
			[[ ${PARALLEL} == True ]] && {
				spinner "Reconnaissance" &
				PID="$!"
				export -f Waybackurls Findomain Subfinder Amass Assetfinder Crobat spinner
				export domain silent bold end
				parallel -j7 ::: Waybackurls Findomain Subfinder Amass Assetfinder Crobat
				kill ${PID}
				[[ $out != False ]] && OUT $out || out
			} || {
				Waybackurls
				Findomain 
				Subfinder 
				Amass 
				Assetfinder
				Crobat
				[[ $out != False ]] && OUT $out || out
			}
		}
		[ $prv == "e" ] && EXCLUDE 
		[ $prv == "u" ] && USE 
		let count+=1
	done < $hosts
}

Main() {
	[ $domain == False ] && [ $hosts == False ] && { echo -e $red"[-] Argument -d/--domain OR -l/--list is Required!"$end; Usage; }
	[ $use != False ] && [ $exclude != False ] && { echo -e $Underlined$red"[!] You can use only one Option: -e/--exclude OR -u/--use"$end; Usage; }
	[ $domain != False ] && { 
		[ $use == False ] && [ $exclude == False ] && { 
			[[ ${PARALLEL} == True ]] && {
				spinner "Reconnaissance" &
				PID="$!"
				export -f Waybackurls Findomain Subfinder Amass Assetfinder Crobat spinner
				export domain silent bold end
				parallel -j7 ::: Waybackurls Findomain Subfinder Amass Assetfinder Crobat
				kill ${PID}
			} || {
				Waybackurls
				Findomain 
				Subfinder
				Amass 
				Assetfinder
				Crobat
			}
			[ "$out" == False ] && OUT || OUT $out
		} || { 
			[ $use != False ] && USE 
			[ $exclude != False ] && EXCLUDE
		}
	}
	[ "$hosts" != False ] && { 
		[ $use != False ] && prv=u
		[ $exclude != False ] && prv=e
		[ $use == False ] && [ $exclude == False ] && prv=a
		LIST
	 } 
}


domain=False
hosts=False
use=False
exclude=False
silent=False
delete=True
out=False
resolve=False
thread=40
PARALLEL=False

list=(
	Waybackurls
	Findomain 
	Subfinder 
	Amass 
	Assetfinder
	Crobat
	)

while [ -n "$1" ]; do
	case $1 in
		-d|--domain)
			domain=$2
			shift ;;
		-l|--list)
			hosts=$2
			shift ;;
		-u|--use)
			use=$2
			lu=${use//,/ }
			for i in $lu; do
				if [[ ! " ${list[@]} " =~ " ${i} " ]]; then
					echo -e $red$Underlined"[-] Unknown Function: $i"$end
					Usage
				fi
			done
			shift ;;
		-e|--exclude)
			exclude=$2
			le=${exclude//,/ }
			for i in $le; do
				if [[ ! " ${list[@]} " =~ " ${i} " ]]; then
					echo -e $red$Underlined"[-] Unknown Function: $i"$end
					Usage
				fi
			done
			shift ;;
		-o|--output)
			out=$2
			shift ;;
		-s|--silent)
			silent=True ;;
		-k|--keep)
			delete=False ;;
		-r|--resolve)
			resolve=True ;;
		-t|--thread)
			thread=$2
			shift ;;
		-h|--help)
			Usage;;
		-p|--parallel)
			PARALLEL=True ;;
		-v|--version)
			echo "Version: $VERSION"
			exit 0 ;;
		*)
			echo "[-] Unknown Option: $1"
			Usage ;;
	esac
	shift
done

[ "$silent" == False ] && echo -e $blue$bold"""
 ____        _     _____                       
/ ___| _   _| |__ | ____|_ __  _   _ _ __ ___  
\___ \| | | | '_ \|  _| | '_ \| | | | '_ \` _ \\ 
 ___) | |_| | |_) | |___| | | | |_| | | | | | |
|____/ \__,_|_.__/|_____|_| |_|\__,_|_| |_| |_|
           Subdomains Enumeration Tool
              By: bing0o @hack1lab
"""$end

Main
