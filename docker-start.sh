#!/bin/bash
# Adapt from https://github.com/openshift/origin-metrics/

if [ -z "${MAX_HEAP_SIZE}" ]; then
   export MAX_HEAP_SIZE=1024M
fi

echo "The MAX_HEAP_SIZE has been set to ${MAX_HEAP_SIZE}"


if [ -z "${HEAP_NEWSIZE}" ] && [ -z "${CPU_LIMIT}" ]; then
  echo "The HEAP_NEWSIZE and CPU_LIMIT envars are not set. Defaulting the HEAP_NEWSIZE to 100M"
  export HEAP_NEWSIZE=100M
elif [ -z "${HEAP_NEWSIZE}" ]; then
  export HEAP_NEWSIZE=$((CPU_LIMIT/10))M
  echo "THE HEAP_NEWSIZE envar is not set. Setting to ${HEAP_NEWSIZE} based on the CPU_LIMIT of ${CPU_LIMIT}. [100M per CPU core]"
else
  echo "The HEAP_NEWSIZE envar is set to ${HEAP_NEWSIZE}. Using this value"
fi

sed -i "s/^#MAX_HEAP_SIZE=.*/MAX_HEAP_SIZE=${MAX_HEAP_SIZE}/" /etc/cassandra/cassandra-env.sh
sed -i "s/^#HEAP_NEWSIZE=.*/HEAP_NEWSIZE=${HEAP_NEWSIZE}/" /etc/cassandra/cassandra-env.sh

# Call official docker-entrypoint.sh to make sure proper processing
# of other env vars
exec /docker-entrypoint.sh cassandra -f -R
