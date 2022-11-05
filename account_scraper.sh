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
    \$1_${n_username}:     uberspace (parser)
    \$2:     search (konto, mon gb)
    \$3:     The pass middle
    \$4:     A1 (pass)
    \$5:     B1 (pass)
    "
}

function url_encode() {
    echo "$@" \
    | sed \
        -e 's/%/%25/g' \
        -e 's/ /%20/g' \
        -e 's/!/%21/g' \
        -e 's/"/%22/g' \
        -e "s/'/%27/g" \
        -e 's/#/%23/g' \
        -e 's/(/%28/g' \
        -e 's/)/%29/g' \
        -e 's/+/%2b/g' \
        -e 's/,/%2c/g' \
        -e 's/-/%2d/g' \
        -e 's/:/%3a/g' \
        -e 's/;/%3b/g' \
        -e 's/?/%3f/g' \
        -e 's/@/%40/g' \
        -e 's/\$/%24/g' \
        -e 's/\&/%26/g' \
        -e 's/\*/%2a/g' \
        -e 's/\./%2e/g' \
        -e 's/\//%2f/g' \
        -e 's/\[/%5b/g' \
        -e 's/\\/%5c/g' \
        -e 's/\]/%5d/g' \
        -e 's/\^/%5e/g' \
        -e 's/_/%5f/g' \
        -e 's/`/%60/g' \
        -e 's/{/%7b/g' \
        -e 's/|/%7c/g' \
        -e 's/}/%7d/g' \
        -e 's/~/%7e/g'
}

parser_uberspace () {
    # $1:     uberspace (parser)
    # $2:     konto / mon 
    # $3:     Path to pass

    get_pass $3

    n_username=$(url_encode $username)
    n_password=$(url_encode $password)
    # echo $n_password
    # echo ${n_username}

    [ ! -f "/tmp/login_web_scraper_$1_${n_username}_$(date +%d-%m)" ] && curl -s -o /dev/null -c /tmp/login_web_scraper_$1_${n_username}_$(date +%d-%m) 'https://dashboard.uberspace.de/login' --data-raw "_csrf_token=634F9E33639560772251F5E3E91FBF43&login=${n_username}&password=${n_password}&submit=login" --compressed
    [ ! -f "/tmp/accounting_$1_${n_username}_$(date +%d-%m).html" ] && curl -s -o /tmp/accounting_$1_${n_username}_$(date +%d-%m).html --cookie /tmp/login_web_scraper_$1_${n_username}_$(date +%d-%m) https://dashboard.uberspace.de/dashboard/accounting
    [ ! -f "/tmp/html-text_$1_${n_username}_$(date +%d-%m).txt" ] && pandoc -o /tmp/html-text_$1_${n_username}_$(date +%d-%m).txt /tmp/accounting_$1_${n_username}_$(date +%d-%m).html




    if [ "$2" == "konto" ]; then
        uberspace_konto $1
    elif [ "$2" == "mon" ]; then
        uberspace_mon $1
    elif [ "$2" == "gb" ]; then
        uberspace_gb $1
    else 
        echo "Error: Invalid search: $3"
    fi

}

uberspace_gb ()
{
    # echo "gb"
    cat /tmp/html-text_$1_${n_username}_$(date +%d-%m).txt | grep "zusätzlicher Speicherplatz" | awk '{ print $3 }' | sed "s/ GB//"
}

uberspace_mon ()
{
    # echo "mon"
    cat /tmp/html-text_$1_${n_username}_$(date +%d-%m).txt | grep "Summe" | awk '{ print $2 }' | sed "s/ €//"
}
uberspace_konto () 
{
    # echo "kon"
    cat /tmp/html-text_$1_${n_username}_$(date +%d-%m).txt | grep "beträgt derzeit" | \
        awk '{ print $4 }' | sed "s/**//g" | sed "s/ €.//"
}

test_func ()
{
    echo $1
    echo $2
}

get_pass ()
{


    pass_out="pass $1"
    password="$($pass_out | head -1)"
    username="$($pass_out | grep "User" | awk '{ print $2 }' )"

    # echo "
    # pas: $password
    # usr: $username
    # "
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
    # one=$(echo $3 | sed "s/+/ /" | awk '{ print $1_${n_username} }')
    # two=$(echo $3 | sed "s/+/ /" | awk '{ print $2 }')
    # get_pass $1_${n_username} $2 $3 $4 $5
    parser_uberspace $@
else
    echo "Error: no valid service: $1"
fi
