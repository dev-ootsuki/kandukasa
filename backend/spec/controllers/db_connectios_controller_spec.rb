require 'rails_helper'

RSpec.describe DbConnection, type: :request do
  describe '#Request testing' do
    before do
      @mysql_sakila = create(:mysql_sakila)
      @mysql_world = create(:mysql_world)
      @headers = {
        'content_type': 'application/json',
        'accespt': 'application/json'
      }
    end

    context 'GET show (/db_connection)' do 
      # 全件取得
      it do
        get '/db_connection', headers: @headers
        expect(response).to have_http_status(:success)
        data = JSON.parse response.body
        expect(data["data"].length).to eq 2
      end
    end

    context 'GET get (/db_connection/:id)' do
      it do
        get '/db_connection/99999', headers: @headers
        expect(response.status).to be 404
      end

      it do
        get '/db_connection/1', headers: @headers
        expect(response).to have_http_status(:success)
        data = JSON.parse response.body
        expect(data["data"]["id"]).to eq "1"
      end
    end

    context 'POST create (/db_connection)' do
      it do
        post '/db_connection', headers: @headers, params: {}
        data = JSON.parse response.body
        expect(response.status).to be 400
        expect(data["errors"]["message"]).to eq "E-001"
      end

      it do
        post '/db_connection', headers: @headers, params: build(:mysql_world_new).to_h
        data = JSON.parse response.body
        p data
      end
    end
  end
end