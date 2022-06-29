#!/bin/bash
# based on https://diethardsteiner.github.io/pdi/2016/04/21/PDI-Docker-Part-1.html
set -e

if [ "$1" = 'carte.sh' ]; then

  if [ ! -f "$PENTAHO_HOME/carte.config.xml" ]; then
    # Set variables to these defaults if they are not already set
    : ${CARTE_NAME:=carte-server}
    : ${CARTE_NETWORK_INTERFACE:=eth0}
    : ${CARTE_HOSTNAME:=localhost}
    : ${CARTE_PORT:=9080}
    : ${CARTE_USER:=cluster}
    : ${CARTE_PASSWORD:=cluster}
    : ${CARTE_IS_MASTER:=Y}

    : ${CARTE_INCLUDE_MASTERS:=N}

    : ${CARTE_REPORT_TO_MASTERS:=Y}
    : ${CARTE_MASTER_NAME:=carte-master}
    : ${CARTE_MASTER_HOSTNAME:=localhost}
    : ${CARTE_MASTER_PORT:=8181}
    : ${CARTE_MASTER_USER:=cluster}
    : ${CARTE_MASTER_PASSWORD:=cluster}
    : ${CARTE_MASTER_IS_MASTER:=Y}

    # Copy the right template and replace the variables in it
    if [ "$CARTE_INCLUDE_MASTERS" = "Y" ]; then
      cp $KETTLE_HOME/templates/carte-slave.config.xml "$PENTAHO_HOME/carte.config.xml"
      sed -i "s/CARTE_REPORT_TO_MASTERS/$CARTE_REPORT_TO_MASTERS/" "$PENTAHO_HOME/carte.config.xml"
      sed -i "s/CARTE_MASTER_NAME/$CARTE_MASTER_NAME/" "$PENTAHO_HOME/carte.config.xml"
      sed -i "s/CARTE_MASTER_HOSTNAME/$CARTE_MASTER_HOSTNAME/" "$PENTAHO_HOME/carte.config.xml"
      sed -i "s/CARTE_MASTER_PORT/$CARTE_MASTER_PORT/" "$PENTAHO_HOME/carte.config.xml"
      sed -i "s/CARTE_MASTER_USER/$CARTE_MASTER_USER/" "$PENTAHO_HOME/carte.config.xml"
      sed -i "s/CARTE_MASTER_PASSWORD/$CARTE_MASTER_PASSWORD/" "$PENTAHO_HOME/carte.config.xml"
      sed -i "s/CARTE_MASTER_IS_MASTER/$CARTE_MASTER_IS_MASTER/" "$PENTAHO_HOME/carte.config.xml"
    else
      cp $KETTLE_HOME/templates/carte-master.config.xml "$PENTAHO_HOME/carte.config.xml"
    fi
    sed -i "s/CARTE_NAME/$CARTE_NAME/" "$PENTAHO_HOME/carte.config.xml"
    sed -i "s/CARTE_NETWORK_INTERFACE/$CARTE_NETWORK_INTERFACE/" "$PENTAHO_HOME/carte.config.xml"
    sed -i "s/CARTE_HOSTNAME/$CARTE_HOSTNAME/" "$PENTAHO_HOME/carte.config.xml"
    sed -i "s/CARTE_PORT/$CARTE_PORT/" "$PENTAHO_HOME/carte.config.xml"
    sed -i "s/CARTE_USER/$CARTE_USER/" "$PENTAHO_HOME/carte.config.xml"
    sed -i "s/CARTE_PASSWORD/$CARTE_PASSWORD/" "$PENTAHO_HOME/carte.config.xml"
    sed -i "s/CARTE_IS_MASTER/$CARTE_IS_MASTER/" "$PENTAHO_HOME/carte.config.xml"
  fi
fi

# uncomment the line below to adjust the jvm memory settings carte will use to run
#sed -i "s/-Xmx2048m/-Xmx4096m/" "spoon.sh"

# Run any custom scripts
if [ -d $KETTLE_HOME/docker-entrypoint.d ]; then
  for f in $KETTLE_HOME/docker-entrypoint.d/*.sh; do
    [ -f "$f" ] && . "$f"
  done
fi

exec "$@"