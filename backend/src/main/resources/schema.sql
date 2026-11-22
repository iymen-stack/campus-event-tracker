CREATE TABLE IF NOT EXISTS locations (
  location_id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  facility VARCHAR(100),
  capacity INT
);

CREATE TABLE IF NOT EXISTS events (
  event_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  description TEXT,
  category VARCHAR(50),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  location_id INT,
  organizer VARCHAR(100),
  CONSTRAINT fk_events_locations FOREIGN KEY (location_id) REFERENCES locations(location_id)
);
