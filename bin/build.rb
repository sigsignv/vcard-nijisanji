#!/usr/bin/env ruby
require 'nkf'
require 'yaml'

class VCard
  def initialize map
    @name = map[:name]
    @kana = NKF.nkf('-w --katakana', map[:kana])
  end

  def separate_name
    if @name.include? ' '
      lname, fname = @name.split(/\s/, 2)
      lkana, fkana = @kana.split(/\s/, 2)
      <<-EOS
N:#{lname};#{fname};;;
FN:#{@name}
X-PHONETIC-FIRST-NAME:#{fkana}
X-PHONETIC-LAST-NAME:#{lkana}
      EOS
    else
      <<-EOS
N:#{@name};;;;
FN:#{@name}
X-PHONETIC-LAST-NAME:#{@kana}
      EOS
    end
  end

  def to_s
    <<-EOS
BEGIN:VCARD
VERSION:3.0
#{self.separate_name.strip}
END:VCARD
    EOS
  end
end

def load_data filename
  File.open(filename, 'r') do |f|
    YAML.load(f, symbolize_names: true)
  end
end

arr = load_data('src/main.yml')
arr.each do |h|
  v = VCard.new(h)
  puts v.to_s
  puts ""
end
