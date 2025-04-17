const { MongoClient } = require("mongodb");
const mongoose = require("mongoose");
const { mongoURI } = require("../config/database");
const Logger = require("../utils/logger");

//MongoDB Connection
const connectToMongoDB = async () => {
  try {
    await mongoose.connect(mongoURI, {
      dbName: "RetailChainDB",
    });
    console.log("\n");
    Logger.log("MongoDB connection established successfully", "success");
    Logger.log(
      `MongoDB URI: ${mongoURI.replace(/\/\/(.+):(.+)@/, "//***:***@")}`
    ); // Hide credentials if present
    Logger.log(`Database: ${mongoURI.split("/").pop()}`);
  } catch (error) {
    Logger.log(`MongoDB connection failed: ${error.message}`, "error");
    Logger.log(
      "Connection details:",
      {
        uri: mongoURI.replace(/\/\/(.+):(.+)@/, "//***:***@"), // Hide credentials in logs
        fullError: error,
      },
      "debug"
    );
    process.exit(1);
  }
};

module.exports = connectToMongoDB;
