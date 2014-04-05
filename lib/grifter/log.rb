require 'logger'

module Grifter
  module Log
    extend self

    GrifterFormatter = proc do |severity, datetime, progname, msg|
      "#{severity[0]}: [#{datetime.strftime('%m/%d/%y %H:%M:%S')}][#{progname}] - #{msg}\n"
    end

    @@loggers = []
    def loggers
      @@loggers
    end

    def add_logger handle
      new_logger = Logger.new handle
      new_logger.progname = 'grifter'
      new_logger.formatter = GrifterFormatter
      @@loggers << new_logger
    end

    add_logger(STDOUT)

    def level= log_level
      @@loggers.each { |logger| logger.level = log_level}
    end

    def log level, msg
      @@loggers.each {|logger| logger.send(level, msg)}
    end

    [:fatal, :error, :warn, :info,:debug].each do |log_method|
      define_method log_method do |msg|
        self.log(log_method, msg)
      end
    end

    def logger
      self
    end
  end
end

