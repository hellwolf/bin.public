none="\033[0m";
red="\033[0;31m";
green="\033[0;32m";
SUCCESS="${green}SUCCESS${none}"
FAIL="${red}FAIL${none}"

function nslookup_()
{
    nslookup "$@" | awk '{ if (found == 1 && $0 != "") print $0;$0 == "Non-authoritative answer:" && found = 1; found == 1 && $0 == "" && found = 0 }'
}

function DOMAIN_CHECK_A_RECORD()
{
    local EXPECTED="Address: $2"
    if nslookup_ $1 | grep -iq "$EXPECTED"; then
        echo -e "A $1 -> $2 : $SUCCESS"
    else
        echo -e "A $1 -> $2 : $FAIL"
    fi
}

function DOMAIN_CHECK_CNAME_RECORD()
{
    local EXPECTED="$(echo -e "$1\tcanonical name = $2")"
    if nslookup_ -query=cname $1 | grep -iq "$EXPECTED"; then
        echo -e "CNAME $1 -> $2 : $SUCCESS"
    else
        echo -e "CNAME $1 -> $2 : $FAIL"
    fi
}

function DOMAIN_CHECK_MX_RECORD()
{
    local EXPECTED="$(echo -e "$1\tmail exchanger = $2")"
    if nslookup_ -query=mx $1 | grep -iq "$EXPECTED"; then
        echo -e "MX $1 -> $2 : $SUCCESS"
    else
        echo -e "MX $1 -> $2 : $FAIL"
    fi
}

function SITE_CHECK_HTTP200()
{
    local SITE=$1
    echo -n "SITE_CHECK_HTTP200 $SITE: "
    { egrep "^HTTP/1.1 200" <(curl -L $SITE -D >(cat) -o /dev/null &>/dev/null) &>/dev/null && echo -e "$SUCCESS"; } || echo -e "$FAIL"
}

function SITE_CHECK_HTTP301()
{
    local FROM=$1
    local TO=$2
    echo -n "SITE_CHECK_HTTP301 $FROM -> $TO: "
    { egrep "^Location: $TO" <(curl $FROM -D >(cat) -o /dev/null &>/dev/null) &>/dev/null && echo -e "$SUCCESS"; } || echo -e "$FAIL"
}
