require 'active_support/notifications'
class Grifter
  module Instrumentation

    Sample = Struct.new(:service_name, :method, :path, :status, :duration_ms, :end_time)

    def start_instrumentation
      @all_requests ||= []
      ActiveSupport::Notifications.subscribe('request.grifter') do |name, start_time, end_time, _, data|
        #do nothing if exception happened, else we might interfere with exception handling
        unless data[:exception]
          duration_ms = ((end_time.to_f - start_time.to_f) * 1000).to_i
          #$stderr.puts '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
          @all_requests << Sample.new(
            data[:service],
            data[:method].intern,
            data[:path],
            data[:response].status.to_s.intern,
            duration_ms,
            end_time
          )
        end
      end
    end

    def metrics_all_requests
      @all_requests
    end
  end
end
