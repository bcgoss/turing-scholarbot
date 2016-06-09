class EnrollmentsManager

  def initialize(course_ids, student)
    @course_ids = course_ids
    @student    = student
    set_enrollments
  end

  def create
    if set_enrollments.all? { |enrollment| enrollment.save }
      send_enrollment_email
      set_courses_to_active
    end
  end

  def send_enrollment_email
    EnrollmentMailer.deliver_confirmation_email_for(@student) # **** THIS IS NOT REAL! ****
  end

  private

  def set_courses_to_active
    @student.courses.each do |course|
      course.update_attributes(active: true)
    end
  end

  def set_enrollments
    @course_ids.collect do |id|
      @student.enrollments.new(course_id: id, score: 100)
    end
  end
end
