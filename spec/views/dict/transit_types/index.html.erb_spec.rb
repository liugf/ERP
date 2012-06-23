require 'spec_helper'

describe "dict_transit_types/index" do
  before(:each) do
    assign(:dict_transit_types, [
      stub_model(Dict::TransitType,
        :code => "Code",
        :name => "Name"
      ),
      stub_model(Dict::TransitType,
        :code => "Code",
        :name => "Name"
      )
    ])
  end

  it "renders a list of dict_transit_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Code".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
