# Account Scraper

is a Script to get informations (like Acount Balance or Monthly fees) from your online Account like Uberspace.
For now, only Uberspace is supported with monthly fees, account balance and extra storage. It's get the password to the account from [pass](https://www.passwordstore.org/), but 
you need a specific [syntax](#Pass syntax) in your pass. (or you have to adjust the script). 

The script can easily be used for example in [sc-im](https://github.com/andmarti1424/sc-im). With this you can have a nice table and overview about multiple accounts.

## Dependencies:

- cUrl
- sed
- cat
- pandoc (Text - html)
- awk
- grep
- echo
- **pass**

## Use it:

### Example:

```
account_scraper uberspace konto test/test/test 
```

### Command structure

uberspace
: the service / module to use

konto
: The information you want to get.  (For Uberspace: konto=account balance; mon=monthly fee; gb=extra storage)

test/test/test
: the postition for the username and password in *pass*

### Pass syntax

For the script to word you need this syntax in your pass:

```pass
$password

User: $username
```

Change `$username` and `$password` to your needs.

# Get it into sc-im

```sc-im
@ston(@ext("./account_scraper uberspace konto test/test/test",0))
```

## Configuration for sc-im

This is to allow external functions. You have to place it in the sc-im file or the global config.

```scimrc
set external_functions=1
```


