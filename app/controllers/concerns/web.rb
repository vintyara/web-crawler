module Web
  extend ActiveSupport::Concern

  class Crawler
    require 'open-uri'
    require 'rubygems/package'
    require 'zlib'

    require 'archive/tar/minitar'
    include Archive::Tar

    def initialize(url, output_format: :tgz, max_depth: 0)
      @url = url
      @output_format  = output_format
      @max_depth      = max_depth
      @tmp_dir_name   = URI(@url).host
      @working_dir    = File.join(Rails.root, 'tmp', @tmp_dir_name)
      @html           = nil
    end

    def process
      save_html
      send("make_#{@output_format}".to_sym)
    end

    private

    def make_pdf
      #kit = PDFKit.new(@html.to_s, :page_size => 'A4')
      #Dir["#{@working_dir}/css/*"].each { |css_file| kit.stylesheets << css_file }

      kit = PDFKit.new(@url, :page_size => 'A4')
      kit.to_pdf
    end

    def make_tgz
      tgz = Zlib::GzipWriter.new(File.open("#{@tmp_dir_name}.tgz", 'wb'))
      Minitar.pack(@working_dir, tgz)
    end

    def save_html(with_css: true, with_images: true)
      Dir.mkdir(@working_dir) unless Dir.exist?(@working_dir)

      @html = Nokogiri::HTML(open(@url))

      save_additionals(:css) if with_css
      save_additionals(:img) if with_images

      File.open(File.join(@working_dir, 'index.html'), "w+") { |file| file.write @html.to_s }
    end

    def save_additionals(target_tag)
      target_dir = target_tag.to_s
      service_data = {
          img: { xpath: '//img', source: 'src' },
          css: { xpath: '/html/head/link[@rel="stylesheet"]', source: 'href' }
      }

      Dir.mkdir(File.join(@working_dir, target_dir)) unless Dir.exist?(File.join(@working_dir, target_dir))

      Net::HTTP.start(URI(@url).host, :read_timeout => 16) { |http|
        @html.xpath(service_data[target_tag][:xpath]).each do |html_tag|
          resp = http.get(html_tag.attr(service_data[target_tag][:source]))
          open(File.join(@working_dir, target_dir, (target_file_name = html_tag.attr(service_data[target_tag][:source]).split('/').last)), "wb") { |file|
            file.write(resp.body)
          }
          html_tag.attributes[service_data[target_tag][:source]].value = "#{target_dir}/#{target_file_name}"
        end
      }
    end
  end

end