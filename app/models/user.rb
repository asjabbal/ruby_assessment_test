class User < ApplicationRecord
  enum :kind, { student: 0, teacher: 1, teacher_student: 2 }

  has_many :student_enrollments, class_name: 'Enrollment', foreign_key: :user_id
  has_many :teacher_enrollments, class_name: 'Enrollment', foreign_key: :teacher_id
  has_many :teachers, through: :student_enrollments
  has_many :student_programs, ->{ distinct }, through: :student_enrollments, source: :program

  # favorites scope works with all above asociations
  # ex: user.teachers.favorites, user.student_enrollments.favorites, user.student_programs.favorites
  scope :favorites, ->{ merge(Enrollment.favorites) }

  validate :check_enrollment, on: :update, if: :kind_changed?

  def self.classmates(user)
    program_ids = user.student_programs.pluck(:id)
    classmate_ids = Enrollment.by_program_ids(program_ids)
                      .where.not(user_id: user.id)
                      .pluck(:user_id)
    where(id: classmate_ids)
  end

  private

  def check_enrollment
    if kind_was == 'student' && kind == 'teacher' && student_enrollments.exists?
      errors.add(:base, 'Kind can not be teacher because is studying in at least one program')
    elsif kind_was == 'teacher' && kind == 'student' && teacher_enrollments.exists?
      errors.add(:base, 'Kind can not be student because is teaching in at least one program')
    end
  end
end
