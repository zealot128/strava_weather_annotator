module.exports = {
  "extends": [
    "airbnb-base",
    "prettier",
  ],
  "globals": {
    OneDrive: true,
    Dropbox: true,
    gapi: true,
    addEventListener: true,
    history: true
  },
  "env": {
    "browser": true
  },
  // check if imports actually resolve
  'rules': {
    // don't require .vue extension when importing
    'import/extensions': ['error', 'always', {
      'js': 'never',
      'vue': 'never'
    }],
    'import/no-unresolved': 'off',
    'import/no-extraneous-dependencies': 'off',
    'import/extensions': 'off',
    "import/no-named-as-default": 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0,
    'no-console': process.env.NODE_ENV === 'production' ? 2 : 0,
    'import/first': 0,
    'comma-dangle': 0,
    "semi": 0,
    "arrow-body-style": ["error", "as-needed", { "requireReturnForObjectLiteral": true }],
    "no-param-reassign": 0,
    "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "no-new": 0,
    "max-len": ["warn", 200],
    "no-else-return": 0,
    "func-names": ["warn", "as-needed"],
    "quotes": 0
  }
};
