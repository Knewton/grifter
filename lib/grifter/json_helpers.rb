require 'json'

class Grifter
  module JsonHelpers

    #always returns a string, intended for request bodies
    #every attempt is made to ensure string is valid json
    #but if that is not possible, then its returned as is
    def jsonify obj
      case obj
      when String
        JSON.pretty_generate(JSON.parse(obj))
      when Hash, Array
        JSON.pretty_generate(obj)
      else
        obj.to_s
      end
    rescue Exception
      obj.to_s
    end

    #attempts to parse json strings into native ruby objects
    def objectify json_string
      return nil if json_string.nil? or json_string==''
      case json_string
      when Hash, Array
        return json_string
      else
        JSON.parse(json_string.to_s)
      end
    rescue Exception
      json_string
    end

  end
end
