#!/usr/bin/env ruby

# Find the closest matchin directory.
#
# Example:
#     $ ruby bin/bam.rb c/p
#     /home/pan/Projects/client/project

PROJECT_DIR = "#{ENV['HOME']}/Projects"

if ARGV[0].nil?
  puts(PROJECT_DIR)
else
  glob = ARGV[0].gsub(/\//, '*/**/')+'*'
  puts(Dir.glob("#{PROJECT_DIR}/**/#{glob}").select{ |i| File.directory?(i) }.sort_by(&:length).first)
end
