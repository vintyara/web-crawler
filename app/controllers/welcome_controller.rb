class WelcomeController < ApplicationController

  require 'crawler'

  before_filter :validate_url, only: :grub_url

  def index
  end

  def grub_url
    crawler = Crawler.new(params[:url], params[:output_format])
    result = crawler.process

    respond_to do |format|
      format.pdf { send_data result, filename: 'result.pdf' }
      format.tgz { raise 'to be continued' }
    end
  end

  private

  def validate_url
    is_valid = true
    is_valid = false if params[:url].blank?

    flash[:error] = 'Invalid URL' and redirect_to(:root) unless is_valid
  end
end
