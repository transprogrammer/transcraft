# REQ: Parses make script options. <skr 2022-07>

function parse_options {
  local opts='b:,e:,k:,l:,g:,m:,s:,u:'
  local longopts
    longopts='bastion:'
  longopts+=',environment:'
  longopts+=',keyfile:'
  longopts+=',location:'
  longopts+=',resource-group:'
  longopts+=',virtual-machine:'
  longopts+=',subscription-id:'
  longopts+=',mimefile:'

  local parsed
  declare -Ag options

  parsed=$(getopt --options="$opts" --longoptions="$longopts" --name "$0" -- "$@")
  eval set -- "$parsed"

  for ((i = 1; i <= $#; i++)); do
    (( j = i + 1 ))
    case "${!i}" in
        -b|--bastion)
          options[bastion]="${!j}"
          (( i++ ))
          ;;
        -e|--environment)
          options[environment]="${!j}"
          (( i++ ))
          ;;
        -g|--resource-group)
          options[resource_group]="${!j}"
          (( i++ ))
          ;;
        -k|--keyfile)
          options[keyfile]="${!j}"
          (( i++ ))
          ;;
        -l|--location)
          options[location]="${!j}"
          (( i++ ))
          ;;
        -m|--virtual-machine)
          options[virtual_machine]="${!j}"
          (( i++ ))
          ;;
        -s|--subcription-id)
          options[subscription_id]="${!j}"
          (( i++ ))
          ;;
        -u|--mimefile)
          options[mime_file]="${!j}"
          (( i++ ))
          ;;
        --)
          if [[ $i -lt $# ]]; then
            (( k = i - $# - 1))
            echo "Invalid arguments: ${@:k}"
            exit 1
          fi
          break
          ;;
        *)
          echo "Invalid option: ${!i}"
          exit 3
          ;;
    esac
  done
}
