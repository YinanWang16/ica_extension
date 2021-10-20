# list volumes
ica volumes list --max-items 0
#x`
wfr_list=(`ica volumes list --max-items 0 -o json | jq -r '.items[]|select(.name|test("wfr*"))|.name'`)

for wfr in ${wfr_list[@]}; do
  status=`ica workflows runs get $wfr -o json|jq -r '.status'`
  if [ "$status" = "Failed" ]; then
    echo 'y' | ica volumes delete gds://$wfr
  fi
done
# list volumes again
ica volumes list --max-items 0