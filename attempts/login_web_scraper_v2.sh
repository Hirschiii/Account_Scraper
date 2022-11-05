#!/bin/bash

help ()
{
    echo "
    Login Account Manager V2

    Ein Tool um den Kontostand von verschieden Online-Konten abzufragen.

    Dependencies:
    - curl
    - pandoc
    - awk
    - sed

    Usage:
    -u:     Enter Username
    -p:     Enter Password
    -w:     Enter Service
    "
}

# Variables

username="world"
password="123654"

uberspace () {
    # $1 Username
    # $2 Password
    curl -s -o /dev/null -c /tmp/login_web_scraper 'https://dashboard.uberspace.de/login' \
        --data-raw "_csrf_token=634F9E33639560772251F5E3E91FBF43&login=$1&password=$2&submit=login" \
        --compressed 



    curl -s -o /tmp/accounting.html --cookie /tmp/login_web_scraper https://dashboard.uberspace.de/dashboard/accounting 
    pandoc -o /tmp/html-text.txt /tmp/accounting.html

    cat /tmp/html-text.txt | grep "beträgt derzeit" | \
        awk '{ print $4 }' | sed "s/**//g" | sed "s/ €.//"

}

call_function ()
{
    if [ "$1" == "uberspace" ]; then
        uberspace $username $password
    else
        echo "Error: Invalid Target: $1"
    fi
}

while getopts ":hu:p:w:" option; do
    case $option in
        h) help
            exit;;
        u) username="$OPTARG";;
        p) password="$OPTARG";;
        w) call_function $OPTARG;;
    esac
done
