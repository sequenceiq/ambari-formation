generate-json() {
  local INPUT=${1:?"required parameter: <cf-yaml-file>"}
  local OUTPUT=${INPUT%.yml}.json

  if [ ! -f $INPUT ] ;then
      echo [ERROR] no such file: $INPUT
      return
  fi

  cat <<EOF
  convert yaml to json
      YAML: $INPUT
      JSON: $OUTPUT
EOF

  ruby -r json -r yaml -e "yaml = YAML.load(File.read('"$INPUT"')); print yaml.to_json" |jq .> $OUTPUT
}
