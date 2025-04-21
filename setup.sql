
-- Create Users Table
CREATE TABLE IF NOT EXISTS users (
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   firstname TEXT NOT NULL,
   lastname  TEXT NOT NULL,
   contact TEXT NOT NULL,
   role TEXT NOT NULL,
   email TEXT UNIQUE NOT NULL,
   password TEXT NOT NULL,
   confirm_password TEXT NOT NULL
);

-- Create Ride Table
CREATE TABLE IF NOT EXISTS ride (
  ride_id INTEGER PRIMARY KEY AUTOINCREMENT,
  ride_giver_id INTEGER NOT NULL,
  origin TEXT NOT NULL,
  destination TEXT NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  available_seats INTEGER NOT NULL CHECK(available_seats >= 0),
  FOREIGN KEY(ride_giver_id) REFERENCES users(id) ON DELETE CASCADE
);



-- Create Booking Table
CREATE TABLE IF NOT EXISTS Booking (
  booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
  ride_id INTEGER NOT NULL,
  passenger_id INTEGER NOT NULL,
  booking_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
  status TEXT NOT NULL CHECK(status IN ('Confirmed', 'Cancelled', 'Pending')),
  FOREIGN KEY (ride_id) REFERENCES ride(ride_id) ON DELETE CASCADE,
  FOREIGN KEY (passenger_id) REFERENCES users(id) ON DELETE CASCADE
);



-- Create Payment Table
CREATE TABLE IF NOT EXISTS payment (
  payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
  booking_id INTEGER NOT NULL,
  amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE
);


-- Queries
SELECT * FROM users;
SELECT * FROM ride;
SELECT * FROM booking;
SELECT * FROM payment;

SELECT firstname FROM users;
SELECT * FROM ride WHERE ride_giver_id = 3;
SELECT u.firstname FROM booking b JOIN users u ON b.passenger_id = u.id WHERE b.ride_id = 1;
SELECT * FROM ride WHERE ride_giver_id = 1 OR ride_id IN (SELECT ride_id FROM booking WHERE passenger_id = 4);
SELECT * FROM ride WHERE origin = 'Erode' AND destination = 'Karur';
SELECT ride_id, COUNT(passenger_id) AS passenger_count FROM booking GROUP BY ride_id;
SELECT * FROM ride WHERE departure = '2025-03-07 05:15:02';
SELECT DISTINCT u.firstname FROM users u JOIN ride r ON u.id = r.ride_giver_id WHERE r.departure = '2025-03-07 05:15:02';
SELECT * FROM ride WHERE origin = 'Chennai' AND available_seats > 2;
SELECT u.firstname, COUNT(r.ride_id) AS total_rides FROM users u JOIN ride r ON u.id = r.ride_giver_id GROUP BY u.firstname HAVING COUNT(r.ride_id) > 1;
SELECT * FROM ride WHERE origin = 'Coimbatore' AND departure = '2025-03-07 05:15:02' AND available_seats > 0;
SELECT * FROM ride WHERE origin = 'Coimbatore' AND destination = 'Tirupur';
SELECT * FROM ride ORDER BY departure DESC LIMIT 1;
SELECT origin, destination, COUNT(*) AS frequency FROM ride GROUP BY origin, destination ORDER BY frequency DESC;
SELECT * FROM ride WHERE strftime('%H:%M:%S', departure) BETWEEN '03:00:00' AND '09:00:00';
