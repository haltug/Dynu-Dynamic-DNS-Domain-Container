#!/bin/sh

# Build the URL to curl
http_protocol="http"
base_url="://api.dynu.com/nic/update?"
url=""
ip_v4=""
ip_v6=""

# Create the url to update dynu for an alias

build_url_update_alias () {
    #http://api.dynu.com/nic/update?hostname=example.dynu.com&alias=Alias&username=USERNAME&password=PASSWORD
    url="hostname=$DYNU_DOMAIN&alias=$DYNU_USERNAME&password=$DYNU_APIKEY"
}

# Create the url to update dynu for a domain
build_url_update_domain () {
    #http://api.dynu.com/nic/update?hostname=example.dynu.com&password=PASSWORD
    url="hostname=$DYNU_DOMAIN&password=$DYNU_APIKEY"
}

# Create the url to update dynu for a username
build_url_update_username () {
    #http://api.dynu.com/nic/update?username=USERNAME&password=PASSWORD
    url="username=$DYNU_USERNAME&password=$DYNU_APIKEY"

}



# Break the script, there is not enough information available

# If an apikey is not provided, fail
if [ -z "$DYNU_APIKEY" ] ; then
    echo "DYNU_APIKEY is missing"
    exit 1
fi

# If alias is set but hostname and username are not, fail
if [ ! -z "$DYNU_ALIAS" ] && [ -z "$DYNU_DOMAIN" ] && [ -z "$DYNU_USERNAME" ] ; then
    echo "An alias was provided but there is either no domain or username provided"
    exit 1
fi



# Create the url to use

if [ ! -z "$DYNU_ALIAS" ] && [ ! -z "$DYNU_DOMAIN" ] && [ ! -z "$DYNU_USERNAME" ] ; then
    # Update alias
    build_url_update_alias

# Restrict the update to the domain instead of all domains
elif [ ! -z "$DYNU_DOMAIN" ] && [ ! -z "$DYNU_USERNAME" ] ; then
    echo "A username and domain have been provided, only the domain will be updated"
    build_url_update_domain

elif [ ! -z "$DYNU_USERNAME" ] ; then
    # Update all domains on the username
    build_url_update_username

elif [ ! -z "$DYNU_DOMAIN" ] ; then
    # Update the specific domain
    build_url_update_domain
else
    echo "A domain or username is required"
    exit 1
fi


# This part is independent of whether an alias, a domain, or username is being updated 

# Use https instead of http
if [ "$USE_SSL" = true ] ; then
    http_protocol="https"
fi

# Create the additional param for not updating ip v6
if [ "$UPDATE_IP_V6" = false ] ; then
    ip_v6="&myipv6=no"
fi

# Create the additional param for not updating ip v4
if [ "$UPDATE_IP_V4" = false ] ; then
    ip_v4="&myip=no"
fi



# Create the URL to use

url="$http_protocol$base_url$url$ip_v4$ip_v6"

# Run the dynu script once to register current IP address at container startup
echo $(date && printf ": " && curl -s $url)

# Create the dynu script

filename="/scripts/dynu.sh"
echo "#!/bin/sh" > $filename
echo -n 'echo $(date && printf ": " && curl -s "' >> $filename
# Replace $url with the variable value on the file
echo -n $url\"")" >> $filename

chmod +x $filename



# Create the crontab file

crontab_file="/scripts/crontab.txt"

cat > $crontab_file <<EOF
$TIME_INTERVAL $filename > /dev/stdout
EOF

/usr/bin/crontab $crontab_file

# start cron
/usr/sbin/crond -f -l 8