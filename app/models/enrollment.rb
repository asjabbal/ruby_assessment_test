class Enrollment < ApplicationRecord
  belongs_to :user, foreign_key: :user_id
  belongs_to :teacher, foreign_key: :teacher_id, class_name: 'User'
  belongs_to :program

  scope :favorites, ->{ where(favorite: true) }
  scope :by_program_ids, ->(program_ids){ where(program_id: program_ids) }
end
