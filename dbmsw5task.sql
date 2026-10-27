USE ecommerce_db;
CREATE TABLE Payment (
    Payment_ID          INT AUTO_INCREMENT,
    Order_ID            INT NOT NULL,
    Payment_Date        DATE NOT NULL,
    Payment_Mode        VARCHAR(20) NOT NULL,
    Payment_Status      VARCHAR(10) NOT NULL DEFAULT 'Pending',
    Transaction_Amount  DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_payment PRIMARY KEY (Payment_ID),
    CONSTRAINT fk_payment_order FOREIGN KEY (Order_ID)
        REFERENCES Orders (Order_ID) ON DELETE CASCADE,
    CONSTRAINT uq_payment_order UNIQUE (Order_ID),
    CONSTRAINT chk_payment_mode CHECK
        (Payment_Mode IN ('UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Cash on Delivery')),
    CONSTRAINT chk_payment_status CHECK
        (Payment_Status IN ('Pending', 'Success', 'Failed')),
    CONSTRAINT chk_payment_amount CHECK (Transaction_Amount > 0)
);
INSERT INTO Payment (Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount) VALUES
(1, '2026-09-01', 'UPI',              'Success', 3697.00),
(2, '2026-09-05', 'Credit Card',      'Success', 3097.00),
(3, '2026-09-12', 'Net Banking',      'Success', 1999.00),
(4, '2026-09-18', 'Debit Card',       'Success', 5598.00),
(5, '2026-09-25', 'Cash on Delivery', 'Pending', 6396.00),
(6, '2026-10-02', 'UPI',              'Failed',  4897.00),
(7, '2026-10-10', 'UPI',              'Pending', 4999.00);

INSERT INTO Payment (Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount)
SELECT Order_ID, CURRENT_DATE, 'Debit Card', 'Failed', Total_Amount
FROM Orders
WHERE Order_ID = 9;

SELECT Payment_ID, Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount
FROM Payment
WHERE Order_ID = 1;

SELECT Payment_ID, Order_ID, Payment_Date, Payment_Mode, Transaction_Amount
FROM Payment
WHERE Payment_Status = 'Success'
ORDER BY Payment_Date;

SELECT
    p.Payment_ID,
    c.Customer_ID,
    c.Name AS Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    o.Total_Amount AS Order_Total,
    p.Payment_Date,
    p.Payment_Mode,
    p.Payment_Status,
    p.Transaction_Amount
FROM Payment p
JOIN Orders o    ON p.Order_ID = o.Order_ID
JOIN Customers c ON o.Customer_ID = c.Customer_ID
ORDER BY p.Payment_ID;


SELECT Payment_ID, Order_ID, Payment_Date, Payment_Mode, Payment_Status, Transaction_Amount
FROM Payment
WHERE Payment_Status IN ('Failed', 'Pending')
ORDER BY Payment_Status, Payment_ID;

UPDATE Payment
SET Payment_Status = 'Success',
    Payment_Date   = '2026-10-03'
WHERE Order_ID = 6
  AND Payment_Status = 'Failed';

SELECT Payment_Status, COUNT(*) AS Payment_Count
FROM Payment
WHERE Payment_Status IN ('Success', 'Failed')
GROUP BY Payment_Status;

SELECT p.Payment_ID, p.Order_ID, p.Transaction_Amount, o.Total_Amount
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID
WHERE p.Transaction_Amount <> o.Total_Amount;


SELECT Payment_Mode, COUNT(*) AS Transaction_Count
FROM Payment
GROUP BY Payment_Mode
ORDER BY Transaction_Count DESC, Payment_Mode;

SELECT Payment_Mode, COUNT(*) AS Transaction_Count
FROM Payment
GROUP BY Payment_Mode
HAVING COUNT(*) = (
    SELECT MAX(mode_count)
    FROM (
        SELECT COUNT(*) AS mode_count
        FROM Payment
        GROUP BY Payment_Mode
    ) AS counts
);

SELECT SUM(Transaction_Amount) AS Total_Successful_Revenue
FROM Payment
WHERE Payment_Status = 'Success';

SELECT
    Payment_Mode,
    SUM(CASE WHEN Payment_Status = 'Success' THEN Transaction_Amount ELSE 0 END) AS Revenue
FROM Payment
GROUP BY Payment_Mode
ORDER BY Revenue DESC;

SELECT
    ROUND(AVG(Transaction_Amount), 2) AS Average_All_Transactions,
    ROUND(AVG(CASE WHEN Payment_Status = 'Success' THEN Transaction_Amount END), 2)
        AS Average_Successful_Transactions
FROM Payment;

SELECT
    c.Customer_ID,
    c.Name AS Customer_Name,
    p.Payment_ID,
    o.Order_ID,
    p.Payment_Date,
    p.Payment_Mode,
    p.Payment_Status,
    p.Transaction_Amount
FROM Customers c
JOIN Orders o  ON c.Customer_ID = o.Customer_ID
JOIN Payment p ON o.Order_ID = p.Order_ID
ORDER BY c.Customer_ID, p.Payment_Date;

SELECT
    SUM(Payment_Status = 'Success') AS Successful_Transactions,
    SUM(Payment_Status = 'Failed')  AS Failed_Transactions,
    SUM(Payment_Status = 'Pending') AS Pending_Transactions,
    COUNT(*)                        AS Total_Transactions
FROM Payment;

SELECT
    o.Order_ID,
    c.Name AS Customer_Name,
    o.Order_Date,
    o.Order_Status,
    o.Total_Amount,
    p.Payment_Mode,
    p.Payment_Status
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
JOIN Payment p   ON o.Order_ID = p.Order_ID
WHERE p.Payment_Status IN ('Failed', 'Pending')
ORDER BY p.Payment_Status, o.Order_ID;