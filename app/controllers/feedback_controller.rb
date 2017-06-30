class FeedbackController < ApplicationController
  layout "pages"

  def new
  end

  def create
    FrontendMailer.new_feedback(params[:message], params[:name], params[:email]).deliver
  end
end
