class Crawler
  require 'open-uri'

  def initialize(url, output_format = :tgz)
    @url = url
    @output_format  = output_format
    @working_dir    = File.join(Rails.root, 'tmp', url.gsub(/.+www.|.+\/\//, ''))
    @html           = nil
  end

  def process
    save_html
  end

  private

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

    Net::HTTP.start(URI(@url).host) { |http|
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