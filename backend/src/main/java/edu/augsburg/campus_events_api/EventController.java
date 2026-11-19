package edu.augsburg.campus_events_api;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDateTime;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import jakarta.validation.Valid;

@RestController
public class EventController {


    private final JdbcTemplate jdbcTemplate;


    public EventController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }


    @GetMapping("/api/events")
    public List<Map<String, Object>> getEvents() {

        String sqlQuery = """
                SELECT
                    e.event_id,
                    e.title,
                    e.category,
                    l.name AS location_name,
                    e.start_time,
                    e.end_time
                FROM events AS e
                LEFT JOIN locations AS l
                    ON e.location_id = l.location_id;
                """;

        return jdbcTemplate.queryForList(sqlQuery);
    }

	@PostMapping("/api/events")
	public ResponseEntity<Void> createEvents(@Valid @RequestBody EventToCreate eventToCreate){
		String title = eventToCreate.title();
		String category = eventToCreate.category();
		int locationId = eventToCreate.locationId();
		LocalDateTime startTime = eventToCreate.startTime();
		LocalDateTime endTime = eventToCreate.endTime();

		String sqlQuery = """
                insert into events(location_id,title,category,start_time,end_time) values(?,?,?,?,?)


                """;
		jdbcTemplate.update(sqlQuery,locationId,title,category,startTime,endTime);
		return ResponseEntity.status(HttpStatus.CREATED).build();
	}
}