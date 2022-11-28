/** @type {import('tailwindcss').Config} */

module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],

  plugins: [require("daisyui")],
  daisyui: {
    themes: ["light", "dark"],
  },
  theme: {
    extend: {
      animation: {
        blob: "blob 30s infinite",
      },
      keyframes: {
        blob: {
          "0%": {
            transform: "translate(0px, 0px) scale(1)",
          },
          "33%": {
            transform: "translate(100px, -150px) scale(1.3)",
          },
          "66%": {
            transform: "translate(-70px, 70px) scale(0.9)",
          },
          "100%": {
            transform: "tranlate(0px, 0px) scale(0.4)",
          },
        },
      },
    },
  },
};
