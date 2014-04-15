require_relative 'configuration'
require_relative 'log'

module Grifter
  module GriftFiles
    include Grifter::Configuration

    def load_grifts_using_configuration
      grift_globs = grifter_configuration['grift_globs']
      p grifter_configuration['grifter_config_file']
      if grifter_configuration['grifter_config_file']
        glob_home_dir = File.dirname grifter_configuration['grifter_config_file']
        grift_globs.map!{|g| File.join glob_home_dir, g }
      end
      if grift_globs.is_a? Array
        grift_globs.each do | gg|
          grifter_load_grift_glob gg
        end
      end
    end

    def grifter_load_grift_glob glob
      globbed_files = Dir[glob]
      Log.debug "Found '#{globbed_files.length}' grift files using grift glob '#{glob}'"
      Dir[glob].each do |filename|
        grifter_load_grift_file filename
      end
    end

    def grifter_load_grift_file filename
      Log.debug "Loading grift file '#{filename}'"

      unless File.exist? filename
        raise GrifterNoSuchGriftFile.new("No such grift file '#{filename}'")
      end

      #by evaling in a anonymous module, we protect this class's namespace
      anon_mod = Module.new
      with_local_load_path File.dirname(filename) do
        anon_mod.class_eval(IO.read(filename), filename, 1)
      end
      self.extend anon_mod
    end

    private
    def with_local_load_path load_path, &block
      $: << load_path
      rtn = yield block
      #delete only the first occurrence, in case something else if changing load path too
      idx = $:.index(load_path)
      $:.delete_at(idx) if idx
      rtn
    end
  end

  class GrifterNoSuchGriftFile < StandardError; end
end
