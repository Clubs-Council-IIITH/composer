#! /bin/bash

# add rover to PATH
export PATH=$HOME/.rover/bin:$PATH

# record healthcheck start time
STARTTIME=$EPOCHSECONDS

# read hit interval and termination timeout from config
INTERVAL=$(yq e '.interval' config.yml)
TIMEOUT=$(yq e '.timeout' config.yml)

# read services array from config
read -r -a services <<< $(yq e '.services[].url' config.yml | xargs)

# healthcheck services until script times out or everything is up
echo "Waiting for healthcheck to complete..."
healthy=()
until [ $((EPOCHSECONDS-STARTTIME)) -gt $TIMEOUT ] || [ "${#healthy[@]}" -eq "${#services[@]}" ]; do
    for i in "${!services[@]}"; do
        # check if service has already been marked as healthy
        if [[ ! " ${healthy[*]} " =~ " ${i} " ]]; then
            # hit the service url to see if it's up
            curl -sSf ${services[$i]} -o /dev/null

            # if up, add to healthy array
            [[ $? -eq 0 ]] && healthy+=($i)
        fi
    done
    
    # wait before next attempt
    sleep $INTERVAL
done

# construct supergraph.yml
echo "Construction supergraph config..."
yq -n e '.federation_version = 2' > /data/supergraph.yml
for i in "${healthy[@]}"; do
    service_name=$(yq e ".services[$i].name" config.yml)
    service_url=$(yq e ".services[$i].url" config.yml)
    yq -i e '.subgraphs.'$service_name'.routing_url = "'$service_url'"' /data/supergraph.yml
    yq -i e '.subgraphs.'$service_name'.schema.subgraph_url = "'$service_url'"' /data/supergraph.yml

    # log healthy services
    echo "HEALTHY: $service_name"
done

# compose supergraph.graphql
echo "Composing supergraph schema..."
rover supergraph compose --config /data/supergraph.yml > /data/supergraph.graphql

# exit
echo "Done."
