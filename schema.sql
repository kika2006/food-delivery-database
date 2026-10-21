CREATE DATABASE IF NOT EXISTS thuisbezorgd;
USE thuisbezorgd;
 
-- Table: Addresses
-- ------------------------------------------------------------
CREATE TABLE Addresses (
    AddressID    INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    Street       VARCHAR(100)    NOT NULL,
    HouseNumber  VARCHAR(10)     NOT NULL,
    City         VARCHAR(100)    NOT NULL,
    PostalCode   VARCHAR(20)     NOT NULL,
    Country      VARCHAR(100)    NOT NULL DEFAULT 'Netherlands',
    PRIMARY KEY (AddressID)
);
 
-- Table: Categories
-- ------------------------------------------------------------
CREATE TABLE Categories (
    CategoryID    INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    CategoryName  VARCHAR(100)   NOT NULL UNIQUE,
    Description   TEXT,
    PRIMARY KEY (CategoryID)
);
 
-- Table: Restaurants
-- ------------------------------------------------------------
CREATE TABLE Restaurants (
    RestaurantID    INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    AddressID       INT UNSIGNED    NOT NULL,
    RestaurantName  VARCHAR(150)    NOT NULL,
    CommissionRate  DECIMAL(5, 2)   NOT NULL,
    IsActive        TINYINT(1)      NOT NULL DEFAULT 0,
    PRIMARY KEY (RestaurantID),
    CONSTRAINT fk_restaurants_address
        FOREIGN KEY (AddressID) REFERENCES Addresses (AddressID),
    CONSTRAINT chk_commissionrate_valid
        CHECK (CommissionRate > 0 AND CommissionRate <= 100)
);
 
-- Table: Couriers
-- ------------------------------------------------------------
CREATE TABLE Couriers (
    CourierID      INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    FirstName      VARCHAR(100)    NOT NULL,
    LastName       VARCHAR(100)    NOT NULL,
    VehicleType    ENUM('Bicycle', 'Scooter', 'Car')
                                   NOT NULL,
    CurrentStatus  ENUM('Active', 'Inactive', 'Suspended')
                                   NOT NULL DEFAULT 'Inactive',
    PhoneNumber    VARCHAR(20)     NOT NULL UNIQUE,
    Email          VARCHAR(150)    NOT NULL UNIQUE,
    IsAvailable    TINYINT(1)      NOT NULL DEFAULT 0,
    LicensePlate   VARCHAR(20)     DEFAULT NULL,
    PRIMARY KEY (CourierID)
);
 
-- Table: Customers
-- ------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID        INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    AddressID         INT UNSIGNED    NOT NULL,
    FirstName         VARCHAR(100)    NOT NULL,
    LastName          VARCHAR(100)    NOT NULL,
    Email             VARCHAR(200)    NOT NULL UNIQUE,
    PasswordHash      VARCHAR(255)    NOT NULL,
    PhoneNumber       VARCHAR(30)     NOT NULL UNIQUE,
    RegistrationDate  DATE            NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (CustomerID),
    CONSTRAINT fk_customer_address
        FOREIGN KEY (AddressID) REFERENCES Addresses (AddressID)
);
 
-- Table: MenuItems
-- ------------------------------------------------------------
CREATE TABLE MenuItems (
    ItemID        INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    RestaurantID  INT UNSIGNED    NOT NULL,
    CategoryID    INT UNSIGNED    NOT NULL,
    ItemName      VARCHAR(150)    NOT NULL,
    Description   TEXT,
    Price         DECIMAL(10, 2)  NOT NULL,
    IsAvailable   TINYINT(1)      NOT NULL DEFAULT 1,
    PRIMARY KEY (ItemID),
    CONSTRAINT fk_menuitems_restaurant
        FOREIGN KEY (RestaurantID) REFERENCES Restaurants (RestaurantID),
    CONSTRAINT fk_menuitems_category
        FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID),
    CONSTRAINT chk_price_positive
        CHECK (Price > 0)
);
 
-- Table: Orders
-- ------------------------------------------------------------
CREATE TABLE Orders (
    OrderID           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    CustomerID        INT UNSIGNED    NOT NULL,
    RestaurantID      INT UNSIGNED    NOT NULL,
    CourierID         INT UNSIGNED    DEFAULT NULL,
    OrderTimestamp    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    TotalAmount       DECIMAL(10, 2)  NOT NULL,
    DeliveryFee       DECIMAL(8, 2)   NOT NULL,
    OrderStatus       ENUM('Pending', 'Confirmed', 'Preparing',
                           'Out_for_delivery', 'Delivered', 'Cancelled')
                                      NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (OrderID),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
    CONSTRAINT fk_order_restaurant
        FOREIGN KEY (RestaurantID) REFERENCES Restaurants (RestaurantID),
    CONSTRAINT fk_order_courier
        FOREIGN KEY (CourierID) REFERENCES Couriers (CourierID),
    CONSTRAINT chk_totalamount_positive
        CHECK (TotalAmount >= 0),
    CONSTRAINT chk_deliveryfee_positive
        CHECK (DeliveryFee >= 0)
);
 
-- Table: OrderDetails
-- ------------------------------------------------------------
CREATE TABLE OrderDetails (
    OrderDetailID  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    OrderID        INT UNSIGNED    NOT NULL,
    ItemID         INT UNSIGNED    NOT NULL,
    Quantity       INT             NOT NULL DEFAULT 1,
    Subtotal       DECIMAL(10, 2)  NOT NULL,
    PRIMARY KEY (OrderDetailID),
    CONSTRAINT fk_orderdetails_order
        FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
    CONSTRAINT fk_orderdetails_item
        FOREIGN KEY (ItemID) REFERENCES MenuItems (ItemID),
    CONSTRAINT chk_quantity_positive
        CHECK (Quantity > 0),
    CONSTRAINT chk_subtotal_positive
        CHECK (Subtotal > 0)
);
 
-- Table: Invoices
-- ------------------------------------------------------------
CREATE TABLE Invoices (
    InvoiceID    INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    OrderID      INT UNSIGNED    NOT NULL UNIQUE,
    InvoiceDate  DATE            NOT NULL DEFAULT (CURRENT_DATE),
    InvoiceUUID  VARCHAR(36)     NOT NULL UNIQUE,
    PRIMARY KEY (InvoiceID),
    CONSTRAINT fk_invoice_order
        FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)
);
 
-- Table: Payments
-- ------------------------------------------------------------
CREATE TABLE Payments (
    PaymentID          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    InvoiceID          INT UNSIGNED    NOT NULL,
    PaymentMethod      ENUM('Credit_card', 'Debit_card', 'Paypal',
                            'Ideal', 'Cash')
                                       NOT NULL,
    TransactionStatus  ENUM('Pending', 'Completed', 'Failed', 'Refunded')
                                       NOT NULL DEFAULT 'Pending',
    PaymentTimestamp   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (PaymentID),
    CONSTRAINT fk_payments_invoice
        FOREIGN KEY (InvoiceID) REFERENCES Invoices (InvoiceID)
);
 
-- Table: Reviews
-- ------------------------------------------------------------
CREATE TABLE Reviews (
    ReviewID   INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    OrderID    INT UNSIGNED    NOT NULL UNIQUE,
    Rating     TINYINT         NOT NULL,
    Comments   VARCHAR(1000),
    PRIMARY KEY (ReviewID),
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
    CONSTRAINT chk_reviews_rating
        CHECK (Rating BETWEEN 1 AND 5)
);
 
USE thuisbezorgd;
 
 
-- ============================================================
-- DUMMY DATA
-- ============================================================
 
-- Table: Addresses
-- ------------------------------------------------------------
INSERT INTO Addresses (Street, HouseNumber, City, PostalCode, Country) VALUES
('Kalverstraat',      '12',  'Amsterdam',  '1012 NX', 'Netherlands'),
('Lijnbaan',          '45',  'Rotterdam',  '3012 EL', 'Netherlands'),
('Grote Marktstraat', '7',   'Den Haag',   '2511 BH', 'Netherlands'),
('Vrijthof',          '3',   'Maastricht', '6211 LD', 'Netherlands'),
('Lange Viestraat',   '22',  'Utrecht',    '3511 BK', 'Netherlands'),
('Damrak',            '88',  'Amsterdam',  '1012 LP', 'Netherlands'),
('Coolsingel',        '55',  'Rotterdam',  '3012 AA', 'Netherlands'),
('Binnenhof',         '9',   'Den Haag',   '2513 AA', 'Netherlands'),
('Stationsplein',     '1',   'Eindhoven',  '5611 AC', 'Netherlands'),
('Markt',             '14',  'Groningen',  '9711 LS', 'Netherlands'),
('Nieuwstraat',       '31',  'Breda',      '4811 AK', 'Netherlands'),
('Wilhelminaplein',   '18',  'Rotterdam',  '3072 AR', 'Netherlands');
 
 
-- Table: Categories
-- ------------------------------------------------------------
INSERT INTO Categories (CategoryName, Description) VALUES
('Pizza',   'Italian-style flatbreads with various toppings'),
('Sushi',   'Japanese rice rolls, nigiri, and sashimi'),
('Burgers', 'Beef, chicken, and plant-based burgers'),
('Asian',   'Stir-fries, noodles, and fried rice dishes'),
('Healthy', 'Salads, grain bowls, and nutritious meals');
 
 
-- Table: Restaurants
-- ------------------------------------------------------------
INSERT INTO Restaurants (AddressID, RestaurantName, CommissionRate, IsActive) VALUES
(1, 'Pizzeria Napoli', 12.50, 1),
(2, 'Sushi Garden',    15.00, 1),
(3, 'Burger House',    13.00, 1),
(4, 'Wok Express',     14.00, 1),
(5, 'Green Bowl',      11.50, 1);
 
 
-- Table: Couriers
-- ------------------------------------------------------------
INSERT INTO Couriers (FirstName, LastName, VehicleType, CurrentStatus, PhoneNumber, Email, IsAvailable, LicensePlate) VALUES
('Jan',    'de Vries', 'Bicycle', 'Active',   '+31612345678', 'jan.devries@courier.nl',    1, NULL),
('Fatima', 'Yilmaz',  'Scooter', 'Active',   '+31623456789', 'fatima.yilmaz@courier.nl',  1, 'AB-12-CD'),
('Lars',   'Bakker',  'Bicycle', 'Active',   '+31634567890', 'lars.bakker@courier.nl',    0, NULL),
('Sofia',  'Chen',    'Scooter', 'Active',   '+31645678901', 'sofia.chen@courier.nl',     1, 'EF-34-GH'),
('Thomas', 'Müller',  'Car',     'Inactive', '+31656789012', 'thomas.muller@courier.nl',  0, 'IJ-56-KL');
 
 
-- Table: Customers
-- ------------------------------------------------------------
INSERT INTO Customers (AddressID, FirstName, LastName, Email, PasswordHash, PhoneNumber, RegistrationDate) VALUES
(6,  'Emma',   'Janssen',  'emma.janssen@gmail.com',   '$2b$12$hashed_pw_001', '+31611111111', '2024-03-01'),
(7,  'Liam',   'Peters',   'liam.peters@gmail.com',    '$2b$12$hashed_pw_002', '+31622222222', '2024-05-15'),
(8,  'Sophie', 'de Boer',  'sophie.deboer@gmail.com',  '$2b$12$hashed_pw_003', '+31633333333', '2024-07-20'),
(9,  'Noah',   'Visser',   'noah.visser@gmail.com',    '$2b$12$hashed_pw_004', '+31644444444', '2024-09-10'),
(10, 'Mila',   'Smit',     'mila.smit@gmail.com',      '$2b$12$hashed_pw_005', '+31655555555', '2024-11-05'),
(11, 'Daan',   'Meijer',   'daan.meijer@gmail.com',    '$2b$12$hashed_pw_006', '+31666666666', '2025-01-20'),
(12, 'Lucas', 'van den Berg', 'lucas.vandenberg@gmail.com', '$2b$12$hashed_pw_007', '+31677777777', '2026-03-17');
 
 
-- Table: MenuItems
-- ------------------------------------------------------------
INSERT INTO MenuItems (RestaurantID, CategoryID, ItemName, Description, Price, IsAvailable) VALUES
-- Pizzeria Napoli (RestaurantID 1, CategoryID 1)
(1, 1, 'Margherita',        'Classic tomato sauce with fresh mozzarella',    9.50,  1),
(1, 1, 'Quattro Formaggi',  'Four-cheese blend on a thin crispy base',       11.50, 1),
(1, 1, 'Prosciutto',        'Parma ham, rocket, and shaved Parmesan',        12.00, 1),
-- Sushi Garden (RestaurantID 2, CategoryID 2)
(2, 2, 'Salmon Nigiri',     '6 pieces of fresh Atlantic salmon nigiri',      10.00, 1),
(2, 2, 'Tuna Maki Roll',    '8-piece tuna and cucumber maki roll',            8.50, 1),
(2, 2, 'Rainbow Roll',      'California roll topped with assorted fish',     13.50, 1),
-- Burger House (RestaurantID 3, CategoryID 3)
(3, 3, 'Classic Burger',    'Beef patty with lettuce, tomato, and mayo',      9.00, 1),
(3, 3, 'BBQ Bacon Burger',  'Smoked bacon, cheddar, and house BBQ sauce',    11.00, 1),
-- Wok Express (RestaurantID 4, CategoryID 4)
(4, 4, 'Chicken Noodles',   'Stir-fried egg noodles with tender chicken',     8.50, 1),
(4, 4, 'Beef Fried Rice',   'Wok-fried jasmine rice with marinated beef',     9.00, 1),
-- Green Bowl (RestaurantID 5, CategoryID 5)
(5, 5, 'Buddha Bowl',       'Quinoa, roasted vegetables, and tahini dressing',11.00, 1),
(5, 5, 'Greek Salad Bowl',  'Feta cheese, Kalamata olives, and cucumber',     9.50, 1);
 
 
-- Table: Orders
-- ------------------------------------------------------------
INSERT INTO Orders (CustomerID, RestaurantID, CourierID, OrderTimestamp, TotalAmount, DeliveryFee, OrderStatus) VALUES
(1, 1, 1, '2024-11-10 18:30:00', 21.50, 2.50, 'Delivered'),  -- OrderID 1
(2, 1, 2, '2024-12-05 19:45:00', 14.00, 2.50, 'Delivered'),  -- OrderID 2
(3, 1, 1, '2025-01-15 20:00:00', 24.00, 2.50, 'Delivered'),  -- OrderID 3
(1, 2, 3, '2025-01-28 12:30:00', 21.50, 3.00, 'Delivered'),  -- OrderID 4
(4, 2, 4, '2025-02-14 19:00:00', 30.00, 3.00, 'Delivered'),  -- OrderID 5
(2, 3, 2, '2025-02-20 13:15:00', 22.50, 2.50, 'Delivered'),  -- OrderID 6
(3, 4, 3, '2025-03-01 18:45:00', 20.00, 2.50, 'Delivered'),  -- OrderID 7
(4, 5, 1, '2025-03-05 12:00:00', 22.50, 2.00, 'Delivered'),  -- OrderID 8
(5, 5, 4, '2025-03-10 19:30:00', 24.00, 2.00, 'Delivered');  -- OrderID 9
 
 
-- Table: OrderDetails
-- ------------------------------------------------------------
INSERT INTO OrderDetails (OrderID, ItemID, Quantity, Subtotal) VALUES
-- Order 1: Margherita x2 (9.50 × 2 = 19.00)
(1, 1, 2, 19.00),
-- Order 2: Quattro Formaggi x1 (11.50 × 1 = 11.50)
(2, 2, 1, 11.50),
-- Order 3: Prosciutto x1 + Margherita x1 (12.00 + 9.50 = 21.50)
(3, 3, 1, 12.00),
(3, 1, 1,  9.50),
-- Order 4: Salmon Nigiri x1 + Tuna Maki Roll x1 (10.00 + 8.50 = 18.50)
(4, 4, 1, 10.00),
(4, 5, 1,  8.50),
-- Order 5: Rainbow Roll x2 (13.50 × 2 = 27.00)
(5, 6, 2, 27.00),
-- Order 6: Classic Burger x1 + BBQ Bacon Burger x1 (9.00 + 11.00 = 20.00)
(6, 7, 1,  9.00),
(6, 8, 1, 11.00),
-- Order 7: Chicken Noodles x1 + Beef Fried Rice x1 (8.50 + 9.00 = 17.50)
(7, 9, 1,  8.50),
(7, 10, 1, 9.00),
-- Order 8: Buddha Bowl x1 + Greek Salad Bowl x1 (11.00 + 9.50 = 20.50)
(8, 11, 1, 11.00),
(8, 12, 1,  9.50),
-- Order 9: Buddha Bowl x2 (11.00 × 2 = 22.00)
(9, 11, 2, 22.00);
 
 
-- Table: Invoices
-- ------------------------------------------------------------
INSERT INTO Invoices (OrderID, InvoiceDate, InvoiceUUID) VALUES
(1, '2024-11-10', 'a1b2c3d4-0001-4e5f-8a9b-000000000001'),
(2, '2024-12-05', 'a1b2c3d4-0002-4e5f-8a9b-000000000002'),
(3, '2025-01-15', 'a1b2c3d4-0003-4e5f-8a9b-000000000003'),
(4, '2025-01-28', 'a1b2c3d4-0004-4e5f-8a9b-000000000004'),
(5, '2025-02-14', 'a1b2c3d4-0005-4e5f-8a9b-000000000005'),
(6, '2025-02-20', 'a1b2c3d4-0006-4e5f-8a9b-000000000006'),
(7, '2025-03-01', 'a1b2c3d4-0007-4e5f-8a9b-000000000007'),
(8, '2025-03-05', 'a1b2c3d4-0008-4e5f-8a9b-000000000008'),
(9, '2025-03-10', 'a1b2c3d4-0009-4e5f-8a9b-000000000009');
 
 
-- Table: Payments
-- ------------------------------------------------------------
INSERT INTO Payments (InvoiceID, PaymentMethod, TransactionStatus, PaymentTimestamp) VALUES
(1, 'Ideal',       'Completed', '2024-11-10 18:31:05'),
(2, 'Credit_card', 'Completed', '2024-12-05 19:46:20'),
(3, 'Paypal',      'Completed', '2025-01-15 20:01:10'),
(4, 'Ideal',       'Completed', '2025-01-28 12:31:45'),
(5, 'Debit_card',  'Completed', '2025-02-14 19:02:30'),
(6, 'Credit_card', 'Completed', '2025-02-20 13:16:55'),
(7, 'Cash',        'Completed', '2025-03-01 18:46:00'),
(8, 'Ideal',       'Completed', '2025-03-05 12:02:15'),
(9, 'Paypal',      'Completed', '2025-03-10 19:31:40');
 
 
-- Table: Reviews
-- ------------------------------------------------------------
INSERT INTO Reviews (OrderID, Rating, Comments) VALUES
(1, 4, 'Delicious pizza, arrived hot and on time.'),
(2, 5, 'Perfect quattro formaggi, will definitely order again!'),
(3, 4, 'Great variety, the prosciutto was excellent.'),
(4, 5, 'Freshest sushi I have had from a delivery service.'),
(5, 4, 'Rainbow roll was beautiful and tasty.'),
(7, 3, 'Noodles were slightly overcooked, but still good value.'),
(8, 5, 'Incredible buddha bowl, super fresh ingredients.'),
(9, 4, 'Generous portions and arrived quickly.');
