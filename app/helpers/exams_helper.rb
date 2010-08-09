module ExamsHelper
  def print_course_exams(course)
    course == nil ? "" : "#{course.course_abbr} - #{course.exams.length} exam(s)"
  end

  def get_max_length(array1, array2) #TODO there's got to be a method for this...
    if array1.nil? || array2.nil?
      0
    else
      array1.length > array2.length ? array1.length : array2.length
    end
  end
end
