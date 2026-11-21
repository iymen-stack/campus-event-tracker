package edu.augsburg.campus_events_api;

import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class EventDeletionController {

    private final JdbcTemplate jdbcTemplate;

    public EventDeletionController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @DeleteMapping("/api/events/{id}")
    public ResponseEntity<Void> deleteEvent(@PathVariable int id) {

        if (id <= 0) {
            return ResponseEntity.badRequest().build();
        }

        String sql = "DELETE FROM events WHERE event_id = ?";

        int rowsDeleted = jdbcTemplate.update(sql, id);

        if (rowsDeleted == 0) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.noContent().build();
    }
}