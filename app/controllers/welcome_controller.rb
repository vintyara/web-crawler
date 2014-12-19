class WelcomeController < ApplicationController

  before_filter :validate_url, only: :grub_url

  include Web

  def index
  end

  def grub_url
    crawler = Web::Crawler.new(params[:url], output_format: params[:format])
    result = crawler.process

    respond_to do |format|
      format.pdf { send_data result, filename: 'result.pdf' }
      format.tgz { send_data result, filename: 'result.tgz' }
    end
  end

  private

  def validate_url
    is_valid = true
    is_valid = false if params[:url].blank?
    is_valid = false unless params[:url].match(/^(http|https):*/)

    flash[:error] = 'Invalid URL' and redirect_to(:root) unless is_valid
  end
end
