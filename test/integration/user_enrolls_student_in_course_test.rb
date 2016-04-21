require 'test_helper'

class UserEnrollsStudentInCourseTest < ActionDispatch::IntegrationTest
  test "initial course score is set and displayed" do
    science            = Course.create(subject: "Science")
    math               = Course.create(subject: "Math")
    history            = Course.create(subject: "History")
    student            = Student.create(name: "Gertrude")
    registration_code  = student.registration_code

    visit student_path(student)
    click_on "Add Course"
    check("course-#{science.id}")
    check("course-#{math.id}")
    click_on "Create Enrollment"

    assert_equal student_path(student), current_path
    within(".current-courses") do
      assert page.has_content?("Science: 100")
      assert page.has_content?("Math: 100")
    end

    refute page.has_content?("History")
  end
end
