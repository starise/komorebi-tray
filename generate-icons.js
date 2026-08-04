const fs = require("fs");
const path = require("path");
const icongen = require("icon-gen");

const themes = ["dark", "light"];
const pngDirectory = path.join("images", "png");
const icoDirectory = path.join("images", "ico");

async function generateIcon(pngFile, themeIcoDirectory, pngName, sizes) {
  const outputs = await icongen(pngFile, themeIcoDirectory, {
    report: false,
    ico: {
      name: pngName,
      sizes,
    },
  });
  const source = path.relative(process.cwd(), pngFile);
  const generated = outputs
    .map((output) => path.relative(process.cwd(), output))
    .join(", ");
  console.log(`  ${source} -> ${generated}`);
  return outputs;
}

async function generateIcons() {
  let generatedCount = 0;
  console.log("Generating icons...");

  fs.mkdirSync(icoDirectory, { recursive: true });
  generatedCount += (await generateIcon(
    path.join(pngDirectory, "app.png"),
    icoDirectory,
    "app",
    [16, 24, 32, 48, 256],
  )).length;

  for (const theme of themes) {
    const themePngDirectory = path.join(pngDirectory, theme);
    const themeIcoDirectory = path.join(icoDirectory, theme);
    fs.mkdirSync(themeIcoDirectory, { recursive: true });

    const pngFiles = fs.readdirSync(themePngDirectory).filter((file) => {
      const fullPath = path.join(themePngDirectory, file);
      return fs.statSync(fullPath).isFile() &&
        path.extname(file).toLowerCase() === ".png";
    }).sort();

    for (const file of pngFiles) {
      const pngFile = path.join(themePngDirectory, file);
      const pngName = path.basename(file, ".png");
      const sizes = pngName.startsWith("app-")
        ? [16, 24, 32, 48, 256]
        : [16, 24, 32, 48];
      generatedCount += (await generateIcon(
        pngFile,
        themeIcoDirectory,
        pngName,
        sizes,
      )).length;
    }
  }

  console.log(`Done: ${generatedCount} icons generated.`);
}

generateIcons().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
