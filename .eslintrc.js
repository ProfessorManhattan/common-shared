/**
 * TODO: All plugins/extends should be loaded based on whether or not
 * they are in the `devDependencies` in `package.json`
 */

module.exports = {
  env: {
    es6: true,
    node: true
  },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: "tsconfig.json",
    sourceType: "module"
  },
  extends: [
    "eslint:all",
    "plugin:import/typescript",
    "plugin:unicorn/recommended",
    "plugin:yml/standard",
    "plugin:yml/prettier",
    "plugin:jsdoc/recommended",
    //"plugin:@typescript-eslint/all",
    "plugin:prettier/recommended"
  ],
  plugins: [
    "@typescript-eslint",
    //"@typescript-eslint/tslint",
    "eslint-plugin-prefer-arrow",
    "eslint-plugin-import",
    "eslint-plugin-jsdoc",
    "eslint-plugin-tsdoc",
    "eslint-plugin-unicorn",
    "jsdoc"
  ],
  overrides: [
    {
      files: ["*.js", "*.jsx"],
      rules: {
        "@typescript-eslint/no-shadow": ["error"],
        "@typescript-eslint/semi": "off",
        "no-shadow": ["error"],
        "semi": ["error"]
      }
    },
    {
      files: ["*.yaml", "*.yml"],
      parser: "yaml-eslint-parser"
    },
    {
      files: ["Taskfile*.yml"],
      parser: "yaml-eslint-parser",
      rules: {
        "yml/sort-keys": [
          "error",
          {
            pathPattern: "^$",
            order: [
              "version",
              "includes",
              "output",
              "silent",
              "method",
              "vars",
              "env",
              "dotenv",
              "tasks"
            ]
          },
          {
            pathPattern: "(?:deps|includes|log|env|vars)$",
            order: { type: "asc" }
          },
          {
            pathPattern: "^tasks$",
            order: { type: "asc" }
          },
          {
            pathPattern: ".*",
            order: [
              "cmd",
              "task",
              "deps",
              "label",
              "desc",
              "summary",
              "silent",
              "dir",
              "vars",
              "env",
              "run",
              "cmds",
              "ignore_error",
              "prefix",
              "log",
              "status",
              "method",
              "sources",
              "generates",
              "preconditions",
              "sh",
              "msg"
            ]
          }
        ],
        "max-len": ["error", { "code": 160 }],
        "unicorn/filename-case": "off"
      }
    }
  ],
  rules: {
    "@typescript-eslint/array-type": [
      "error",
      {
        default: "array"
      }
    ],
    "@typescript-eslint/class-literal-property-style": ["error", "fields"],
    "@typescript-eslint/explicit-member-accessibility": [
      "error",
      {
        accessibility: "explicit"
      }
    ],
    "@typescript-eslint/member-delimiter-style": [
      "error",
      {
        multiline: {
          delimiter: "semi",
          requireLast: true
        },
        singleline: {
          delimiter: "semi",
          requireLast: false
        }
      }
    ],
    "@typescript-eslint/no-extraneous-class": "off",
    "@typescript-eslint/no-inferrable-types": "off",
    "@typescript-eslint/no-shadow": ["error"],
    "@typescript-eslint/quotes": [
      "error",
      "single",
      {
        avoidEscape: true
      }
    ],
    "@typescript-eslint/semi": ["error", "always"],
    "@typescript-eslint/strict-boolean-expressions": "off",
    "@typescript-eslint/triple-slash-reference": [
      "error",
      {
        path: "always",
        types: "prefer-import",
        lib: "always"
      }
    ],
    "arrow-parens": ["off", "always"],
    "brace-style": ["error", "1tbs"],
    "capitalized-comments": "off",
    "comma-dangle": "off",
    eqeqeq: ["error", "always"],
    "id-blacklist": [
      "error",
      "any",
      "Number",
      "number",
      "String",
      "string",
      "Boolean",
      "boolean",
      "Undefined",
      "undefined"
    ],
    "import/no-extraneous-dependencies": [
      "error",
      {
        devDependencies: false
      }
    ],
    "jsdoc/check-indentation": ["error"],
    "jsdoc/check-line-alignment": ["error"],
    "jsdoc/no-bad-blocks": ["error"],
    "linebreak-style": ["error", "unix"],
    "max-classes-per-file": ["error", 5],
    "max-len": [
      "error",
      {
        code: 120
      }
    ],
    "max-lines": ["error", 500],
    "newline-per-chained-call": "off",
    "no-console": [
      "error",
      {
        allow: [
          "warn",
          "dir",
          "time",
          "timeEnd",
          "timeLog",
          "trace",
          "assert",
          "clear",
          "count",
          "countReset",
          "group",
          "groupEnd",
          "table",
          "debug",
          "info",
          "dirxml",
          "groupCollapsed",
          "Console",
          "profile",
          "profileEnd",
          "timeStamp",
          "context"
        ]
      }
    ],
    "no-magic-numbers": [
      "error",
      {
        ignoreArrayIndexes: true
      }
    ],
    "no-multiple-empty-lines": [
      "error",
      {
        max: 2
      }
    ],
    "no-plusplus": [
      "error",
      {
        allowForLoopAfterthoughts: true
      }
    ],
    "no-restricted-syntax": ["error", "ForInStatement"],
    "no-shadow": "off",
    "one-var": ["error", "never"],
    "padding-line-between-statements": [
      "error",
      {
        blankLine: "always",
        prev: "*",
        next: "return"
      }
    ],
    "prefer-arrow/prefer-arrow-functions": [
      "warn",
      {
        disallowPrototype: true,
        singleReturnOnly: false,
        classPropertiesAllowed: false
      }
    ],
    "quote-props": ["error", "as-needed"],
    "semi": "off",
    "space-before-function-paren": "off",
    "space-in-parens": ["off", "never"],
    "spaced-comment": [
      "error",
      "always",
      {
        markers: ["/"]
      }
    ],
    "tsdoc/syntax": "error",
    /*"@typescript-eslint/tslint/config": [ // TODO: Make it so this works for both projects that do and do not have a tsconfig.json file
      // TODO: Ensure these rules are working and eliminate rules that are duplicates of other rules
      "error",
      {
        rules: {
          "comment-type": [true, "doc", "singleline", "multiline"],
          "completed-docs": [
            true,
            "enums",
            "functions",
            "methods",
            "classes",
            "namespaces"
          ],
          encoding: true,
          "import-spacing": true,
          "invalid-void": true,
          "no-delete": true,
          "no-inferred-empty-object-type": true,
          "no-let": true,
          "no-mergeable-namespace": true,
          "no-method-signature": true,
          "no-mixed-interface": true,
          "no-object-mutation": true,
          "no-promise-as-boolean": true,
          "no-tautology-expression": true,
          "no-unnecessary-callback-wrapper": true,
          "number-literal-format": true,
          "object-literal-sort-keys": [
            true,
            "ignore-case",
            "locale-compare",
            "match-declaration-order",
            "shorthand-first"
          ],
          "prefer-conditional-expression": true,
          "prefer-method-signature": true,
          "prefer-switch": [
            true,
            {
              "min-cases": 4
            }
          ],
          "readonly-array": true,
          "readonly-keyword": true,
          "return-undefined": true,
          "static-this": true,
          "strict-comparisons": true,
          "strict-string-expressions": true,
          "strict-type-predicates": true,
          typedef: [true, "call-signature"],
          "unnecessary-else": true
        }
      }
    ]*/
  }
};
