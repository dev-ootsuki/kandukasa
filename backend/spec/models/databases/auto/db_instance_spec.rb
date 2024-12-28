require 'rails_helper'

RSpec.describe "Databases::Auto::DbInstance", type: :model do
  describe 'generate_query' do
    before do
      @mysql_all = Databases::Auto::DbInstance.new 1, 0, false
      @mysql_exclude_sys = Databases::Auto::DbInstance.new 1, 0, true
    end

    context '' do
      
    end
  end
end