#!/bin/bash

DIR=$(cd `dirname $0` && pwd)

url="$1"
apiurl="${url}/api"

source $DIR/include.sh $url

create_proj(){
    projname=$1
    cat > $DIR/proj_create.post <<END
<project>
    <name>$projname</name>
    <description>test1</description>
    <config>
        <property key="test.property" value="test value"/>
    </config>
</project>
END

    runurl="${APIURL}/projects"

    # post
    docurl -X POST -D $DIR/headers.out --data-binary @$DIR/proj_create.post \
        -H Content-Type:application/xml ${runurl}?${params} > $DIR/curl.out
    if [ 0 != $? ] ; then
        errorMsg "ERROR: failed POST request"
        exit 2
    fi
    rm $DIR/proj_create.post
    assert_http_status 201 $DIR/headers.out
}


echo "url: $url"
echo "apiurl: $apiurl"

loginurl="${url}/j_security_check"

# curl opts to use a cookie jar, and follow redirects, showing only errors
CURLOPTS="-s -S -L -c $DIR/cookies -b $DIR/cookies"
CURL="curl $CURLOPTS"

# get main page for login
RDUSER=${2:-"admin"}
RDPASS=${3:-"admin"}

echo "Login..."
$CURL $url > $DIR/curl.out
if [ 0 != $? ] ; then
  errorMsg "failed login request to ${loginurl}"
  exit 2
fi
$CURL -X POST -d j_username=$RDUSER -d j_password=$RDPASS $loginurl > $DIR/curl.out
if [ 0 != $? ] ; then
  errorMsg "failed login request to ${loginurl}"
  exit 2
fi

##  grep 'j_security_check' -q $DIR/curl.out 
##  if [ 0 == $? ] ; then
##    errorMsg "login was not successful: ${loginurl}"
##    exit 2
##  fi

create_proj "daplay"

