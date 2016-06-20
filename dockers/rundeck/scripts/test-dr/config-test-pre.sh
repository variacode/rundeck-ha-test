#!/bin/bash
#### DR TEST CONFIGURATION.
echo "DR test pre config"


# Configure passive mode if applies.
if [[ X$RUNDECK_ROLE == 'Xpassive' ]] ;
then
    # Here all instructions to run in the passive pre-start
    echo "This is the passive instance. Configuring passive Node";
    ./rdpro-installer configure-execution-mode --rdeck-base $HOME --execution-mode passive;

else
    # Here all instructions to run in the active pre-start
    echo "This is the active Instance";

fi
