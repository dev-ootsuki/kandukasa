require 'rails_helper'

RSpec.describe DbConnection, type: :request do
  INT_MAX = 1 << 64
  describe '#Request testing' do
    before do
      @mysql_sakila = create(:mysql_sakila)
      @mysql_world = create(:mysql_world)
      @mysql_new_instance = build(:mysql_world_new)
      @headers = {
        'content_type': 'application/json',
        'accespt': 'application/json'
      }
    end

    context 'GET show (/db_connection)' do 
      # 全件取得
      it '全件取得可能か' do
        get '/db_connection', headers: @headers
        expect(response).to have_http_status(:success)
        data = JSON.parse response.body
        expect(data["data"].length).to eq 2
      end
    end

    context 'POST create (/db_connection)' do
      it '空パラメータは404か' do
        post '/db_connection', headers: @headers, params: {}
        expect(response.status).to be 400
      end

      it 'validationが起動されているか' do
        params = {"db_connection" => @mysql_new_instance.attributes}
        params["db_connection"]["port"] = "aaaaaaa"
        post '/db_connection', headers: @headers, params: params
        expect(response.status).to be 400
        data = JSON.parse response.body
        expect(data["errors"]["detail"]["port"]).to include "validate.range_from_to#1-99999"
      end

      it '新規登録可能か' do
        params = {"db_connection" => @mysql_new_instance.attributes}
        post '/db_connection', headers: @headers, params: params
        expect(response.status).to be 200
      end
    end

    context 'PUT/PATCH update (/db_connection/:id)' do
      it '指定IDが存在しない場合は404か' do
        put "/db_connection/#{INT_MAX}", headers: @headers, params: {}
        expect(response.status).to be 404
      end

      it 'validationが起動されているか' do
        params = {"db_connection" => @mysql_sakila.attributes}
        params["db_connection"]["port"] = "aaaaaaa"
        put "/db_connection/#{@mysql_sakila.id}", headers: @headers, params: params
        expect(response.status).to be 400
        data = JSON.parse response.body
        expect(data["errors"]["detail"]["port"]).to include "validate.range_from_to#1-99999"
      end

      it '指定IDの更新が可能か' do
        test_description = "Rspec Test !!!!!"
        @mysql_sakila.description = test_description
        put "/db_connection/#{@mysql_sakila.id}", headers: @headers, params: { "db_connection" => @mysql_sakila.attributes}
        expect(response.status).to be 200
        data = JSON.parse response.body
        expect(data["data"]["description"]).to eq test_description
      end

      it 'patchも動作しているか' do
        test_description = "Rspec Test !!!!!"
        @mysql_world.description = test_description
        patch "/db_connection/#{@mysql_world.id}", headers: @headers, params: { "db_connection" => @mysql_world.attributes}
        expect(response.status).to be 200
        data = JSON.parse response.body
        expect(data["data"]["description"]).to eq test_description
      end
    end

    context 'DELETE destroy (/db_connections/:id)' do
      it '指定IDが存在しない場合は404か' do
        delete "/db_connection/#{INT_MAX}", headers: @headers
        expect(response.status).to be 404
      end

      it '指定IDで削除可能か' do
        delete "/db_connection/#{@mysql_sakila.id}", headers: @headers
        expect(response.status).to be 200
      end
    end

    context 'GET get (/db_connection/:id)' do
      it '指定IDが存在しない場合は404か' do
        get "/db_connection/#{INT_MAX}", headers: @headers
        expect(response.status).to be 404
      end

      it '指定IDの情報が取得可能か' do
        get "/db_connection/#{@mysql_sakila.id}", headers: @headers
        expect(response).to have_http_status(:success)
        data = JSON.parse response.body
        expect(data["data"]["id"]).to eq @mysql_sakila.id.to_s
      end
    end
  end
end