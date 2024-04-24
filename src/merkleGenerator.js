const fs = require("fs");
const pdfParse = require("pdf-parse");

// Function to read the PDF and parse its content
async function parsePDF(filePath) {
  const dataBuffer = fs.readFileSync(filePath);

  try {
    const data = await pdfParse(dataBuffer);
    extractData(data.text);
  } catch (error) {
    console.error("Error parsing PDF:", error);
  }
}

function extractData(text) {
  const lines = text.split("\n");
  const usersData = [];

  for (let line of lines) {
    const parts = line.trim().split(/\s+/); // Adjust this based on the actual format seen in the console.log output
    if (parts.length >= 3 && parts[0].startsWith("0x")) {
      console.log("Parsing line:", line); // Debugging: print each line being parsed
      usersData.push({
        address: parts[0],
        whitelistQty: parseInt(parts[1]),
        freeMintQty: parseInt(parts[2]),
      });
    }
  }

  console.log(usersData);
}

// Path to your PDF file
const pdfPath = "./src/Reserved1.pdf";

// Start the parsing process
parsePDF(pdfPath);
