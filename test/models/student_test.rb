require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  test "enrollment code is generated when saved in database" do
    student = Student.create(name: "Gertrude")

    assert_equal 7, student.registration_code.length
    assert student.registration_code.match(/\A[a-zA-Z0-9]+\z/)
  end
end
