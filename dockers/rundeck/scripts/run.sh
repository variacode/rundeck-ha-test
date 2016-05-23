#!/bin/bash

# Configure general stuff.
./rdpro-installer configure-server-hostname --server-hostname $RUNDECK_NODE --rdeck-base $HOME
./rdpro-installer configure-server-name --rdeck-base $HOME --server-name $RUNDECK_NODE
./rdpro-installer configure-server-url --server-url $RUNDECK_URL --rdeck-base $HOME


# Configure passive mode if applies.
if [[ X$RUNDECK_ROLE == 'Xpassive' ]] ;
then
    echo "This is the passive instance. Configuring passive Node";
    ./rdpro-installer configure-execution-mode --rdeck-base $HOME --execution-mode passive;
    # Here all instructions to run in the passive
else
    echo "This is the active Instance";
    # Here all instructions to run in the active.
fi


# party: on
./rdpro-installer start --rdeck-base $HOME && tail -F $HOME/server/logs/catalina.out

