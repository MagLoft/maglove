module MagLove
  class View
    
    def self.editor
      %q{!!! 5
%html
  %head
    %meta{ charset: "UTF-8" }
    %title= "#{theme} - #{template}"
    %meta{ name: "viewport", content: "width=device-width, initial-scale=1.0" }
    %link{ href: "/themes/#{theme}/theme.css", media: "screen", rel: "stylesheet" }
    %link{ href: "/fonts/fonts.css", media: "screen", rel: "stylesheet" }
    %script{ src: "/themes/#{theme}/theme.js", type: "text/javascript" }
  %body
    = contents
    #inspector
      - templates.each do |template|
        %a{href: "/#{template}"}
          = template

:css
  div#inspector {
    position: fixed !important;
    top: 8px !important;
    right: 8px !important;
    height: 32px !important;
    background: #FFF !important;
    line-height: 32px !important;
    z-index: 1000000 !important;
    text-transform: uppercase !important;
    font-size: 11px !important;
    font-weight: bold !important;
    letter-spacing: 1px !important;
    font-family: "Helvetica Neue" !important;
    opacity: 0.25 !important;
    transition: opacity 300ms !important;
  }

  div#inspector:hover {
    opacity: 1 !important;
  }

  div#inspector a {
    color: #171717 !important;
    padding: 0px 12px !important;
    border-left: 1px solid #F5F5F5 !important;
    border-right: none !important;
    border-top: none !important;
    border-bottom: none !important;
    display: inline-block !important;
    float: left !important;
  }

  div#inspector a:hover {
    color: #FFFFFF !important;
    background: #000000 !important;
  }

  div#inspector a:first-child {
    border-left: none !important;
  }

  div#__bs_notify__ {
    border-radius: 0 !important;
    right: inherit !important;
    left: 8px !important;
    height: 32px !important;
    top: 8px !important;
    line-height: 32px !important;
    padding: 0px 26px !important;
    color: #171717 !important;
    z-index: 1000000 !important;
    background: #FFF !important;
  }
}
    end
  end
end
