package edu.augsburg.campus_events_api;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.jdbc.core.JdbcTemplate;

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
                    l.name AS location_name
                FROM events AS e
                LEFT JOIN locations AS l
                    ON e.location_id = l.location_id;
                """;

        return jdbcTemplate.queryForList(sqlQuery);
    }
}