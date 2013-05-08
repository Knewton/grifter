require 'grifter/json_helpers.rb'

describe Grifter::JsonHelpers do

  let(:json_helper) { Class.new.extend(Grifter::JsonHelpers) }

  describe :jsonify do
    it "should turn a hash into json" do
      hash = {
        'a' => '123',
        'b' => 456,
        :c => [
          1,
          2.3,
          '456'
        ],
        'd' => {
          'x' => 'y'
        }
      }

      json = json_helper.jsonify(hash)

      #ugh, gross!
      json.should eql %Q|{
  "a": "123",
  "b": 456,
  "c": [
    1,
    2.3,
    "456"
  ],
  "d": {
    "x": "y"
  }
}|

    end

    it "should return a non json string as itself" do
      json_helper.jsonify("abc").should eql("abc")
    end

    it "should make a json string pretty" do
      json_str = '{"foo":"bar", "abc":123}'
      json_helper.jsonify(json_str).should eql %Q|{
  "foo": "bar",
  "abc": 123
}|
    end

  end
end
