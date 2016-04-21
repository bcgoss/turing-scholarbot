require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test "filter by active status" do
    science = Course.create(subject: "Science", active: true)
    history = Course.create(subject: "History", active: false)
    math    = Course.create(subject: "Math", active: true)

    assert_equal [science, math], Course.active
  end

  test "filter by created at date" do
    science = Course.create(subject: "Science", created_at: "2016-03-01 01:59:15")
    math    = Course.create(subject: "Math", created_at: "2016-01-01 01:59:15")
    history = Course.create(subject: "History", created_at: "2016-02-01 01:59:15")

    assert_equal [math], Course.created_before("2016-01-02 01:59:15")
  end
end
