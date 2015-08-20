module MagLove
  module Command
    class Font
      include Commander::Methods
      
      def get_font_styles(font_id, variant, append_dir='')
        font_name = font_id.gsub('-', ' ').titleize
        case variant
        when "regular"
          "@font-face{font-family:'#{font_name}';src:url('#{append_dir}#{font_id}-#{variant}.ttf');}\n"
        when "bold"
          "@font-face{font-family:'#{font_name}';src:url('#{append_dir}#{font_id}-#{variant}.ttf');font-weight:bold;}\n"
        when "italic"
          "@font-face{font-family:'#{font_name}';src:url('#{append_dir}#{font_id}-#{variant}.ttf');font-style:italic;}\n"
        when "bolditalic"
          "@font-face{font-family:'#{font_name}';src:url('#{append_dir}#{font_id}-#{variant}.ttf');font-weight:bold;font-style:italic;}\n"
        when "light"
          "@font-face{font-family:'#{font_name}';src:url('#{append_dir}#{font_id}-#{variant}.ttf');font-weight:300;}\n"
        end
      end
      
      def run

        task :compile, bucket: "cdn.magloft.com", sync: "NO" do |args, options|
    
          # clean up
          FileUtils.rm_rf("dist/fonts")
          FileUtils.mkdir_p("dist/fonts")
    
          # 1: Build font map
          debug("▸ building font map")
          font_map = {}
          font_files = Dir.glob("src/fonts/*/*.ttf")
          font_files.each do |font_file|
            (root_dir, font_dir, font_id, font_filename) = font_file.split("/")
            font_variant = font_filename.gsub("#{font_id}-", '').gsub(".ttf", '')
            font_map[font_id] = [] if font_map[font_id].nil?
            font_map[font_id].push(font_variant)
          end
    
          # 2: Generate stylesheets
          debug("▸ compiling fonts:")
          FileUtils.touch("dist/fonts/fonts.css")
          open("dist/fonts/fonts.css", 'wb') do |master_file|
            font_map.each do |font_id, variants|
              debug("~▸ compiling font '#{font_id}'")
              
              # Create font directory
              FileUtils.mkdir_p("dist/fonts/#{font_id}")
              
              # Copy fonts
              variants.each do |variant|
                FileUtils.copy("src/fonts/#{font_id}/#{font_id}-#{variant}.ttf", "dist/fonts/#{font_id}/#{font_id}-#{variant}.ttf")
              end
              
              # Create stylesheet
              font_style_file = "dist/fonts/#{font_id}/font.css"
              FileUtils.touch(font_style_file)
              open(font_style_file, 'wb') do |file|
                master_file << "/* #{font_id} (#{variants.join(", ")}) */\n"
                variants.each do |variant|
                  file << get_font_styles(font_id, variant)
                  master_file << get_font_styles(font_id, variant, "#{font_id}/")
                end
                master_file << "\n"
              end
            end
          end
          debug("▸ all font styles created")
    
          if options.sync == "YES"
            system "gsutil -m rsync -d -r dist/fonts gs://#{options.bucket}/fonts"
            debug("▸ all fonts synchronized with bucket '#{options.bucket}'")
          end
        end

      end
    end
  end
end
