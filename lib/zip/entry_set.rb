module Zip
  class EntrySet #:nodoc:all
    include Enumerable
    attr_accessor :entry_set, :entry_order

    def initialize(an_enumerable = [])
      super()
      @entry_set   = {}
      an_enumerable.each { |o| push(o) }
    end

    def include?(entry)
      @entry_set.include?(to_key(entry))
    end

    def find_entry(entry, case_sensitively = true)
      return @entry_set[to_key(entry)] if case_sensitively
      entry = @entry_set.find { |k, _| k.downcase == to_key(entry).downcase }
      entry.last if entry
    end

    def <<(entry)
      @entry_set[to_key(entry)] = entry
    end

    alias :push :<<

    def size
      @entry_set.size
    end

    alias :length :size

    def delete(entry)
      if @entry_set.delete(to_key(entry))
        entry
      else
        nil
      end
    end

    def each(&block)
      @entry_set = sorted_entries.dup.each do |_, value|
        block.call(value)
      end
    end

    def entries
      sorted_entries.values
    end

    # deep clone
    def dup
      EntrySet.new(@entry_set.map { |key, value| value.dup })
    end

    def ==(other)
      return false unless other.kind_of?(EntrySet)
      @entry_set.values == other.entry_set.values
    end

    def parent(entry)
      @entry_set[to_key(entry.parent_as_string)]
    end

    def glob(pattern, flags = ::File::FNM_PATHNAME|::File::FNM_DOTMATCH)
      entries.map do |entry|
        next nil unless ::File.fnmatch(pattern, entry.name.chomp('/'), flags)
        yield(entry) if block_given?
        entry
      end.compact
    end

    protected
    def sorted_entries
      ::Zip.sort_entries ? Hash[@entry_set.sort] : @entry_set
    end

    private
    def to_key(entry)
      entry.to_s.chomp('/')
    end
  end
end

# Copyright (C) 2002, 2003 Thomas Sondergaard
# rubyzip is free software; you can redistribute it and/or
# modify it under the terms of the ruby license.
