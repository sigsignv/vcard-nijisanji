#!/usr/bin/env ruby
require 'nkf'
require 'yaml'

class VCard
  attr_reader :label

  def initialize map
    @name = map[:name]
    @kana = NKF.nkf('-w --katakana', map[:kana])
    @label = map[:label]
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

def save_data path, vcard
  filename = "#{path}/#{vcard.label}.vcf"
  File.open(filename, 'w') do |f|
    f.write vcard.to_s
  end
end

arr = load_data('src/main.yml')
arr.each do |h|
  save_data("dist/", VCard.new(h))
end
