#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

print_cpu_percentage() {
	if command_exists "iostat"; then

		if is_linux_iostat; then
			iostat -cy 1 1 | tr -s ' ' ';' | grep -e '^;' |  cut -d ';' -f 7 | awk '{usage=100-$1} END {printf("%5.1f%%", usage)}'
		elif is_osx; then
			iostat -c 2 | tail -n 1 | tr -s ' ' ';' | cut -d ';' -f 7 | awk '{usage=100-$1} END {printf("%5.1f%%", usage)}'
		elif is_freebsd; then
			iostat -c 2 | tail -n 1 | tr -s ' ' ';' | cut -d ';' -f 11 | awk '{usage=100-$1} END {printf("%5.1f%%", usage)}'
		elif [ -e "/proc/stat" ]; then
			grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf("%5.1f%", usage)}'
		fi
	elif command_exists "sar"; then
		sar -u 1 1 | tail -n 1 | tr -s ' ' ';' | cut -d ';' -f 8 | awk '{usage=100-$1} END {printf("%5.1f%", usage)}'
	else
		if is_cygwin; then
			usage="$(WMIC cpu get LoadPercentage | grep -Eo '^[0-9]+')"
			printf "%5.1f%%" $usage
		else
			load=`ps -aux | awk '{print $3}' | tail -n+2 | awk '{s+=$1} END {print s}'`
			cpus=$(cpus_number)
			echo "$load $cpus" | awk '{printf "%3.0f%%", $1/$2}'
		fi
	fi
}

main() {
	print_cpu_percentage
}
main
