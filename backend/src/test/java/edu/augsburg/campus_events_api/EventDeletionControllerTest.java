package edu.augsburg.campus_events_api;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.when;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(EventDeletionController.class)
class EventDeletionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JdbcTemplate jdbcTemplate;

    @Test
    void deleteExistingEventReturnsNoContent() throws Exception {

        String sql = "DELETE FROM events WHERE event_id = ?";

        when(jdbcTemplate.update(sql, 42))
                .thenReturn(1);

        mockMvc.perform(delete("/api/events/42"))
                .andExpect(status().isNoContent());

        verify(jdbcTemplate).update(sql, 42);
    }

    @Test
    void deleteMissingEventReturnsNotFound() throws Exception {

        String sql = "DELETE FROM events WHERE event_id = ?";

        when(jdbcTemplate.update(sql, 999999))
                .thenReturn(0);

        mockMvc.perform(delete("/api/events/999999"))
                .andExpect(status().isNotFound());

        verify(jdbcTemplate).update(sql, 999999);
    }

    @Test
    void deleteNegativeEventIdReturnsBadRequest() throws Exception {

        mockMvc.perform(delete("/api/events/-5"))
                .andExpect(status().isBadRequest());

        verifyNoInteractions(jdbcTemplate);
    }

    @Test
    void deleteNonNumericEventIdReturnsBadRequest() throws Exception {

        mockMvc.perform(delete("/api/events/abc"))
                .andExpect(status().isBadRequest());

        verifyNoInteractions(jdbcTemplate);
    }
}