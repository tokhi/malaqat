require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal '2014/08/10', availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["09:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    # I assume Tuesdays are off
    assert_equal [], availabilities[2][:slots]
    assert_equal '2014/08/16', availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "another simple test example2" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2019-10-04 09:30"), ends_at: DateTime.parse("2019-10-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2019-10-09 11:30"), ends_at: DateTime.parse("2019-10-09 12:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2019-10-10 10:30"), ends_at: DateTime.parse("2019-10-10 11:30")   
    availabilities = Event.availabilities DateTime.parse("2019-10-09")
    assert_equal '2019/10/09', availabilities[0][:date]
    assert_equal ["09:30", "10:00", "10:30", "11:00"], availabilities[0][:slots]
    assert_equal '2019/10/10', availabilities[1][:date]
    assert_equal ["09:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[3][:slots]
    assert_equal '2019/10/15', availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

end
