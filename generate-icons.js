const fs = require("fs");
const path = require("path");
const icongen = require("icon-gen");

const pngDirectory = "images/png";
const icoDirectory = "images/ico";

const options = {
  report: true,
  ico: {
    name: "app",
    sizes: [16, 24, 32, 48, 256],
  },
};

fs.mkdirSync(icoDirectory, { recursive: true });

icongen(pngDirectory + "/app.png", icoDirectory, options)
  .then((results) => {
    console.log(results);
  })
  .catch((err) => {
    console.error(err);
  });

const pngFiles = fs.readdirSync(pngDirectory).filter((file) => {
  const fullPath = path.join(pngDirectory, file);
  return fs.statSync(fullPath).isFile() &&
    path.extname(file).toLowerCase() === ".png";
});

pngFiles.filter((e) => e !== "app.png").forEach((file) => {
  const pngFile = path.join(pngDirectory, file);
  const pngName = path.basename(file, ".png");
  const options = {
    report: true,
    ico: {
      name: pngName,
      sizes: [16, 24, 32, 48],
    },
  };
  icongen(pngFile, icoDirectory, options)
    .then((results) => {
      console.log(results);
    })
    .catch((err) => {
      console.error(err);
    });
});
