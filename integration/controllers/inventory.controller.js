const inventoryService = require('../services/inventory.service')
const Logger = require('../utils/logger')

/**
 * Contrller for inventory operations
 */
const inventoryController = {
    /**
   * Get all inventory across stores
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  getAllInventory: async (req, res) => {
    try {
        const { limit } = req.query;
        const inventory = await inventoryService.getAllInventory(limit)

        res.status(200).json({
            success: true,
            count: inventory.length,
            data: inventory
        })

    } catch (error) {
        Logger.error(`Error getting all inventory: ${error.message}`);
        res.status(500).json({
          success: false,
          message: 'Error retrieving inventory',
          error: error.message
        });  
    }
  },

   /**
   * Get inventory for a specific store
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  getStoreInventory: async (req, res) => {
    try {
        const { storeId } = req.params;

        if(!storeId) {
            return res.status(400).json({
                success: false,
                message: "Store ID is required",
            })
        }

        const inventory = await inventoryService.getStoreInventory(storeId)

        res.status(200).json({
            success: true,
            count: inventory.length,
            data: inventory
        })

    } catch (error) {
        Logger.error(`Error getting store inventory: ${error.message}`);
      res.status(500).json({
        success: false,
        message: 'Error retrieving store inventory',
        error: error.message
      });
    }
  },

  
  /**
   * Get inventory for a specific product across all stores
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  getProductInventory: async (req, res) => {
    try {
      const { productId } = req.params;
      
      if (!productId) {
        return res.status(400).json({
          success: false,
          message: 'Product ID is required'
        });
      }
      
      const inventory = await inventoryService.getProductInventory(productId);
      
      res.status(200).json({
        success: true,
        count: inventory.length,
        data: inventory
      });
    } catch (error) {
      Logger.error(`Error getting product inventory: ${error.message}`);
      res.status(500).json({
        success: false,
        message: 'Error retrieving product inventory',
        error: error.message
      });
    }
  },
  
  /**
   * Check product availability in a store
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  checkAvailability: async (req, res) => {
    try {
      const { storeId, productId } = req.params;
      
      if (!storeId || !productId) {
        return res.status(400).json({
          success: false,
          message: 'Store ID and Product ID are required'
        });
      }
      
      const availability = await inventoryService.checkAvailability(storeId, productId);
      
      res.status(200).json({
        success: true,
        data: availability
      });
    } catch (error) {
      Logger.error(`Error checking availability: ${error.message}`);
      res.status(500).json({
        success: false,
        message: 'Error checking product availability',
        error: error.message
      });
    }
  },
  
  /**
   * Update inventory quantity
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  updateInventory: async (req, res) => {
    try {
      const { storeId, productId } = req.params;
      const { quantity } = req.body;
      
      if (!storeId || !productId || quantity === undefined) {
        return res.status(400).json({
          success: false,
          message: 'Store ID, Product ID, and quantity are required'
        });
      }
      
      const result = await inventoryService.updateInventory(storeId, productId, parseInt(quantity));
      
      res.status(200).json({
        success: true,
        message: `Inventory updated successfully. New quantity: ${result.quantityInStock}`,
        data: result
      });
    } catch (error) {
      Logger.error(`Error updating inventory: ${error.message}`);
      
      // Specific error handling for insufficient inventory
      if (error.message.includes('Insufficient inventory')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Error updating inventory',
        error: error.message
      });
    }
  },
  
  /**
   * Get products with low stock
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  getLowStockItems: async (req, res) => {
    try {
      const lowStockItems = await inventoryService.getLowStockItems();
      
      res.status(200).json({
        success: true,
        count: lowStockItems.length,
        data: lowStockItems
      });
    } catch (error) {
      Logger.error(`Error getting low stock items: ${error.message}`);
      res.status(500).json({
        success: false,
        message: 'Error retrieving low stock items',
        error: error.message
      });
    }
  },
  
  /**
   * Get inventory transactions for a store
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  getInventoryTransactions: async (req, res) => {
    try {
      const { storeId } = req.params;
      const { limit } = req.query;
      
      if (!storeId) {
        return res.status(400).json({
          success: false,
          message: 'Store ID is required'
        });
      }
      
      const transactions = await inventoryService.getInventoryTransactions(storeId, limit || 100);
      
      res.status(200).json({
        success: true,
        count: transactions.length,
        data: transactions
      });
    } catch (error) {
      Logger.error(`Error getting inventory transactions: ${error.message}`);
      res.status(500).json({
        success: false,
        message: 'Error retrieving inventory transactions',
        error: error.message
      });
    }
  },
  
  /**
   * Transfer inventory between stores
   * @param {Request} req - Express request object
   * @param {Response} res - Express response object
   */
  transferInventory: async (req, res) => {
    try {
      const { sourceStoreId, targetStoreId, productId, quantity } = req.body;
      
      if (!sourceStoreId || !targetStoreId || !productId || !quantity) {
        return res.status(400).json({
          success: false,
          message: 'Source store ID, target store ID, product ID, and quantity are required'
        });
      }
      
      const result = await inventoryService.transferInventory(
        parseInt(sourceStoreId),
        parseInt(targetStoreId),
        parseInt(productId),
        parseInt(quantity)
      );
      
      res.status(200).json({
        success: true,
        message: 'Inventory transferred successfully',
        data: result
      });
    } catch (error) {
      Logger.error(`Error transferring inventory: ${error.message}`);
      
      // Handle specific errors
      if (error.message.includes('Source and target stores must be different') ||
          error.message.includes('Transfer quantity must be greater than zero') ||
          error.message.includes('Insufficient inventory')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }
      
      res.status(500).json({
        success: false,
        message: 'Error transferring inventory',
        error: error.message
      });
    }
  }

}

module.exports = inventoryController;