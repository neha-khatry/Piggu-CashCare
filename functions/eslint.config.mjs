// eslint.config.mjs
import eslint from "@eslint/js";

export default [
  // Use ESLint's recommended configuration
  eslint.configs.recommended,
  {
    // Set up JavaScript language options
    languageOptions: {
      ecmaVersion: 2021, // Modern ECMAScript features
      sourceType: "module", // Using ES modules (e.g., import/export)
      globals: {
        require: "readonly", // Define `require` as a global in your project
        exports: "readonly", // Define `exports` as a global in your project
        console: "readonly", // Define `console` as a global in your project
      },
    },
    // Define custom rules
    rules: {
      "quotes": ["error", "double"], // Enforce double quotes for strings
      "semi": ["error", "always"],   // Enforce semicolons at the end of statements
      "indent": ["error", 2],         // Enforce 2 spaces for indentation
    },
  },
];
