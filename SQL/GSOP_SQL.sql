CREATE SCHEMA gsop;
use gsop;

CREATE TABLE users (
   id INTEGER PRIMARY KEY,
   username VARCHAR(255) NOT NULL ,
   role VARCHAR(50) NOT NULL,
   email VARCHAR(255) UNIQUE NOT NULL,
   password VARCHAR(255) NOT NULL
);


CREATE TABLE ride (
  ride_id INTEGER PRIMARY KEY,
  ride_giver_id INTEGER NOT NULL,
  origin VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  departure TIMESTAMP NOT NULL,
  available_seats INTEGER NOT NULL CHECK(available_seats>=0),
  FOREIGN KEY( ride_giver_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO users( id,username,role,email,password) VALUES (1, 'Ashwin','ride_giver', 'ashwin12@gmail.com','ashwin123');
INSERT INTO users( id,username,role,email,password) VALUES (2, 'Brindha','Passenger', 'brindha12@gmail.com','brindha123');
INSERT INTO users( id,username,role,email,password) VALUES (3, 'Diya','ride_giver', 'diya12@gmail.com','diya123');
INSERT INTO users( id,username,role,email,password) VALUES (4, 'Guru','Passenger', 'guru12@gmail.com','guru123');
INSERT INTO users( id,username,role,email,password) VALUES (5, 'Hema','ride_giver', 'hema12@gmail.com','hema123');
INSERT INTO users( id,username,role,email,password) VALUES (6, 'Kavin','Passenger', 'kavin12@gmail.com','kavin123');
INSERT INTO users( id,username,role,email,password) VALUES (7, 'Nisa','ride_giver', 'nisa12@gmail.com','nisa123');
INSERT INTO users( id,username,role,email,password) VALUES (8, 'Pradeep','Passenger', 'pradeep12@gmail.com','pradeep123');
INSERT INTO users( id,username,role,email,password) VALUES (9, 'Sri','ride_giver', 'sri12@gmail.com','sri123');

SELECT * FROM users;

INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (1,1,'Erode ','Karur','2025-03-01 08:30:00',8);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (2,3,'Coimbatore','Tirupur','2025-03-05 09:30:00',6);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (3,5,'Tirupur','Karur','2025-03-07 05:15:02',4);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (4,7,'Chennai','vellore','2025-03-15 10:40:11',5);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (5,1,'Trichy','Madurai','2025-03-18 12:48:43',6);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (6,3,'Trichy','Chennai','2025-03-20 06:18:09',7);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (7,5,'Madurai','Theni','2025-03-22 18:37:10',2);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (8,1,'Cuddalore','Thanjavur','2025-03-28 20:51:00',4);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (9,3,'Salem','Erode','2025-04-01 06:18:00',5);
INSERT INTO ride (ride_id,ride_giver_id,origin,destination,departure,available_seats) VALUES (10,1,'Kochi','Thiruvanthapuram','2025-04-03 14:20:13',5);

SELECT * FROM ride;

UPDATE ride SET departure='2025-04-03 14:20:13' WHERE ride_id=10;
SELECT * FROM ride;

use gsop;

CREATE TABLE Booking (
  booking_id INTEGER PRIMARY KEY,
  ride_id INTEGER NOT NULL,
  passenger_id INTEGER NOT NULL,
  booking_datetime TIMESTAMP  DEFAULT  CURRENT_TIMESTAMP,
  status VARCHAR(50) NOT NULL CHECK ( status IN ('Confirmed','Cancelled','Pending')),
  FOREIGN KEY (ride_id) REFERENCES ride(ride_id) ON DELETE CASCADE,
  FOREIGN KEY (passenger_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO Booking (booking_id, ride_id, passenger_id, booking_datetime, status) VALUES (301,1,2,'2025-02-20 10:00:00','Confirmed');
INSERT INTO Booking (booking_id, ride_id, passenger_id, booking_datetime, status) VALUES (302,2,4,'2025-02-21 11:30:00','Pending');
INSERT INTO Booking (booking_id, ride_id, passenger_id, booking_datetime, status) VALUES (303,3,6,'2025-02-22 12:45:00','Confirmed');
INSERT INTO Booking (booking_id, ride_id, passenger_id, booking_datetime, status) VALUES (304,4,8,'2025-02-23 14:00:00','Cancelled');
INSERT INTO Booking (booking_id, ride_id, passenger_id, booking_datetime, status) VALUES (305,5,2,'2025-02-24 15:15:00','Confirmed');

SELECT * FROM Booking;

CREATE TABLE payment (
 payment_id INTEGER PRIMARY KEY,
 booking_id INTEGER NOT NULL,
 amount DECIMAL(10,2) NOT NULL CHECK ( amount >=0),
 payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
 FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE
);

INSERT INTO payment (payment_id, booking_id, amount, payment_date) VALUES (401,301,25.00,'2025-02-20 10:30:00');
INSERT INTO payment (payment_id, booking_id, amount, payment_date) VALUES (402,303,30.50,'2025-02-22 13:00:00');
INSERT INTO payment (payment_id, booking_id, amount, payment_date) VALUES (403,305,20.00,'2025-02-24 15:45:00');
INSERT INTO payment (payment_id, booking_id, amount, payment_date) VALUES (404,302,15.75,'2025-02-21 11:35:00');

SELECT * FROM payment;

SELECT username FROM users;
SELECT * FROM ride WHERE ride_giver_id='3';
SELECT u.username FROM booking b JOIN users u ON b.passenger_id = u.id WHERE b.ride_id='1';
SELECT * FROM ride WHERE ride_giver_id='1' OR ride_id IN (SELECT ride_id FROM booking WHERE passenger_id='4');
SELECT * FROM ride;
SELECT * FROM ride WHERE origin='Erode' AND destination='Karur';
SELECT ride_id, COUNT(passenger_id) as passenger_count FROM booking GROUP BY ride_id;
SELECT * FROM ride WHERE departure='2025-03-07 05:15:02';
SELECT DISTINCT u.username FROM users u JOIN ride r ON u.id=ride_giver_id WHERE r.departure='2025-03-07 05:15:02';
SELECT * FROM ride WHERE origin='Chennai'AND available_seats>2;
SELECT u.username , COUNT(r.ride_id) AS total_rides FROM users u JOIN ride r ON u.id=r.ride_giver_id GROUP BY u.username HAVING COUNT(r.ride_id)>1;
SELECT * FROM ride WHERE origin='Coimbatore' AND departure='2025-03-07 05:15:02' AND available_seats>0;
SELECT * FROM ride WHERE origin='Coimbatore' AND destination='Tirupur';
SELECT * FROM ride ORDER BY departure DESC LIMIT 1;
SELECT origin, destination, count(*) AS frequency FROM ride GROUP BY origin,destination ORDER BY frequency DESC;
SELECT * FROM ride WHERE TIME (departure) between '03:00:00' AND '09:00;00';