class Program < ApplicationRecord
  has_many :enrollments

  scope :favorites, ->{ merge(Enrollment.favorites) }
end
