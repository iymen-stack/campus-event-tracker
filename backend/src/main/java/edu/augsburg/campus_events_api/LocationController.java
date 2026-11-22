package edu.augsburg.campus_events_api;

import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LocationController {

    private final JdbcTemplate jdbcTemplate;

    public LocationController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/api/locations")
    public List<Map<String, Object>> getLocations() {
        String sql = """
                SELECT location_id, name
                FROM locations
                ORDER BY name
                """;

        return jdbcTemplate.queryForList(sql).stream()
                .map(this::normalizeKeys)
                .toList();
    }

    private Map<String, Object> normalizeKeys(Map<String, Object> row) {
        Map<String, Object> normalized = new LinkedHashMap<>();
        row.forEach((key, value) -> normalized.put(key.toLowerCase(), value));
        return normalized;
    }
}
