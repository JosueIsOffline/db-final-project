const express = require('express');
const router = express.Router();

/**
 * @swagger
 * components:
 *  schemas:
 *    Exmaple:
 *      type: object
 *      properties:
 *        message:
 *         type: string
 *         description: Welcome message
 *        version:
 *         type: string
 *         description: API version
 *      example:
 *         message: Welcome to the Retail Chain API!
 *         version: v1
 */


/**
 * @swagger
 * tags:
 *   - name: Example
 *     description: Example endpoint
 */


/**
 * @swagger
 * /api/v1/example:
 *   get:
 *     summary: Get all Examples
 *     description: Get all examples from the database
 *     tags: 
 *       - Example
 *     responses:
 *       200:
 *         description: A welcome message with API version
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   description: Welcome message
 *                 version:
 *                   type: string
 *                   description: API version
 *               example:
 *                 message: Welcome to the Retail Chain API!
 *                 version: v1
 */
router.get('/', (req, res) => {
    res.status(200).json({
        message: 'Welcome to the Retail Chain API!',
        version: 'v1'
    });
})

module.exports = router;