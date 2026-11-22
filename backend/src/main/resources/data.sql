INSERT INTO locations (location_id, name, facility, capacity) VALUES
  (1, 'Hoversten Chapel', 'Foss Center', 400),
  (2, 'Sverdrup Hall', 'Academic Center', 220),
  (3, 'Mullin Hall Gym', 'Student Activities Center', 500);

INSERT INTO events (event_id, title, description, category, start_time, end_time, location_id, organizer) VALUES
  (1, 'Induction Hall of Fame', 'Event that celebrates athletes at Augsburg', 'Sports', '2026-11-14 10:00:00', '2026-11-14 11:30:00', 1, 'Augsburg Athletic Department'),
  (2, 'Campus Career Fair', 'Meet employers and learn about internships and jobs', 'Career', '2026-11-18 12:00:00', '2026-11-18 15:00:00', 2, 'Career Services'),
  (3, 'Open Mic Night', 'Student performances, music, poetry, and comedy', 'Arts', '2026-12-02 18:30:00', '2026-12-02 21:00:00', 3, 'Student Activities Board');
