#!/usr/bin/env ruby

# Find the closest matchin directory.
#
# Example:
#     $ ruby bin/bam.rb c/p
#     /home/pan/Projects/client/project

glob = ARGV[0].gsub(/\//, '*/')+'*'
puts Dir.glob("#{ENV['HOME']}/Projects/#{glob}").first
