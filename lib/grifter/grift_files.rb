require_relative 'log'

module Grifter
  module GriftFiles

    def grifter_load_grift_file filename
      Log.debug "Loading grift file '#{filename}'"
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
end
