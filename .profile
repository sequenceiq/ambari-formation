generate-json() {
  local INPUT=${1:?"required parameter: <cf-yaml-file>"}
  local OUTPUT=${INPUT%.yml}.json

  if [ ! -f $INPUT ] ;then
      echo [ERROR] no such file: $INPUT
      return
  fi

  if [ -f $OUTPUT ] ;then
      echo [ERROR] output alredy exists: $OUTPUT
      return
  fi


  cat <<EOF
  convert yaml to json
      YAML: $INPUT
      JSON: $OUTPUT
EOF

  ruby -r json -r yaml -e "yaml = YAML.load(File.read('"$INPUT"')); print yaml.to_json" |jq .> $OUTPUT
}


json-diff() {
  cat $1| jq . > d1
  cat $2| jq . > d2
  diff d1 d2
}
