# About
This docker image is for being able to update the Dynamic DNS available from Dynu.com.

This image uses curl and crontabs to execute the curl command necessary to update with Dynu.

Dynu curl documentation:
https://www.dynu.com/DynamicDNS/IPUpdateClient/cURL

# How to Use This Image

## Start This Container
Build the image
```
docker image build . --target=dynu_domain --tag dynu_dns
```

Run the image
```
docker run -d -e DYNU_PASSWORD=SHA256_PASSWORD -e DYNU_DOMAIN=example.domain.org dynu_dns
```

### Via Docker-Compose

```
version: '3.7'

services:
  ddns:
    container_name: dynu_dns
    build:
      context: .
      target: dynu_domain
    environment:
      - DYNU_PASSWORD=SHA256_PASSWORD
      - DYNU_DOMAIN=example.domain.org
      - VERIFY_DYNU_CONFIG=true
      - TIME_INTERVAL=*/5 * * * *
    restart: always
```

## Environment Variables
|Environment Variable | Optional | Purpose | Example Value | Default |
|---------------------|----------|---------|---------------|---------|
| DYNU_ALIAS          | Yes*     | Update the specified Dynu alias | | |
| DYNU_PASSWORD       | No       | The Dynu password as MD5 to use to authenticate to Dynu | | |
| DYNU_DOMAIN         | Yes*     | Update the specified Dynu domain | example.dynu.net | |
| DYNU_USERNAME       | Yes*     | Update all domains under the specified Dynu username | | |
| TIME_INTERVAL       | Yes      | Set the time interval for calling the Dynu IP update API, must be specified in a cron format | * * * * * | */10 * * * * |
| UPDATE_IP_V4        | Yes      | Update the IP v4 address | false | true |
| UPDATE_IP_V6        | Yes      | Update the IP v6 address | false | true |
| VERIFY_DYNU_CONFIG  | Yes      | On container startup verify that the cURL command gets a successful response from Dynu | false | true |

*Either a username has to provided, a hostname, or an alias, a hostname, and username.

Visit https://www.dynu.com/NetworkTools/Hash to get MD5 or SHA256 hash value of your password