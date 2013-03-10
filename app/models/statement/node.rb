# -*- encoding : utf-8 -*-
class Node < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :improvements, dependent: :destroy
  has_many :pro_arguments, dependent: :destroy
  has_many :contra_arguments, dependent: :destroy
  has_many :background_infos, dependent: :destroy

  def destroy
    super unless %w(questions proposals improvements pro_arguments contra_arguments background_infos).any? { |a| self.send(a).count > 0 }
  end
end