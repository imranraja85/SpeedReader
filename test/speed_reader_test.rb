require 'test_helper'
require 'ruby-debug'

class SpeedReaderTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, SpeedReader
  end

  test "should parse the files headers" do
    SpeedReader.open("test/sample_file.csv", {:headers => true}) do |f| 
      assert f.headers == {"Name" => 1, "Age" => 2, "DOB"=> 3, "Status"=> 4}
      assert f.sum_column(2) == 69
    end
  end

  
end
