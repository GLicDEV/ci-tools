#!/usr/bin/env sh
dfx start --clean --background

dfx identity use $DFX_DEV_IDENTITY
principal=$(dfx identity get-principal)
minter=$(dfx ledger account-id)

echo -e "Deploying NNS: \nMINTER: $minter\nPRINCIPAL: $principal\n"


csvstack $DFX_NEURONS_DIR/*.csv > ~/initial-neurons.csv

# Limit execution time for this script
# It could go into infinite retry loop on deployment error
timeout 180 \
ic-nns-init --url $IC_URI \
--wasm-dir $DFX_WASMS_DIR \
--initial-neurons ~/initial-neurons.csv \
--minter $minter \
--initialize-ledger-with-test-accounts-for-principals $principal

deploy_status=$?

dfx stop

sleep 2

if [ $deploy_status -ne 0 ]; then 
    echo "ERROR! NNS deploy failed!";
    exit 1; 
fi

echo "NNS initialization successful"

exit 0