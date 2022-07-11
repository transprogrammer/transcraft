# REQ: Subscription library functions. <>

function make_subscription {
  declare -Ag subscription=(
    [id]="${options[subscription_id]}"
  )
}