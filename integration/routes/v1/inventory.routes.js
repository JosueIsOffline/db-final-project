const express = require('express');
const router = express.Router();
const inventoryController = require('../../controllers/inventory.controller');

/**
 * @swagger
 * /api/v1/inventory:
 *   get:
 *     summary: Get all inventory across stores
 *     tags: [Inventory]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *         description: Limit number of results
 *     responses:
 *       200:
 *         description: List of inventory items
 *       500:
 *         description: Server error
 */
router.get('/', inventoryController.getAllInventory);

/**
 * @swagger
 * /api/v1/inventory/low-stock:
 *   get:
 *     summary: Get products with low stock
 *     tags: [Inventory]
 *     responses:
 *       200:
 *         description: List of products with low stock
 *       500:
 *         description: Server error
 */
router.get('/low-stock', inventoryController.getLowStockItems);

/**
 * @swagger
 * /api/v1/inventory/stores/{storeId}:
 *   get:
 *     summary: Get inventory for a specific store
 *     tags: [Inventory]
 *     parameters:
 *       - in: path
 *         name: storeId
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID of the store
 *     responses:
 *       200:
 *         description: Store inventory
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.get('/stores/:storeId', inventoryController.getStoreInventory);

/**
 * @swagger
 * /api/v1/inventory/products/{productId}:
 *   get:
 *     summary: Get inventory for a specific product across all stores
 *     tags: [Inventory]
 *     parameters:
 *       - in: path
 *         name: productId
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID of the product
 *     responses:
 *       200:
 *         description: Product inventory
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.get('/products/:productId', inventoryController.getProductInventory);

/**
 * @swagger
 * /api/v1/inventory/availability/{storeId}/{productId}:
 *   get:
 *     summary: Check product availability in a store
 *     tags: [Inventory]
 *     parameters:
 *       - in: path
 *         name: storeId
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID of the store
 *       - in: path
 *         name: productId
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID of the product
 *     responses:
 *       200:
 *         description: Product availability information
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.get('/availability/:storeId/:productId', inventoryController.checkAvailability);

/**
 * @swagger
 * /api/v1/inventory/update/{storeId}/{productId}:
 *   put:
 *     summary: Update inventory quantity
 *     tags: [Inventory]
 *     parameters:
 *       - in: path
 *         name: storeId
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID of the store
 *       - in: path
 *         name: productId
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID of the product
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - quantity
 *             properties:
 *               quantity:
 *                 type: integer
 *                 description: Quantity to add (positive) or remove (negative)
 *     responses:
 *       200:
 *         description: Inventory updated successfully
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.put('/update/:storeId/:productId', inventoryController.updateInventory);

/**
 * @swagger
 * /api/v1/inventory/transactions/{storeId}:
 *   get:
 *     summary: Get inventory transactions for a store
 *     tags: [Inventory]
 *     parameters:
 *       - in: path
 *         name: storeId
 *         schema:
 *           type: integer
 *         required: true
 *         description: ID of the store
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *         description: Limit number of results
 *     responses:
 *       200:
 *         description: Transaction history
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.get('/transactions/:storeId', inventoryController.getInventoryTransactions);

/**
 * @swagger
 * /api/v1/inventory/transfer:
 *   post:
 *     summary: Transfer inventory between stores
 *     tags: [Inventory]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - sourceStoreId
 *               - targetStoreId
 *               - productId
 *               - quantity
 *             properties:
 *               sourceStoreId:
 *                 type: integer
 *                 description: ID of the source store
 *               targetStoreId:
 *                 type: integer
 *                 description: ID of the target store
 *               productId:
 *                 type: integer
 *                 description: ID of the product to transfer
 *               quantity:
 *                 type: integer
 *                 description: Quantity to transfer
 *     responses:
 *       200:
 *         description: Inventory transferred successfully
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.post('/transfer', inventoryController.transferInventory);

module.exports = router;