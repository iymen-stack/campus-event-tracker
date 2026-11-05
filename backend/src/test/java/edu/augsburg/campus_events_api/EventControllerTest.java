package edu.augsburg.campus_events_api;

import java.time.LocalDateTime;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(EventController.class)
class EventControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JdbcTemplate jdbcTemplate;

    @Test
    void rejectsEndTimeBeforeStartTime() throws Exception {
        mockMvc.perform(post("/api/events")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "title": "Coding Night",
                      "category": "Academic",
                      "locationId": 8,
                      "startTime": "2026-11-05T17:00:00",
                      "endTime": "2026-11-05T15:00:00"
                    }
                    """))
                .andExpect(status().isBadRequest());

        verifyNoInsert();
    }

    @Test
    void rejectsEqualStartAndEndTime() throws Exception {
        mockMvc.perform(post("/api/events")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "title": "Coding Night",
                      "locationId": 8,
                      "startTime": "2026-11-05T17:00:00",
                      "endTime": "2026-11-05T17:00:00"
                    }
                    """))
                .andExpect(status().isBadRequest());

        verifyNoInsert();
    }

    @Test
    void rejectsBlankTitle() throws Exception {
        mockMvc.perform(post("/api/events")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "title": "   ",
                      "locationId": 8,
                      "startTime": "2026-11-05T17:00:00",
                      "endTime": "2026-11-05T19:00:00"
                    }
                    """))
                .andExpect(status().isBadRequest());

        verifyNoInsert();
    }

    @Test
    void rejectsMissingStartTimeWithoutCrashing() throws Exception {
        mockMvc.perform(post("/api/events")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "title": "Coding Night",
                      "locationId": 8,
                      "endTime": "2026-11-05T19:00:00"
                    }
                    """))
                .andExpect(status().isBadRequest());

        verifyNoInsert();
    }

    @Test
    void validEventCallsInsertAndReturnsCreated() throws Exception {
        when(jdbcTemplate.update(anyString(), any(), any(), any(), any(), any()))
                .thenReturn(1);

        mockMvc.perform(post("/api/events")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                      "title": "Coding Night",
                      "category": "Academic",
                      "locationId": 8,
                      "startTime": "2026-11-05T17:00:00",
                      "endTime": "2026-11-05T19:00:00"
                    }
                    """))
                .andExpect(status().isCreated());

        verify(jdbcTemplate).update(
                anyString(),
                eq(8),
                eq("Coding Night"),
                eq("Academic"),
                eq(LocalDateTime.parse("2026-11-05T17:00:00")),
                eq(LocalDateTime.parse("2026-11-05T19:00:00"))
        );
    }

    private void verifyNoInsert() {
        verify(jdbcTemplate, never()).update(anyString(), any(), any(), any(), any(), any());
    }
}
