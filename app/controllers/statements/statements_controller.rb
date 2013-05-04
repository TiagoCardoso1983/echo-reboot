class Statements::StatementsController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!, except: [:index, :show]


  before_filter :fetch_statement, only: [:show, :edit, :update, :destroy]
  before_filter :new_statement, only: [:new, :create]
  before_filter :read_permission, only: [:show]
  before_filter :write_permission, only: [:edit, :update, :destroy]


  def index

  end

  def show
    @document = @statement.node.current_document
    render
  end

  def new
    @document = @statement.node.new_document
    render
  end

  def edit
    @document = @statement.node.new_document
    render
  end

  def create
    @statement.assign_attributes(params[:statement])
    # set document author
    @statement.node.documents.each{|d| d.author = current_user }
    flash[:notice] = I18n.t("discuss.messages.created", type: @statement.class.model_name.human) if @statement.save
    respond_with(@statement)
  end

  def update
    @statement.assign_attributes(params[:statement])
    @document = @statement.node.documents.last
    if @document.new_record?
      @document.author = current_user
    else
      @document = @statement.node.current_document
    end
    flash[:notice] = I18n.t("discuss.messages.updated", type: @statement.class.model_name.human) if @statement.save
    respond_with(@statement)
  end

  def destroy
    @statement.destroy
    flash[:notice] = I18n.t("discuss.messages.deleted", type: @statement.class.model_name.human) if @statement.destroyed?
    respond_with(@statement)
  end

  private

  def read_permission
    return true if @statement.node.published?
    write_permission
  end

  def write_permission
    return false unless current_user.present? and  @statement.node.authors.by_language.include?(current_user)
    return true
  end

end
