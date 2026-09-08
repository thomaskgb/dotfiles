## Cloudflare API access (read-only by design)
#
# The token in the keychain is deliberately READ-ONLY. Reading is the frequent,
# low-risk half of the job: checking SSL mode, DNS records, redirect behaviour,
# what changed. Writes to this zone are rare and high-blast-radius (the MX and
# SPF records carry Google Workspace mail, and there is no staging), so they go
# through the dashboard where the confirmation steps act as a guardrail.
#
# If you ever genuinely need a write token, create a short-lived one with an
# expiry date and a client IP filter rather than making this one permanent.
#
# The token lives in the login keychain under the service
# "cloudflare:api-token", the same way gh stores its GitHub token. Nothing in
# this file writes the secret to disk, and the token only enters the
# environment of the single process that needs it.
#
# To (re)store the token:
#   security add-generic-password -U -s cloudflare:api-token -a "$USER" \
#     -T /usr/bin/security -w
# The -w with no value prompts for the token instead of putting it in history.
# The -T pre-authorizes the security binary so reads do not prompt each time.
#
# Read it back:
cf-token() {
  security find-generic-password -s cloudflare:api-token -a "$USER" -w 2>/dev/null
}

# flarectl wrapper: injects the token per invocation instead of exporting it
# globally. Good for readable table output, e.g.
#   flarectl zone list
#   flarectl dns list --zone tdlx.nl
flarectl() {
  local token
  token="$(cf-token)" || { print -u2 "flarectl: no Cloudflare token in keychain"; return 1; }
  CF_API_TOKEN="$token" command flarectl "$@"
}

# Raw v4 REST API, for everything flarectl does not surface (zone settings,
# rules, WAF, analytics). Prints JSON; pipe through jq.
#
#   cf /zones | jq -r '.result[].name'
#   cf /zones/$zid/settings/ssl
#   cf /zones/$zid/settings | jq -r '.result[] | "\(.id)=\(.value)"'
#   cf /zones/$zid/dns_records | jq -r '.result[] | "\(.type)\t\(.name)\t\(.content)"'
#
# A mutating method is accepted here so the helper still works if you swap in a
# short-lived write token, but with the normal read-only token Cloudflare will
# reject it with a 403. That is the intended behaviour, not a bug.
cf() {
  emulate -L zsh
  # NB: do not name a local "path" here. In zsh `path` is the array form of
  # PATH, so assigning to it wipes PATH inside the function.
  local method=GET endpoint body token
  if [[ "$1" == (GET|POST|PUT|PATCH|DELETE) ]]; then
    method="$1"; shift
  fi
  endpoint="$1"; body="$2"
  if [[ -z "$endpoint" ]]; then
    print -u2 "usage: cf [METHOD] /path [json-body]"
    return 2
  fi
  token="$(cf-token)" || { print -u2 "cf: no Cloudflare token in keychain"; return 1; }

  # Build the body flag as an array. zsh does not word-split an unquoted
  # ${body:+--data "$body"}, so that form reaches curl as one argument.
  local -a data_args
  [[ -n "$body" ]] && data_args=(--data "$body")

  curl -sS -X "$method" \
    "https://api.cloudflare.com/client/v4${endpoint}" \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/json" \
    "${data_args[@]}"
}

# Resolve a zone name to its zone ID: zid=$(cf-zone tdlx.nl)
cf-zone() {
  [[ -n "$1" ]] || { print -u2 "usage: cf-zone <zone-name>"; return 2; }
  cf "/zones?name=$1" | jq -r '.result[0].id // empty'
}
