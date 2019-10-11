# frozen_string_literal: true

require 'test_helper'

class TimeSlotsTest < ActiveSupport::TestCase
  setup do
    @opening = Event.create kind: 'opening', starts_at: DateTime.parse('2019-10-04 09:30'), ends_at: DateTime.parse('2019-10-04 12:30'), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse('2019-10-09 11:30'), ends_at: DateTime.parse('2019-10-09 12:30')
    @date = DateTime.parse('2019-10-09')
    @timeslots = Managers::TimeSlots.new(@date, 7)
  end

  test 'test the call action' do
    timeslots = @timeslots.call
    assert_equal Array, timeslots.class
    assert_equal Hash, timeslots.first.class
    assert_equal DateTime, DateTime.parse(timeslots[0][:date]).class
    assert_equal ['09:30', '10:00', '10:30', '11:00'], timeslots[0][:slots]
  end

  test 'reserved time slots' do
    assert_equal [{ date: '2019/10/09', slots: ['11:30', '12:00'] }], @timeslots.reserved_time_slots
  end

  test 'extract slots' do
    reserved_slots = [{ date: '2019/10/09', slots: ['11:30', '12:00'] }]
    all_slots = [{ date: '2019/10/09', slots: ['09:30', '10:00', '10:30', '11:00', '11:30', '12:00'] }]
    result = [{ date: '2019/10/09', slots: ['09:30', '10:00', '10:30', '11:00'] }]
    assert_equal result, @timeslots.extract_available_slots(reserved_slots, all_slots)
  end

  test 'slots range' do
    assert_equal ['09:30', '10:00', '10:30', '11:00', '11:30', '12:00'], @timeslots.slots_range(@opening)
  end

  test 'slots bucket' do
    slots = ['09:30', '10:00', '10:30', '11:00', '11:30', '12:00']
    r2 = { date: '2019/10/15', slots: [] }
    r1 = { date: '2019/10/09', slots: ['09:30', '10:00', '10:30', '11:00', '11:30', '12:00'] }
    assert_equal r1, @timeslots.slots_bucket(@date, slots).first
    assert_equal r2, @timeslots.slots_bucket(@date, slots).last
  end

  test 'daily bucket slots' do
    r1 = { date: '2019/10/04', slots: ['09:30', '10:00', '10:30', '11:00', '11:30', '12:00'] }
    slots_range = ['09:30', '10:00', '10:30', '11:00', '11:30', '12:00']
    assert_equal r1, @timeslots.daily_slot_bucket(@opening.starts_at, slots_range)
  end
end
