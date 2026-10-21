-- Query 1: Restaurant Performance Report
SELECT
    r.RestaurantName,
    COUNT(o.OrderID)                                          AS TotalOrders,
    SUM(o.TotalAmount)                                        AS TotalRevenue,
    ROUND(SUM(o.TotalAmount) * r.CommissionRate / 100, 2)    AS CommissionEarned,
    ROUND(AVG(rv.Rating), 2)                                  AS AverageRating
FROM Restaurants r
JOIN Orders o
    ON  r.RestaurantID = o.RestaurantID
    AND o.OrderStatus  = 'Delivered'
LEFT JOIN Reviews rv
    ON o.OrderID = rv.OrderID
GROUP BY
    r.RestaurantID,
    r.RestaurantName,
    r.CommissionRate
HAVING COUNT(o.OrderID) >= 2
ORDER BY TotalRevenue DESC
LIMIT 10;

-- ------------------------------------------------------------
-- Query 2 (LEFT JOIN): Customers with No Orders
SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName)  AS CustomerName,
    c.Email,
    c.PhoneNumber,
    c.RegistrationDate
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL
ORDER BY c.RegistrationDate DESC;
