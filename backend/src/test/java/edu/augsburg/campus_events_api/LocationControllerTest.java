
package edu.augsburg.campus_events_api;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(LocationController.class)
class LocationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JdbcTemplate jdbcTemplate;

    @Test
    void getLocationsReturnsIdsAndNames() throws Exception {

        List<Map<String, Object>> locations = List.of(
                Map.of("location_id", 8, "name", "Hagfors Center"),
                Map.of("location_id", 11, "name", "Lindell Library"));

        when(jdbcTemplate.queryForList(anyString()))
                .thenReturn(locations);

        mockMvc.perform(get("/api/locations"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].location_id").value(8))
                .andExpect(jsonPath("$[0].name").value("Hagfors Center"))
                .andExpect(jsonPath("$[1].location_id").value(11));

        verify(jdbcTemplate).queryForList(
                argThat(sql -> sql.contains("FROM locations")
                        && sql.contains("ORDER BY name")));
    }

    @Test
    void getLocationsReturnsEmptyList() throws Exception {

        when(jdbcTemplate.queryForList(anyString()))
                .thenReturn(List.of());

        mockMvc.perform(get("/api/locations"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

}
