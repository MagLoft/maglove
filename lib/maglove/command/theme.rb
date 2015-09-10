module MagLove
  module Command
    class Theme
      include Commander::Methods
      
      def run

        task :compile, theme: ENV["THEME"], sync: "NO", bucket: "localhost:3002" do |args, options|
          info("▸ compiling theme #{options.theme}")
          invoke_tasks(["core:validate", "core:clean", "compile:coffee", "compile:less", "compile:yaml", "compile:templates", "copy:base_images", "copy:images", "copy:thumbs", "compress:theme"], options)
          
          if options.sync == "YES"
            error!("▸ SYNC error: please specify a bucket to use (cdn.magloft.com, test-cdn.magloft.com)") if options.bucket == "localhost:3001"
            invoke_task("sync:cdn", options)
          end
        end
        
        task :deploy, theme: ENV["THEME"], out: ".", sync: "NO", bucket: "localhost:3002" do |args, options|
          
          # Compile Theme
          invoke_task("theme:compile", options)
          
          # Prepare Deployment Directory
          output_path = File.expand_path(options.out)
          error!("Directory '#{output_path}' does not exist!") if !File.directory?(output_path)
          target_path = File.join(output_path, options.theme)
          FileUtils.rm_r(target_path) if File.directory?(target_path)
          FileUtils.mkdir_p(File.join(target_path, "themes"))
          
          # Copy Assets
          FileUtils.cp_r(theme_dist_path(nil, options.theme), File.join(target_path, "themes/#{options.theme}"))
          FileUtils.cp_r(File.join("dist", "fonts"), File.join(target_path, "fonts"))
          
          # Process Templates
          templates = theme_config(:templates, options.theme)
          templates.each do |template|
            debug "▸ processing template #{template}"
            
            # Render template
            variables_yaml = theme_contents("templates/#{template}.yml", options.theme)
            variables = variables_yaml ? YAML.load(variables_yaml).with_indifferent_access : {}
            variables[:theme] = options.theme
            template_file = theme_glob("templates/#{template}.{html,twig,haml}", options.theme).first
            if !template_file.nil?
              asset = MagLove::Asset::Theme.new(template_file, options.theme, variables)
              contents = asset.contents
            else
              contents = "<p style='text-align: center; margin-top: 12px;'>ERROR: Template '#{template}' not found!</p>"
            end
            
            # Render Static Dump
            haml_contents = File.read(File.join(Gem.datadir("maglove"), "dump.haml"))
            html_contents = Hamloft.render(haml_contents, theme: options.theme, contents: contents, templates: templates, template: template)            
            
            # Write to file
            File.open(File.join(target_path, "#{template}.html"), "w") {|f| f.write(html_contents) }
          end


        end
        
        task :"compile-all", sync: "NO", bucket: "localhost:3002" do |args, options|
          themes = Dir.chdir("src/themes") { Dir.glob("*") }
          themes.each do |theme|  
            options.theme = theme
            invoke_task("theme:compile", options)
          end
        end
        
        task :thumbnails, theme: ENV["THEME"] do |args, options|
          info("▸ Starting Server")
          Thread.new do
            MagLove::Server.new(options.theme, 3000).run!
          end
          sleep 1
          
          info("▸ Generating thumbnails for theme '#{options.theme}'")
          
          templates = theme_config(:templates, options.theme)
          templates.each do |template|
            debug "▸ processing template #{template}"
            
            variables = {}
            variables_yaml = theme_contents("templates/#{template}.yml", options.theme)
            variables = YAML.load(variables_yaml).with_indifferent_access if variables_yaml
            variables[:theme] = options.theme
          
            # Render template
            template_file = theme_glob("templates/#{template}.{html,twig,haml}", options.theme).first
            if !template_file.nil?
              asset = MagLove::Asset::Theme.new(template_file, options.theme, variables)
              contents = asset.contents
            else
              contents = "<p style='text-align: center; margin-top: 12px;'>ERROR: Template '#{template}' not found!</p>"
            end
          
            # Render thumbnail html
            haml_contents = File.read(File.join(Gem.datadir("maglove"), "thumbnail.haml"))
            html = Hamloft.render(haml_contents, theme: options.theme, contents: contents)
            
            # Create thumbnail image
            script = PhantomScript.new('thumbnail')
            html_base64 = Base64.strict_encode64(html)
            contents = script.run(html_base64, "png", "480", "640", "1")
            theme_write_contents("thumbs/#{template}.png", contents, options.theme)
            
            # Optimize thumbnail image
            info("▸ Optimize image")
            begin
              image_optim = ImageOptim.new(pngout: false, svgo: false)
              image_optim.optimize_image!(theme_path("thumbs/#{template}.png", options.theme))
            rescue Exception => e
              error(e.message)
              error!("Missing image optimization binaries. Install via: gem install image_optim_pack")
            end
            
          end
          
        end
        
        task :init, theme: ENV["THEME"], base_version: "v1" do |args, options|
          # validate theme
          error! "no theme specified" if !options.theme
          error! "theme #{options.theme} already exists" if File.directory?("src/themes/#{options.theme}")
          debug("theme: #{options.theme}")
          debug("environment: #{options.production ? 'production' : 'development'}")
          
          # collect variables
          base_scaffold_dir = File.join(Gem.datadir("maglove"), "scaffold/base")
          base_target_dir = "src/base/#{options.base_version}"
          theme_scaffold_dir = File.join(Gem.datadir("maglove"), "scaffold/theme")
          theme_target_dir = "src/themes/#{options.theme}"
          
          # create base repository
          if !File.directory?(base_target_dir)
            FileUtils.mkdir_p("src/base")
            FileUtils.cp_r(base_scaffold_dir, base_target_dir)
            info("▸ created base theme in '#{base_target_dir}'")
          end
          
          # create theme repository
          FileUtils.mkdir_p("src/themes")
          FileUtils.cp_r(theme_scaffold_dir, theme_target_dir)
          
          # create yaml file
          yaml_contents = {
            "name" => options.theme.titlecase,
            "base_version" => options.base_version,
            "identifier" => options.theme,
            "description" => "#{options.theme.titlecase} theme created with MagLove",
            "templates" => ['cover', 'toc', 'article-01']
          }
          theme_write_contents("theme.yml", yaml_contents.to_yaml.gsub("---\n", ''), options.theme)
          info("▸ created #{options.theme} theme in '#{theme_target_dir}'")
        end
        
        task :dev, theme: ENV["THEME"] do |args, options|
          options.production = false
          invoke_task("theme:compile", options)
          invoke_task("font:compile", options)
          options.block = "NO"
          invoke_task("util:watch", options)
          
          # browser sync
          options.files = "dist/themes/#{options.theme}/*.css, dist/themes/#{options.theme}/*.js, dist/themes/#{options.theme}/templates/*.html, dist/themes/#{options.theme}/images/**/*"
          options.start_path = theme_config(:templates, options.theme).first
          invoke_task("util:browser_sync", options)
          
          invoke_task("server:run", options)
        end

      end
    end
  end
end
