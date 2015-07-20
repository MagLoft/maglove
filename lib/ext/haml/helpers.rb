module Haml::Helpers

  # styles
  def asset(url)
    "#{Haml::Options.defaults[:asset_uri]}/#{url}"
  end

  def link(href, referrer="Baker", &block)
    if referrer and not referrer.empty? and not href.include?("referrer=")
      href = "#{href}#{href.include?("?") ? "&" : "?"}referrer=#{referrer}"
    end
    haml_tag :a, :href => href do
      block.call if block
    end    
  end
  # <a href="http://www.google.com/?referrer=Baker" class="">

  def font(font_face, &block)
    haml_tag :font, :face => font_face do
      block.call if block
    end
  end

  def style(*args, &block)
    style = nil
    if args[-1].class.name == "Hash"
      style_options = args.pop
      style = Haml::StyleBuilder.new(style_options, style_options.keys).process
    end
    
    classes = args.map{|a| "__#{a}"}
    haml_tag :span, :class => classes.join(" "), :style => style do
      block.call if block
    end    
  end

  # drop container

  def drop_container
    haml_tag :div, :class => "_typeloft_widget_drop_container"
  end
  
  # widgets

  def widget_block(widget, &block)
    haml_tag :div, widget.typeloft_widget_options do
      block.call(widget) if block
    end
  end

  def column(row, &block)
    # get and increase span
    next_span = row.next_span
    if next_span
      haml_tag :div, :class => "column col-#{row.options[:collapse_options]}-#{next_span}" do
        block.call if block
        drop_container
      end
    else
      haml_tag :pre do
        haml_concat "ERROR: Row does not allow column at position #{row.column_count}"
      end
    end
  end

  def columns_widget(options={}, &block)
    widget_block(Columns.new(options)) do |widget|
      haml_tag :div, widget.row_options do
        block.call(widget) if block
      end
    end
  end

  def container_widget(options={}, &block)
    widget_block(Container.new(options)) do |widget|
      haml_tag :section, widget.container_options do
        haml_tag :div, widget.image_options do
          block.call if block
          drop_container
        end
      end
    end
  end
  
  def banner_widget(options={}, &block)
    widget_block(Banner.new(options)) do |widget|
      haml_tag :div, :class => "banner-outer align-#{widget.options[:alignment]}" do
        haml_tag :div, :class => "banner banner-#{widget.options[:style]}" do
          block.call if block
          drop_container
        end
      end
    end
  end
  
  def youtube_widget(options={}, &block)
    widget_block(Youtube.new(options)) do |widget|
      haml_tag :div, :class => "flex-video widescreen", :style => "margin: 0 auto; text-align: center;" do
        haml_tag :iframe, :src => "http://www.youtube.com/embed/#{widget.options[:youtube_id]}", :type => "text/html", :width => widget.options[:width], :height => widget.options[:height], :style => "max-width: 100%; position: absolute; top: 0px; left: 0px; width: 100%; height: 100%;", :allowfullscreen => "", :frameborder => "0", :webkitallowfullscreen => "", :mozallowfullscreen => ""
      end
    end
  end
  
  def image_widget_link(options={})
    widget_block(Image.new(options)) do |widget|
      haml_tag :div, :class => "image-widget" do
        link options[:href] do
          haml_tag :img, :style => "margin-bottom: #{widget.options[:margin_bottom]}", :class => "image #{widget.options[:style]} #{widget.options[:magnify] ? "magnific-image" : ""}", :src => widget.options[:source]
        end
        haml_tag :div, :class => "image-drop-target"
      end
    end
  end

  def horizontal_rule_widget(options={})
    widget_block(HorizontalRule.new(options)) do |widget|
      haml_tag :hr, :class => widget.options[:style]
    end
  end

  def image_widget(options={})
    widget_block(Image.new(options)) do |widget|
      haml_tag :div, :class => "image-widget" do
        haml_tag :img, :style => "margin-bottom: #{widget.options[:margin_bottom]}", :class => "image #{widget.options[:style]} #{widget.options[:magnify] ? "magnific-image" : ""}", :src => widget.options[:source]
        haml_tag :div, :class => "image-drop-target"
      end
    end
  end
  
  def heading_widget(options={}, contents=nil, &block)
    if options.class.name == "String"
      contents = options
      options = {}
    end
    widget_block(Heading.new(options)) do |widget|
      haml_tag :header, :class => "#{widget.options[:style]} align-#{widget.options[:align]}" do
        haml_tag widget.options[:type], :class => "_typeloft_editable _typeloft_widget_autoselect" do
          haml_concat(contents) if contents
          block.call if block
        end
      end
    end
  end
  
  def paragraph_widget(options={}, contents=nil, &block)
    if options.class.name == "String"
      contents = options
      options = {}
    end
    widget_block(Paragraph.new(options)) do |widget|
      haml_tag :div, :style => style = Haml::StyleBuilder.new(widget.options, [:margin_bottom]).process, :class => "paragraph _typeloft_editable _typeloft_widget_autoselect #{widget.options[:style]} align-#{widget.options[:align]} size-#{widget.options[:size]}" do
        haml_concat(contents) if contents
        block.call if block
      end
    end
  end
  
end