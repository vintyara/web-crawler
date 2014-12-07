class WelcomeController < ApplicationController

  require 'crawler'

  def index
  end

  def grub_url
    redirect_to :root unless valid_url
    c = Crawler.new(params[:url], params[:output_format])
    c.process

    flash[:info] = 'Successfully'
    redirect_to :root
  end

  private

  def valid_url
    is_valid = true
    is_valid = false if params[:url].blank?

    flash[:error] = 'Invalid URL' and return false unless is_valid
    true
  end
end
