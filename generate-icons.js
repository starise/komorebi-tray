const fs = require("fs");
const icongen = require("icon-gen");

const sourceDir = "images/png/app";
const destinationDir = "images/ico";

const options = {
  report: true,
  ico: {
    name: "app",
    sizes: [16, 24, 32, 48, 64, 128, 256],
  },
};

fs.mkdirSync(destinationDir, { recursive: true });

icongen(sourceDir, destinationDir, options)
  .then((results) => {
    console.log(results);
  })
  .catch((err) => {
    console.error(err);
  });
