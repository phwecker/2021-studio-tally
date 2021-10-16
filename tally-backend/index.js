// const Lights = require('./Lights');
const config = require("./config/tally.config.json");
const { Atem } = require("atem-connection");
const { networkInterfaces } = require("os");
const express = require("express");
const app = express();

const switcher = new Atem();

const color = {
  program: "#FF0000",
  preview: "#00FF00",
  transition: "#FFFF00",
  off: "#666666",
};

const text = {
  program: "ON AIR",
  preview: "UP NEXT",
  transition: "IN TRANSITION",
  off: "NOT SELECTED",
};

var tally = {
  id: config.inputID,
  status: "undefined",
  color: "undefined",
  text: "undefined",
  ip: "undefined",
};

// const lights = new Lights(config.ledGpioPins.red, config.ledGpioPins.green, config.ledGpioPins.blue);

// Flash to indicate the tally is currently disconnected
// lights.startFlashing(
//   config.disconnectedFlashColor.red,
//   config.disconnectedFlashColor.green,
//   config.disconnectedFlashColor.blue,
//   config.disconnectedFlashFrequency
// );

console.log("Connecting...");
switcher.connect(config.switcherIP);

switcher.on("connected", () => {
  console.log("Connected.");
  //   lights.stopFlashing();
});

switcher.on("disconnected", () => {
  console.log("Lost connection!");
  // Flash to indicate the tally is currently disconnected
  //   lights.startFlashing(
  //     config.disconnectedFlashColor.red,
  //     config.disconnectedFlashColor.green,
  //     config.disconnectedFlashColor.blue,
  //     config.disconnectedFlashFrequency
  //   );
});

switcher.on("stateChanged", (state) => {
  // State does not always contain ME video data; Return if necessary data is missing.
  if (!state || !state.video || !state.video.ME || !state.video.ME[0]) return;

  const preview = state.video.ME[0].previewInput;
  const program = state.video.ME[0].programInput;

  // If faded to black, lights are always off
  if (
    state.video.ME[0].fadeToBlack &&
    state.video.ME[0].fadeToBlack.isFullyBlack
  ) {
    // lights.off();
    // This camera is either in program OR preview, and there is an ongoing transition.
  } else if (
    state.video.ME[0].inTransition &&
    (program === config.inputID || preview === config.inputID)
  ) {
    tally.status = "transition";
    tally.color = color[tally.status];
    tally.text = text[tally.status];

    console.log("Status : ", tally);
    // lights.yellow();
  } else if (program === config.inputID) {
    tally.status = "program";
    tally.color = color[tally.status];
    tally.text = text[tally.status];

    console.log("Status : ", tally);
    // lights.red();
  } else if (preview === config.inputID) {
    tally.status = "preview";
    tally.color = color[tally.status];
    tally.text = text[tally.status];

    console.log("Status : ", tally);

    // lights.green();
  } else {
    tally.status = "off";
    tally.color = color[tally.status];
    tally.text = text[tally.status];

    console.log("Status : ", tally);
    // Camera is not in preview or program
    // lights.off();
  }
});

// get tally IP address
const nets = networkInterfaces();
const results = Object.create(null); // Or just '{}', an empty object

for (const name of Object.keys(nets)) {
  for (const net of nets[name]) {
    // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
    if (net.family === "IPv4" && !net.internal) {
      if (!results[name]) {
        results[name] = [];
      }
      results[name].push(net.address);
    }
  }
}

tally.ip = results;

// start backend listener
const listenPort = process.env.PORT || 8081;

app.use(express.static("../tally-frontend/dist"));

app.get("/tally", (req, res) => {
  res.writeHead(200, {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  });

  res.end(JSON.stringify(tally));
});

app.listen(listenPort, () => {
  console.log(`Example app listening at http://localhost:${listenPort}`);
});
