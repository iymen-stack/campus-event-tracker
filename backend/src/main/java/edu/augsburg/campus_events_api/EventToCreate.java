package edu.augsburg.campus_events_api;

import java.time.LocalDateTime;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.AssertTrue;

public record EventToCreate(
	@Size(max=150)
	@NotBlank
	String title,
	@Size(max = 50)
	String category,
	@Positive
	@NotNull Integer locationId,
	@NotNull LocalDateTime startTime,
	@NotNull LocalDateTime endTime
){
	@AssertTrue
	public boolean isValidTimeRange(){
		if (startTime == null || endTime ==null){
			return true;
		}
		return endTime.isAfter(startTime);
	}
}
