# -*- encoding : utf-8 -*-
class Node < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :improvements, dependent: :destroy
  has_many :pro_arguments, dependent: :destroy
  has_many :contra_arguments, dependent: :destroy

  has_many :documents, inverse_of: :node, dependent: :destroy
  has_many :authors, through: :documents do
    def by_language(locale=I18n.locale)
      where(Document.arel_table[:language_code].eq(locale))
    end
  end


  has_enumerated :editorial_state, class_name: "StatementState"

  mount_uploader :image, StatementImageUploader

  acts_as_taggable :topics

  validates :documents, collection_emptiness: true

  def editorial_state
    @editorial_state ||= StatementState[editorial_state_code]
  end

  delegate :published?, to: :editorial_state
  def publish ; self.editorial_state = StatementState[:published] ; end
  def publish! ; publish ; save ; end


  # documents
  def new_document(locale=I18n.locale)
    doc = current_document(locale)
    doc.nil? ? documents.build(language_code: locale) : doc.dup
  end
  def current_documents
    @current_documents ||= documents.where(current: true)
  end
  def current_document(locale=I18n.locale)
    current_documents.where(language_code: locale).first
  end
  def original_document
    documents.where(previous_document_id: nil).first
  end
  def original_language
    original_document.language
  end

  # authors



  # form_handlers
  def document=(ar_attrs)
    ar_attrs.is_a?(Hash) ? documents.build(ar_attrs) : super
  end

  def destroy
    super unless %w(questions proposals improvements pro_arguments contra_arguments).any? { |a| self.send(a).count > 0 }
  end
end