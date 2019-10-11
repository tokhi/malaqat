# frozen_string_literal: true

class Event < ApplicationRecord
	
  def self.availabilities(date, next_x_days = 7)
    Managers::TimeSlots.new(date, next_x_days).call
  end
end
