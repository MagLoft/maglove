class Powersnap
  attr_accessor :urls, :prefix

  def initialize(urls, prefix: nil)
    @urls = urls.map { |url| URI.encode(url) }
    @prefix = prefix
  end

  def generate(dir: ".", width: 768, height: 1024, pattern: "image-{index}.png", zoom: 1.0, page: false, quality: 100, css: nil)
    extension = File.extname(pattern)
    if extension == ".jpg"
      format = "jpeg"
    elsif extension == ".png"
      format = "png"
    else
      raise "Invalid file extension: #{extension}"
    end
    cmd = "#{@prefix} powersnap -j -d \"#{dir}\" -t \"#{format}\" -q #{quality} -z #{zoom} #{page ? '--page' : ''} -w #{width.to_i} -h #{height.to_i} #{(css and "-c #{css}")} -f \"#{pattern}\" #{@urls.join(' ')}"
    json_response = `#{cmd}`

    response = JSON.parse(json_response)
    return response["stats"] == "success"
  end
end
