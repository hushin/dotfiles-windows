#!/bin/bash

git init
# https://github.com/simonwhitaker/gibo
gibo dump Node >> .gitignore
echo '/lib' >> .gitignore
# https://github.com/blaix/license-generator
licgen MIT hushin
touch README.md
# create dir
mkdir test
mkdir lib
mkdir src
# create package.json
# https://github.com/azu/init-package-json-parcel
yes '' | init-package-json

# create README
CURRENT_DIR=$(echo ${PWD##*/})
cat <<EOF > README.md
# $CURRENT_DIR

(Overview)

## Description

***DEMO:***

## Features

- aaa

## Installation

\`\`\`

\`\`\`

## Usage

\`\`\`

\`\`\`

## Anything Else

## Running tests

\`\`\`
npm install
npm run test:all
\`\`\`

## Develop

\`\`\`
npm run test:watch
npm run lint:fix
npm run watch
\`\`\`
EOF

# update package.json
node -e '
var package = require("./package.json")
var fs = require("fs")
package.version = "0.1.0"
package.main = "lib/index.js"
package.scripts = {
  "build:base": "babel src --out-dir lib --ignore test.js --source-maps inline",
  "build": "NODE_ENV=production npm run build:base",
  "watch": "npm run build:base -- --watch",
  "lint": "eslint .",
  "lint:fix": "npm run lint -- --fix",
  "test": "mocha src/**/*.test.js",
  "test:watch": "npm test -- --watch",
  "test:all": "npm run lint && npm run test",
  "preversion": "npm run test:all",
  "version": "npm run build",
  "postversion": "git push && git push --tags",
  "prepush": "npm run test:all"
}
fs.writeFile("./package.json", JSON.stringify(package, null, 2) + "\n",
  function(err) {
    if (err) { console.log(err) }
  })
'

# setting
echo "--require babel-register test/**/*.js" > test/mocha.opts
echo '{
  "presets": [
    "env"
  ],
  "env": {
    "development": {
      "presets": [
        "power-assert"
      ]
    }
  }
}' > .babelrc
echo '{
  "extends": "standard",
  "globals": {
    "describe": false,
    "context": false,
    "it": false,
    "after": false,
    "before": false,
    "beforeEach": false,
    "afterEach": false
  }
}' > .eslintrc.json

echo 'lib/**' > .eslintignore

# sample file
echo "import * as calc from './calc'
export {
  calc
}" > src/index.js

echo "export const add = (x, y) => x + y" > src/calc.js

echo "import * as root from '.'
import assert from 'assert'

describe('root', () => {
  it('should exist.', () => {
    assert.ok(root)
  })
})" > src/index.test.js

echo "import * as calc from './calc'
import assert from 'assert'

describe('calc', () => {
  it('add', () => {
    assert(calc.add(1, 2) === 3)
  })
})" > src/calc.test.js

# install package
npm install -D \
babel-cli \
babel-preset-env \
babel-preset-power-assert \
babel-register \
eslint \
eslint-config-standard \
eslint-plugin-standard \
eslint-plugin-promise \
eslint-plugin-import \
eslint-plugin-node \
husky \
mocha \
power-assert

# git
git add .
