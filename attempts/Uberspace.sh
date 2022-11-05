#!/bin/bash

help ()
{
    echo "
    Login Account Manager V2

    Ein Tool um den Kontostand von verschieden Online-Konten abzufragen.
    das Passwort wird via pass ermittelt. Dabei wird nach dem Syntax vorgegangen:

    $4/$3/$5

    Dependencies:
    - curl
    - pass
    - pandoc
    - awk
    - sed
    - pass

    Usage:
    $1:     uberspace (parser)
    $2:     search (konto, mon gb)
    $3:     The pass middle
    $4:     A1 (pass)
    $5:     B1 (pass)
    "
}

parser_uberspace () {
    # $1 Username
    # $2 Password

    if ! [ -f /tmp/login_web_scraper_$1 ] || ! [ -f /tmp/accounting_$1.html ] || ! [ -f /tmp/html-text_$1.txt ]; then

        curl -s -o /dev/null -c /tmp/login_web_scraper_$1 'https://dashboard.uberspace.de/login' --data-raw "_csrf_token=634F9E33639560772251F5E3E91FBF43&login=$1&password=$2&submit=login" --compressed
        curl -s -o /tmp/accounting_$1.html --cookie /tmp/login_web_scraper_$1 https://dashboard.uberspace.de/dashboard/accounting
        pandoc -o /tmp/html-text_$1.txt /tmp/accounting_$1.html
    fi




    if [ "$3" == "konto" ]; then
        uberspace_konto $1
    elif [ "$3" == "mon" ]; then
        uberspace_mon $1
    elif [ "$3" == "gb" ]; then
        uberspace_gb $1
    else 
        echo "Error: Invalid search: $3"
    fi

}

uberspace_gb ()
{
    cat /tmp/html-text_$1.txt | grep "zusätzlicher Speicherplatz" | awk '{ print $3 }' | sed "s/ GB//"
}

uberspace_mon ()
{
    cat /tmp/html-text_$1.txt | grep "Summe" | awk '{ print $2 }' | sed "s/ €//"
}
uberspace_konto () 
{
    cat /tmp/html-text_$1.txt | grep "beträgt derzeit" | \
        awk '{ print $4 }' | sed "s/**//g" | sed "s/ €.//"
}

test_func ()
{
    echo $1
    echo $2
}

get_pass ()
{
    # $1:     uberspace (parser)
    # $2:     konto / mon 
    # $3:     The pass middle
    # $4:     A1 (pass)
    # $5:     B1 (pass)

    pass_out="pass $4/$3/$5"
    password="$($pass_out | head -1)"
    username="$($pass_out | grep "User" | awk '{ print $2 }' )"

    # echo "
    # pas: $password
    # usr: $username
    # "

    parser_function $1 $username $password $2
}


parser_function ()
{
    if [ "$1" == "uberspace" ]; then
        parser_uberspace $2 $3 $4
    elif [ "$1" == "test" ]; then
        test_func $2 $3 $4
    else
        echo "Error: Invalid Target: $1"
    fi
}

if [ "$1" == "-h" ]; then
    help
elif [ "$1" == "uberspace" ]; then
    # one=$(echo $3 | sed "s/+/ /" | awk '{ print $1 }')
    # two=$(echo $3 | sed "s/+/ /" | awk '{ print $2 }')
    get_pass $1 $2 $3 $4 $5
else
    echo "Error: no valid service: $1"
fi
