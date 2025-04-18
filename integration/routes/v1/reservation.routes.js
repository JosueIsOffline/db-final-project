const express = require('express');
const router = express.Router();
const reservationController = require('../../controllers/reservation.controller');

/**
 * @swagger
 * /api/v1/reservation:
 *   post:
 *     summary: Create a new reservation
 *     tags: [Reservations]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - storeId
 *               - productId
 *               - quantity
 *             properties:
 *               storeId:
 *                 type: integer
 *                 description: ID of the store
 *               productId:
 *                 type: integer
 *                 description: ID of the product
 *               quantity:
 *                 type: integer
 *                 description: Quantity to reserve
 *               customerInfo:
 *                 type: object
 *                 properties:
 *                   name:
 *                     type: string
 *                     description: Customer name
 *                   email:
 *                     type: string
 *                     description: Customer email
 *                   phone:
 *                     type: string
 *                     description: Customer phone
 *                   sqlCustomerId:
 *                     type: integer
 *                     description: Customer ID in SQL database
 *               notes:
 *                 type: string
 *                 description: Additional notes
 *     responses:
 *       201:
 *         description: Reservation created successfully
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.post('/', reservationController.createReservation);

/**
 * @swagger
 * /api/v1/reservation/active:
 *   get:
 *     summary: Get active reservations
 *     tags: [Reservations]
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *         description: Page number (default 1)
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *         description: Items per page (default 10)
 *       - in: query
 *         name: storeId
 *         schema:
 *           type: integer
 *         description: Filter by store ID
 *     responses:
 *       200:
 *         description: List of active reservations
 *       500:
 *         description: Server error
 */
router.get('/active', reservationController.getActiveReservations);

/**
 * @swagger
 * /api/v1/reservation/customer/{customerId}:
 *   get:
 *     summary: Get reservations for a specific customer
 *     tags: [Reservations]
 *     parameters:
 *       - in: path
 *         name: customerId
 *         schema:
 *           type: integer
 *         required: true
 *         description: SQL Customer ID
 *     responses:
 *       200:
 *         description: Customer reservations
 *       400:
 *         description: Bad request
 *       500:
 *         description: Server error
 */
router.get('/customer/:customerId', reservationController.getCustomerReservations);

/**
 * @swagger
 * /api/v1/reservation/{confirmationCode}:
 *   get:
 *     summary: Get reservation details by confirmation code
 *     tags: [Reservations]
 *     parameters:
 *       - in: path
 *         name: confirmationCode
 *         schema:
 *           type: string
 *         required: true
 *         description: Reservation confirmation code
 *     responses:
 *       200:
 *         description: Reservation details
 *       404:
 *         description: Reservation not found
 *       500:
 *         description: Server error
 */
router.get('/:confirmationCode', reservationController.getReservationByCode);

/**
 * @swagger
 * /api/v1/reservation/{confirmationCode}/confirm:
 *   put:
 *     summary: Confirm a reservation
 *     tags: [Reservations]
 *     parameters:
 *       - in: path
 *         name: confirmationCode
 *         schema:
 *           type: string
 *         required: true
 *         description: Reservation confirmation code
 *     responses:
 *       200:
 *         description: Reservation confirmed successfully
 *       400:
 *         description: Bad request
 *       404:
 *         description: Reservation not found
 *       500:
 *         description: Server error
 */
router.put('/:confirmationCode/confirm', reservationController.confirmReservation);

/**
 * @swagger
 * /api/v1/reservation/{confirmationCode}/cancel:
 *   put:
 *     summary: Cancel a reservation
 *     tags: [Reservations]
 *     parameters:
 *       - in: path
 *         name: confirmationCode
 *         schema:
 *           type: string
 *         required: true
 *         description: Reservation confirmation code
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               reason:
 *                 type: string
 *                 description: Reason for cancellation
 *     responses:
 *       200:
 *         description: Reservation cancelled successfully
 *       400:
 *         description: Bad request
 *       404:
 *         description: Reservation not found
 *       500:
 *         description: Server error
 */
router.put('/:confirmationCode/cancel', reservationController.cancelReservation);

/**
 * @swagger
 * /api/v1/reservation/{confirmationCode}/complete:
 *   put:
 *     summary: Complete a reservation (product picked up)
 *     tags: [Reservations]
 *     parameters:
 *       - in: path
 *         name: confirmationCode
 *         schema:
 *           type: string
 *         required: true
 *         description: Reservation confirmation code
 *     responses:
 *       200:
 *         description: Reservation completed successfully
 *       400:
 *         description: Bad request
 *       404:
 *         description: Reservation not found
 *       500:
 *         description: Server error
 */
router.put('/:confirmationCode/complete', reservationController.completeReservation);

module.exports = router;