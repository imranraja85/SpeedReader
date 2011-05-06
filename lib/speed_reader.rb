#!/usr/local/bin/ruby -w 
 
# = speed_reader.rb -- Fast file processing 
#   SpeedReader is a awk powered CSV file parser.
#
#   Features:
#   - Return the file as an array of rows
#   - Sum up a column
#   - Find the mean of a column
#
#   To-Do:
#   - Validate a column by passing in a regular expression
#   - Return the line number if validation fails
#
#   Created by Imran Raja 
#   Copyright 2011 Raja Productions. All rights reserved. 


class SpeedReader
  VERSION = "0.1.0".freeze
  attr_reader :headers

  def initialize(file_data, options = Hash.new) 
    @field_delimiter =  options[:field_delimiter] || "," 
    @line_delimiter  =  options[:line_delimiter] || "\n"

    create_temp_file(file_data)
    set_headers if options[:headers]
  end 

  def self.open(*args)
    options = if args.last.is_a? Hash then args.pop else Hash.new end

    raise "File Not Found" if !File.exists?(*args)

    #instantize a new object of this class to read in the initial file
    csv = new(File.open(*args).read, options)

    #this makes no sense because we havent opened the file in the instance of 
    #csv
    if block_given?
      yield csv
    else
      csv.close
    end
  end

  def fetch_column(*args)
    results = `awk -F '#{@field_delimiter}' '{print $#{args.first}}' #{file_location}`
    results.split("\n")
  end

  def sum_column(*args)
    awk_params = map_column_identifier_to_number(args.first)
    `awk -F '#{@field_delimiter}' '{x += $#{awk_params}} END {print x}' #{file_location}`.chomp.to_f
  end

  #return the file as an array of arrays specified by the delimiter
  def to_array
    File.read(file_location).split(@line_delimiter)
  end

  private
    #returns the location of the temp file
    def file_location
      File.join(File.dirname(@file), File.basename(@file))
    end

    #create the temp file
    def create_temp_file(file_data)
      @file = Tempfile.new('csv_file')
      @file << file_data
      @file.flush
    end

    #assign the headers in the file to a hash
    def set_headers
      column_names = File.read(file_location).split(@line_delimiter).first.split(@field_delimiter)
      @headers = Hash.new
      column_names.each_with_index do |column, index|
        @headers["#{column}"] = index + 1
      end
    end


    def map_column_identifier_to_number(column_identifier)
      case column_identifier.class.to_s
        when "Fixnum"; column_identifier
        when "String"; @headers[column_identifier]
      end
    end
end
