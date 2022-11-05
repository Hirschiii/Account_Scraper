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
    - pass

    Usage:
    -u:     Enter Pass / Service username
    -w:     Enter Service
    "
}

parser_uberspace () {
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

test_func ()
{
    echo $1
    echo $2
}

get_pass ()
{
    # $1 Benutzer
    password="$(pass $1 | head -1)"
    username="$(echo $1 | awk -F"/" '{print $2}')"

    parser_function $service $username $password
}

parser_function ()
{
    if [ "$1" == "uberspace" ]; then
        parser_uberspace $2 $3
    elif [ "$1" == "test" ]; then
        test_func $2 $3
    else
        echo "Error: Invalid Target: $1"
    fi
}

while getopts ":hw:u:" option; do
    case $option in
        h) help
            exit;;
        w) service=$OPTARG;;
        u) get_pass $OPTARG;;
    esac
done
