package edu.augsburg.campus_events_api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

// A context smoke test should not require every developer to have a live MySQL server.
// Database connectivity and SQL correctness need separate integration tests.
@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration"
})
class CampusEventsApiApplicationTests {

    @MockitoBean
    private JdbcTemplate jdbcTemplate;

    @Test
    void contextLoads() {
        // Spring should initialize the application with a mocked JDBC boundary.
    }
}
