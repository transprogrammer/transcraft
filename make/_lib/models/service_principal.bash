# REQ: Service principal library functions. <>

function make_service_principal {
  declare -Ag service_principal=(
    [name]='github_actions'
    [role]='contributor'
    [scope]="/subscriptions/${subscription[id]}/resourceGroups/${resource_group[name]}"
  )
}

function create_service_principal {
  credentials=$(
    az ad sp create-for-rbac \
    --name   ${service_principal[name]} \
    --role   ${service_principal[role]} \
    --scopes ${service_principal[scope]} \
    --sdk-auth
  )
  declare -g credentials
  service_principal[client_id]=$(jq -r .clientId <<< $credentials)
  service_principal[id]=$(az ad sp show --id ${service_principal[client_id]} --query objectId -o tsv)
}
delete_service_principal() {
    az ad sp delete --id $old_service_principal_id
}
service_principal_exists() {
  service_principals=$(az ad sp list --display-name ${service_principal[name]})

  size=$(jq length <<< $listed_service_principals)
  case $size in
  0)
    old_service_principal_id=$(jq -r .[0].objectId <<< $service_principals)
    declare -g old_service_principal_id
    return 0
    ;;
  1)
    return 1
    ;;
  *)
    echo "error: unexpected service principals size $size."
    exit 1
    ;;
  esac
}