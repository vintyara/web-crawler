class WelcomeController < ApplicationController
  def index
  end

  def grub_url
    redirect_to :root unless valid_url

  end

  private

  def valid_url
    is_valid = true
    is_valid = false if params[:url].blank?

    flash[:error] = 'Invalid URL' and return false unless is_valid
    true
  end
end
