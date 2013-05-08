require 'logger'

class Grifter
  class Log
    GrifterFormatter = proc do |severity, datetime, progname, msg|
      "#{severity[0]}: [#{datetime.strftime('%m/%d/%y %H:%M:%S')}][#{progname}] - #{msg}\n"
    end

    @@loggers = []
    def self.add_logger handle
      new_logger = Logger.new handle
      new_logger.progname = 'grifter'
      new_logger.formatter = GrifterFormatter
      @@loggers << new_logger
    end

    self.add_logger(STDOUT)

    def self.level= log_level
      @@loggers.each { |logger| logger.level = log_level}
    end

    def self.log level, msg
      @@loggers.each {|logger| logger.send(level, msg)}
    end

    [:fatal, :error, :warn, :info,:debug].each do |log_method|
      define_singleton_method log_method do |msg|
        log(log_method, msg)
      end
    end
  end
end


