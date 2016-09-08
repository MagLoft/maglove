require "maglove/widgets/base"
require "maglove/widgets/banner"
require "maglove/widgets/button"
require "maglove/widgets/columns"
require "maglove/widgets/container"
require "maglove/widgets/heading"
require "maglove/widgets/horizontal_rule"
require "maglove/widgets/image"
require "maglove/widgets/paragraph"
require "maglove/widgets/scrollable_image"
require "maglove/widgets/slider"
require "maglove/widgets/video"
require "maglove/widgets/yahoo_screen"
require "maglove/widgets/youtube"

module Maglove
  module Widgets
    Hamloft.register_widget(Banner)
    Hamloft.register_widget(Button)
    Hamloft.register_widget(Columns)
    Hamloft.register_widget(Container)
    Hamloft.register_widget(Heading)
    Hamloft.register_widget(HorizontalRule)
    Hamloft.register_widget(Image)
    Hamloft.register_widget(Paragraph)
    Hamloft.register_widget(ScrollableImage)
    Hamloft.register_widget(Slider)
    Hamloft.register_widget(Video)
    Hamloft.register_widget(YahooScreen)
    Hamloft.register_widget(Youtube)
  end
end
