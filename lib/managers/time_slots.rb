# frozen_string_literal: true

module Managers
  class TimeSlots
    OFF_DAYS = %w[Saturday Sunday Tuesday].freeze

    def initialize(date, next_x_days, time_interval = 30)
      @date = date
      @next_x_days = next_x_days
      @time_interval = time_interval
    end

    def call
      open_slots = slots_range(latest_opening)
      slots = slots_bucket(@date, open_slots)
      # byebug
      extract_available_slots(reserved_time_slots, slots)
    end

    def reserved_time_slots
      reserved_slots = []
      appointments.each do |e|
        reserved_slots << daily_slot_bucket(e.starts_at, slots_range(e))
      end
      reserved_slots
    end

    def slots_range(e)
      slots = []
      slot_interval = e.starts_at
      partitions = ((e.ends_at - e.starts_at).to_i / 60) / @time_interval
      1.upto(partitions) do |_i|
        slots << slot_interval
        slot_interval += @time_interval.minutes
      end

      slots.map { |x| x.strftime('%H:%M') }
      end

    def slots_bucket(date, open_slots)
      aslots = []
      event_date = date
      1.upto(7) do |_i|
        aslots << daily_slot_bucket(event_date, open_slots)
        event_date += 1.day
      end
      aslots
      end

    def daily_slot_bucket(event_date, slots)
      slots = [] if OFF_DAYS.include?(event_date.strftime('%A'))
      { date: extract_date(event_date), slots: slots }
      end

    def extract_available_slots(rsrved_slots, aslots)
      rsrved_slots.each do |rs|
        sindate = aslots.select { |s| s[:date] == rs[:date] }.first
        sindate[:slots] = sindate[:slots] - rs[:slots]
        aslots.delete_if { |s| s[:date] == rs[:date] }
        aslots << sindate
      end
      aslots.sort_by { |hsh| hsh[:date] }
      end

    def extract_date(d)
      d.strftime('%Y/%m/%d')
    end

    private

    def appointments
      Event.where(kind: 'appointment', starts_at: @date.beginning_of_day..@date.end_of_day + @next_x_days.days)
    end

    def latest_opening
      Event.where(kind: 'opening', weekly_recurring: true).last
    end
  end
end
