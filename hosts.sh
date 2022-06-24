#!/bin/sh
# tick nocross
list=$(curl -Ls 'https://v.firebog.net/hosts/lists.php?type=nocross')
list="$list
https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds.txt
https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-Samsung-AdBlock.txt
https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-Xiaomi-Extension.txt
https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Extension/GoodbyeAds-Spotify-AdBlock.txt
https://adaway.org/hosts.txt
https://phishing.army/download/phishing_army_blocklist_extended.txt
https://blokada.org/blocklists/ddgtrackerradar/standard/hosts.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt
https://blokada.org/blocklists/exodusprivacy/standard/hosts.txt
https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
https://blocklistproject.github.io/Lists/tracking.txt
https://blocklistproject.github.io/Lists/phishing.txt
https://blocklistproject.github.io/Lists/malware.txt
https://blocklistproject.github.io/Lists/facebook.txt
https://blocklistproject.github.io/Lists/ads.txt
https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt
https://hblock.molinero.dev/hosts_domains.txt
https://raw.githubusercontent.com/bongochong/CombinedPrivacyBlockLists/master/newhosts-final.hosts
https://someonewhocares.org/hosts/hosts
https://curben.gitlab.io/malware-filter/urlhaus-filter-hosts.txt
https://block.energized.pro/blu/formats/domains.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/trackers.list
https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/malware.list
https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt
https://www.github.developerdan.com/hosts/lists/dating-services-extended.txt
https://www.github.developerdan.com/hosts/lists/tracking-aggressive-extended.txt
https://raw.githubusercontent.com/d3ward/toolz/master/src/d3host.txt
https://raw.githubusercontent.com/badmojr/1Hosts/master/Xtra/hosts.txt"
# https://energized.pro/ultimate/formats/hosts.txt
add="i.tct-rom.com
g2master-us-east.tctmobile.com
g2master-us-west.tctmobile.com
g2master-eu-west.tctmobile.com
g2master-ap-south.tctmobile.com
g2master-ap-north.tctmobile.com
g2master-sa-east.tctmobile.com
g2master-us-west.tclclouds.com
g2master-us-east.tclclouds.com
g2master-eu-west.tclclouds.com
g2master-ap-north.tclclouds.com
g2master-ap-south.tclclouds.com
g2master-sa-east.tclclouds.com
g2slave-us-west-01.tctmobile.com
g2slave-us-east-01.tctmobile.com
g2slave-eu-west-01.tctmobile.com
g2slave-ap-north-01.tctmobile.com
aota.tclclouds.com"
list=$(echo "$list" | sort -u)

echo "List combined"


# LISTS:
# https://raw.githubusercontent.com/blokadaorg/blokada/master/android5/app/src/libre/kotlin/ui/PackDataSource.kt


dnsmasqlist="https://dnsmasq.oisd.nl/
https://dnsmasq.oisd.nl/extra/"

if [ "$1" == "-e" ] ; then
	exodus=$(curl -Ls https://reports.exodus-privacy.eu.org/en/trackers/ | grep "/trackers/" | grep "link black" | awk -F'/' '{print $4}' | sort -hu | sed 's|^|https://reports.exodus-privacy.eu.org/en/trackers/|')
	echo "Exodus combined"
	
	while IFS= read -r line ; do
		ex=$(curl -Ls "$line")
		echo "$ex" | grep -A1 '<h1 class="main-title">' | tail -n1 | sed 's/^[[:blank:]]\+//'
		echo "$ex" | grep "Network detection rule" | grep -o "<code>.*</code>" | sed 's/<\/\?code>//g;s/^NC$//;s/\\\././g;s/[[:blank:]]\+\?|[[:blank:]]\+\?/\n/g' | grep "[[:alnum:]]\.[[:alnum:]]" | sed 's/^\.//;s/\\-/-/g;s/^/0.0.0.0 /' >> /tmp/exodus 
	done <<< "$exodus"
	sed -i 's/\\-/-/g;s/\[//g;s/\]//g;s/\*//g' /tmp/exodus
	sed -i '/^0\.0\.0\.0[[:blank:]]\+\?$/d' /tmp/exodus
	sort -u /tmp/exodus -o /tmp/exodus
fi



while IFS= read -r line ; do
	file=$(curl -s "$line")
	echo "$file" | grep -v "^#" | grep -Po '^[a-z0-9-]+([\-\.]{1}[a-z0-9-]+)*\.[a-z-]{2,10}(:[0-9]{1,5})?(\/.*)?' | awk '{print $1}' | grep -v "\-\." >> /tmp/dnsmasq
	echo "$file" | grep "^127\.0\.0\.1[[:blank:]]\|0\.0\.0\.0[[:blank:]]" | sed 's/^127\.0\.0\.1/0.0.0.0/' >> /tmp/hosts
	echo "$file" | grep -v "^#" | grep "^[[:alnum:][:punct:]]\+$" | grep -c "^address=" | sed 's/^/0.0.0.0 /' >> /tmp/hosts
	echo "$file" | grep -v "^#" | grep -Po '^[a-z0-9-]+([\-\.]{1}[a-z0-9-]+)*\.[a-z-]{2,10}(:[0-9]{1,5})?(\/.*)?' | awk '{print $1}' | sed 's/^/0.0.0.0 /' >> /tmp/hosts
	echo "$line good"
done <<< "$list"

echo "$add" | sed 's/^/0.0.0.0 /' >> /tmp/hosts

echo "hosts done"

sort -u /tmp/dnsmasq -o /tmp/dnsmasq
sort -u /tmp/hosts -o /tmp/hosts
echo sorted
sed -i 's|^|address=/|;s|$|/#|' /tmp/dnsmasq
while IFS= read -r line ; do
	curl -Ls "$line" >> /tmp/dnsmasq
done <<< "$dnsmasqlist"
echo "dnsmasqed"

last=$(cat /tmp/dnsmasq | grep "^address=" | sed 's|^address=/||;s|/#$||' | tail -n1)
while [[ "$regex" -ne "$last" ]] ; do
	regex=$(cat /tmp/dnsmasq | grep "^address=" | sed 's|^address=/||;s|/#$||' | idn2 --no-tr46 2>/dev/null | tail -n1)
	sed -ie "/$regex/{n;d}" /tmp/dnsmasq
done

sort -u /tmp/dnsmasq -o /tmp/dnsmasq
echo 'done'
