-- MySQL dump 10.13  Distrib 26.7.0, for macos26.6 (arm64)
--
-- Host: localhost    Database: augsburg_events
-- ------------------------------------------------------
-- Server version	26.7.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '4cb567e0-c183-11f1-9adb-cdfa7e89325f:1-13';

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `event_id` int NOT NULL,
  `title` varchar(150) NOT NULL,
  `description` text,
  `category` varchar(50) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `location_id` int DEFAULT NULL,
  `organizer` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `events_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES (1,'Induction Hall of Fame','Event that celebrates athletes at Augsburg','Sports','2026-10-14 10:00:00','2026-10-14 11:30:00',1,'Augsburg Athletic Department'),(2,'Math_Competition','Augsburg math competition','Education','2026-10-13 04:30:00','2026-10-13 06:00:00',2,'Augsburg Math Department'),(3,'Augsburg Women\'s Volleyball Match vs Macalester','Volleyball match','Sports','2026-10-22 19:00:00','2026-10-22 21:00:00',8,'Augsburg Athletic Department'),(4,'Campus Cupboard','Campus food resource','Food Resource','2026-10-23 12:20:00','2026-10-23 17:00:00',5,'Augsburg University'),(5,'Augsburg Men\'s Ice Hockey vs Hamline University','Hockey game','Sports','2026-10-23 19:00:00','2026-10-23 21:00:00',9,'Augsburg Athletic Department'),(6,'Much Ado About Nothing Friday Movie Night','Movie night','Entertainment','2026-10-23 18:00:00','2026-10-23 21:00:00',7,'Much Ado About Nothing - Creative Team'),(7,'Augsburg Women\'s Ice Hockey vs St. Olaf','Hockey game','Sports','2026-10-24 15:00:00','2026-10-24 18:00:00',9,'Augsburg Athletic Department'),(8,'Psychological Thriller Movie Night','Event to watch a thriller movie','Entertainment','2026-10-26 19:00:00','2026-10-26 21:00:00',7,'Augsburg Psychological Association'),(9,'Francophone Meet-up','Event for people from Francophone countries','Misc','2026-10-27 15:30:00','2026-10-27 16:30:00',8,NULL),(10,'MSA Dawah Table','Event related to Islam','Religion','2026-10-28 11:00:00','2026-10-28 13:00:00',6,'MSA Dawah'),(11,'Living Stories Series Opener','A talk on commitment from different traditions','Religion','2026-10-28 12:00:00','2026-10-28 12:20:00',6,NULL),(12,'PAPM Spooky Night','Cookie decorating, fun activities, and free food and drinks','Entertainment','2026-10-28 16:00:00','2026-10-28 18:00:00',7,'Campus Life'),(13,'Book Club Third Meeting','Discussing the first half of the club\'s current book','Social','2026-10-28 17:00:00','2026-10-28 18:30:00',11,'Campus Life'),(14,'Augsburg Women\'s Soccer vs Macalester','Soccer game','Sports','2026-10-30 16:30:00','2026-10-30 18:30:00',3,'Augsburg Athletic Department'),(15,'Augsburg Men\'s Soccer vs Macalester','Soccer game','Sports','2026-10-30 19:00:00','2026-10-30 21:00:00',3,'Augsburg Athletic Department'),(16,'Augsburg Men\'s Football vs Carleton College','Football game','Sports','2026-10-31 12:00:00','2026-10-31 15:00:00',3,'Augsburg Athletic Department'),(17,'Augsburg Women\'s Volleyball vs St. Olaf','Volleyball game','Sports','2026-10-31 19:00:00','2026-10-31 21:00:00',10,'Augsburg Athletic Department'),(18,'Assessment Committee',NULL,'Social','2026-11-02 16:00:00','2026-11-02 17:00:00',8,NULL),(19,'Augsburg Women\'s Wrestling vs Luther College','Wrestling match','Sports','2026-11-04 19:00:00','2026-11-04 22:00:00',10,'Augsburg Athletic Department'),(20,'Daily Chapel: THRIVE Series: Daniel Hickox-Young','Chapel speaking','Religion','2026-11-04 12:00:00','2026-11-04 12:20:00',1,NULL),(21,'Business Career Fair','An event to meet different companies and find job opportunities','Social','2026-09-30 14:00:00','2026-09-30 16:00:00',8,NULL),(22,'Staff Senate: Food Truck Friday',NULL,'Staff Senate','2026-11-06 12:00:00','2026-11-06 13:00:00',6,'Staff Senate');
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `location_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `capacity` int DEFAULT NULL,
  PRIMARY KEY (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
INSERT INTO `locations` VALUES (1,'Hoversten Chapel',400),(2,'Your Location Name',100),(3,'Augsburg Turf Field',700),(4,'Anderson Music Hall',200),(5,'Anderson Residence Hall',600),(6,'Chirstensen Center',1000),(7,'Foss Center',500),(8,'Hagfors Center',1500),(9,'Ice Arena',300),(10,'Kennedy Center',250),(11,'Lindell Library',250),(12,'Luther Residence Hall',500),(13,'Memorial Hall',100),(14,'Mortensen Residence Hall',500),(15,'Old Main',250),(16,'Oren Gateway Center',250),(17,'Riverside Park Plaza',200),(18,'Science Hall',500),(19,'Si Melby Hall',200),(20,'Sverdrup Hall',250),(21,'Urness Tower',600);
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-21 21:24:33
