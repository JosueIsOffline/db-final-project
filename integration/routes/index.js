const express = require('express');
const router = express()
const fs = require('fs')
const path = require('path')
require('dotenv').config()
const logger = require('../utils/logger');

const PATH_ROUTES = __dirname


const removeExtension = (fileName) => {
    if(fileName === "") throw new  Error("Should provide a filename")
    return fileName.split('.').shift()
}

const getVersionFolders = () => {
    const folders = fs.readdirSync(PATH_ROUTES).filter((file) => {
        return fs.statSync(path.join(PATH_ROUTES, file)).isDirectory()
    })

    if(folders.length === 0) {
        logger.log("No version folders found", "warn")
        throw new error("No version folders found")
    }

    return folders
}

const loadVersionRoutes = (versionPrefix, versionPath) => {
    fs.readdirSync(versionPath).filter((fileName) => {
        const name = removeExtension(fileName)
        if(name !== "index") {
            const version = versionPrefix.split("/api/")[1]
            logger.log(
                `Loading ${name} routes for version ${version}`, "info"
            )
            router.use(
                `${versionPrefix}/${name}`,
                require(path.join(versionPath, fileName))
            )
        }
    })
}

getVersionFolders().forEach((version) => {
    const versionPrefix = `/api/${version}`
    const versionPath = path.join(PATH_ROUTES, version)
    loadVersionRoutes(versionPrefix, versionPath)
})

module.exports = {
    router,
    loadVersionRoutes,
    getVersionFolders,
    removeExtension
}