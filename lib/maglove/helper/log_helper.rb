require "logging"
module MagLove
  module Helper
    module LogHelper
      def info(message)
        logger.send(:info, message)
      end

      def debug(message)
        logger.send(:debug, message)
      end

      def error(message)
        logger.send(:error, message)
      end

      def error!(message)
        logger.send(:fatal, message)
        Kernel.exit
      end

      def logger
        Maglove.logger
      end
    end
  end
end
