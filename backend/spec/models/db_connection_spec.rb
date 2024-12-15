require 'rails_helper'

RSpec.describe DbConnection, type: :model do
  describe '#Validation' do
    describe '#Invalid' do
      let!(:empty_all){ DbConnection.new }

      context 'name - なし' do
        it do
          empty_all.valid?
          expect(empty_all.errors[:name]).to include("validate.required")
        end
      end

      context 'name - 最大文字数超え' do
        it do
          obj = DbConnection.new({:name => 33.times.map{|e| "0"}})
          obj.valid?
          expect(obj.errors[:name]).to include("validate.length_to#32")
        end
      end

      context 'db_type - なし' do
        it do
          empty_all.valid?
          expect(empty_all.errors[:db_type]).to include("validate.required")
        end
      end

      context 'db_type - 指定値以外' do
        it do
          obj = DbConnection.new({:db_type => "NG NAME !!!!"})
          obj.valid?
          expect(obj.errors[:db_type]).to include("validate.select_from_puludown")
        end
      end

      context 'host - なし' do
        it do
          empty_all.valid?
          expect(empty_all.errors[:host]).to include("validate.required")
        end
      end

      context 'host - 最大文字数超え' do
        it do
          obj = DbConnection.new({:host => 129.times.map{|e| "0"}})
          obj.valid?
          expect(obj.errors[:host]).to include("validate.length_to#128")
        end
      end

      context 'port - なし' do
        it do
          empty_all.valid?
          expect(empty_all.errors[:port]).to include("validate.required")
        end
      end

      context 'port - 整数以外' do
        it do
          obj = DbConnection.new({ :port => 'test!'})
          obj.valid?
          expect(obj.errors[:port]).to include("validate.range_from_to#1-99999")
        end

        it do
          obj = DbConnection.new({:port => -10})
          obj.valid?
          expect(obj.errors[:port]).to include("validate.range_from_to#1-99999")
        end
      end

      context 'port - 範囲外' do
        it do
          obj = DbConnection.new({:port => 100000})
          obj.valid?
          expect(obj.errors[:port]).to include("validate.range_from_to#1-99999")
        end

        it do
          obj = DbConnection.new({:port => 0})
          obj.valid?
          expect(obj.errors[:port]).to include("validate.range_from_to#1-99999")
        end
      end

      context 'login_name - なし' do
        it do
          empty_all.valid?
          expect(empty_all.errors[:login_name]).to include("validate.required")        
        end
      end
      
      context 'login_name - 最大文字数超え' do
        it do
          obj = DbConnection.new({:login_name => 33.times.map{|e| "0"}})
          obj.valid?
          expect(obj.errors[:login_name]).to include("validate.length_to#32")
        end
      end

      context 'password - 最大文字数超え' do
        it do
          obj = DbConnection.new({:password => 65.times.map{|e| "0"}})
          obj.valid?
          expect(obj.errors[:password]).to include("validate.length_to#64")
        end
      end

      context 'default_database_name - なし' do
        it do
          empty_all.valid?
          expect(empty_all.errors[:default_database_name]).to include("validate.required")
        end
      end

      context 'default_database_name - 最大文字数超え' do
        it do
          obj = DbConnection.new({:default_database_name => 65.times.map{|e| "0"}})
          obj.valid?
          expect(obj.errors[:default_database_name]).to include("validate.length_to#64")
        end
      end

      context 'timeout - 整数以外' do
        it do
          obj = DbConnection.new({ :timeout => 'test!'})
          ret = obj.valid?
          expect(ret).to eq false
          expect(obj.errors[:timeout]).to include("validate.range_from_to#1-#{DbConnection::TIMEOUT_MAX_VALUE}")
        end
  
        it do
          obj = DbConnection.new({:timeout => -10})
          ret = obj.valid?
          expect(ret).to eq false
          expect(obj.errors[:timeout]).to include("validate.range_from_to#1-#{DbConnection::TIMEOUT_MAX_VALUE}")
        end
      end

      context 'timeout - 範囲外' do
        it do
          obj = DbConnection.new({ :timeout => DbConnection::TIMEOUT_MAX_VALUE+1})
          ret = obj.valid?
          expect(ret).to eq false
          expect(obj.errors[:timeout]).to include("validate.range_from_to#1-#{DbConnection::TIMEOUT_MAX_VALUE}")
        end
  
        it do
          obj = DbConnection.new({:timeout => 0})
          ret = obj.valid?
          expect(ret).to eq false
          expect(obj.errors[:timeout]).to include("validate.range_from_to#1-#{DbConnection::TIMEOUT_MAX_VALUE}")
        end
      end

      context 'description - 最大文字数超え' do
        it do
          obj = DbConnection.new({:description => 1025.times.map{|e| "0"}})
          obj.valid?
          expect(obj.errors[:description]).to include("validate.length_to#1024")
        end
      end
    end

    describe "#Valid" do
      let!(:empty_all){ DbConnection.new }

      context 'timeout - なしはdefault指定した値になる' do
        it do
          # timeoutはMigratiionで設定したdefault値が設定される
          expect(empty_all.timeout).to eq 5000
        end
      end

      context 'use_ssl - なしはdefault指定した値になる' do
        it do
          # timeoutはMigratiionで設定したdefault値が設定される
          expect(empty_all.use_ssl).to eq false
        end
      end
    end
  end

  describe '#save / #save!' do
    # TODO SSL接続時のファイルアップロード実装したらテストコードかく
  end
end


