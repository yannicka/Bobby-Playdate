version := `sed -n -e 's/^version=//p' src/pdxinfo`

run:
    pdc src Bobby.pdx && PlaydateSimulator Bobby.pdx

build:
    rm -rf Bobby.pdx Bobby-{{version}}.pdx
    pdc --strip --skip-unknown src Bobby.pdx
    rm -r Bobby.pdx/scenes
    zip Bobby-{{version}}.pdx.zip -r Bobby.pdx
