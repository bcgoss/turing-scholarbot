require 'test_helper'

class UserEnrollsStudentInCourseTest < ActionDispatch::IntegrationTest
  test "initial course score is set and displayed" do
    course            = Course.create(name: "Science")
    student           = Student.create(name: "Gertrude")
    registration_code = student.registration_code

    visit student_path(student)
    click_on "Add Course"
    select "Science", from: "course[name]"
    click_on "Create Enrollment"

    assert_equal student_path(student), current_path
    within(".current-courses") do
      assert page.has_content?("Science: 100")
    end
  end
end
