#!/bin/bash
# AUTHOR: Phil Porada
# WHAT: Removes the named database, imports a new database, grants access

BLD=$(tput bold)
RST=$(tput sgr0)

# Set defaults
# The .my.cnf information can be gleaned from https://easyengine.io/tutorials/mysql/mycnf-preference/
DB_USER=$(grep 'user=' $HOME/.my.cnf | sed 's/user=//')
DB_PASS=$(grep 'password=' $HOME/.my.cnf | sed 's/password=//')
DB_NAME=root
DESTROY=0
CREATE=0
DATABASEPATH="/vagrant/dbdump/"

trap echo EXIT

function usage() {
    echo -e "$(basename $0) [-r \$DB_NAME | -d \$DB_NAME] [-u] [-p] [-h] [-s]
    
    FLAGS:
        ${BLD}-r \$DB_NAME${RST}  | Load database dump from $DATABASEPATH
        ${BLD}-d \$DB_NAME${RST}  | Destroy named database
        ${BLD}-u \$DB_USER${RST}  | Specify new database user
        ${BLD}-p \$DB_PASS${RST}  | Specify new database password
        ${BLD}-s         ${RST}  | Show existing databases
        ${BLD}-h${RST}           | Displays this help screen

    EXAMPLES:
        Show currently loaded mysql databases: ${BLD}$(basename $0) -s${RST}
        Destroy named database: ${BLD}$(basename $0) -d \$DB${RST}
        Load new database dump with a named user and specified password: ${BLD}$(basename $0) -r \$DB_NAME -u testuser -p mypass${RST}
        Load new database dump with user/pass from $HOME/.my.cnf: ${BLD}$(basename $0) -r \$DB_NAME${RST}

    NOTES:
        This will automatically choose the database located at $DATABASEPATH
    "
}

function destroydb() {
    mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME;"
}

function createdb() {
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';" 2>/dev/null
    mysql -u root -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';" 2>/dev/null
    mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
    mysql -u root -e "FLUSH PRIVILEGES;"
}

function loaddb() {
    DBDUMP="$(ls -tc "${DATABASEPATH}" | egrep -v '(testing|root)' | head -n1)"
    EXT="${DBDUMP##*.}"
    if [[ "$(echo "${EXT}" | tr '[:upper:]' '[:lower:]')" == "gz" ]]; then
        zcat "${DATABASEPATH}""${DBDUMP}" | mysql -u$DB_USER -p$DB_PASS $DB_NAME
    else
        cat "${DATABASEPATH}""${DBDUMP}" | mysql -u$DB_USER -p$DB_PASS $DB_NAME
    fi
}

while getopts ":hsu:p:r:d:" opt; do
  case $opt in
    u)  DB_USER="$OPTARG";;
    p)  DB_PASS="$OPTARG";;
    r)  DB_NAME="$OPTARG"
        mysql -uroot -e "SHOW DATABASES;" | sed -e 's/\+//g' -e '/Database/d' | grep -o "^$DB_NAME$" &>/dev/null
        if [ $? -eq 1 ]; then
            CREATE=1
        else
            echo "==> Database $DB_NAME already exists. You should delete it first"
        fi
        ;;
    d)  DB_NAME="$OPTARG"
        mysql -uroot -e "SHOW DATABASES;" | sed -e 's/\+//g' -e '/Database/d' | grep -o "^$DB_NAME$" &>/dev/null
        if [ $? -eq 0 ]; then
            DESTROY=1
        else
            echo "==> Database $DB_NAME does not exist for deletion"
        fi
        ;;
    h)  usage
        exit 0;;
    s) mysql -uroot -e "SHOW DATABASES;";;
    \?) 
        echo "Invalid option: -$OPTARG" >&2
        echo
        usage
        exit 1
        ;;
    :)  
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
  esac
done
shift $(($OPTIND - 1))

if [ $OPTIND -eq 1 ]; then 
    echo "ERROR: No options were passed";
    echo
    usage
    exit 1
fi

if [ $DESTROY -eq 1 ]; then
    destroydb
    echo "Destroyed"
    echo "==> Database: $DB_NAME"
fi

if [ $CREATE -eq 1 ]; then
    echo "Creating"
    echo "==> Database: $DB_NAME"
    createdb
    echo "Loading database dump"
    loaddb
    echo "Created"
    echo "==> Database: $DB_NAME"
    echo "==> User: $DB_USER"
    echo "==> Pass: $DB_PASS with ALL grants"
    echo
    echo "You're done here\!"
fi
