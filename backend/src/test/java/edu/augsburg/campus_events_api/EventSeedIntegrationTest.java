package edu.augsburg.campus_events_api;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class EventSeedIntegrationTest {

    @Autowired
    private EventController eventController;

    @Test
    void returnsAllOneHundredSeededEvents() {
        assertEquals(100, eventController.getEvents().size());
    }
}
