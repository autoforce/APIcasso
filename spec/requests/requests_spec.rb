# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Used Model requests', type: :request do
  token = Apicasso::Key.create(scope: { manage: { used_model: true } }).token
  access_token = { 'AUTHORIZATION' => "Token token=#{token}" }
  describe 'GET /api/v1/used_model' do
    context 'with default pagination' do
      before(:all) do
        get '/api/v1/used_model', headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'returns all UsedModel' do
        expect(JSON.parse(response.body)['entries'].size).to eq(UsedModel.all.size)
      end
    end

    context 'with negative pagination' do
      before(:all) do
        get '/api/v1/used_model', params: { per_page: -1 }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'returns all UsedModel' do
        expect(JSON.parse(response.body)['entries'].size).to eq(UsedModel.all.size)
      end
    end

    context 'with pagination' do
      before(:all) do
        get '/api/v1/used_model', params: { per_page: 5, page: 1 }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns five records from UsedModel if not last page' do
        expect(JSON.parse(response.body)['entries'].size).to be(5) if JSON.parse(response.body)['last_page'] == false
      end
    end

    context 'by searching' do
      before(:all) do
        get '/api/v1/used_model', params: { 'q[brand_matches]': 'Audi' }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records with brand queried' do
        JSON.parse(response.body)['entries'].each do |record|
          expect(record['brand']).to eq('Audi')
        end
      end
    end

    context 'by grouping' do
      before(:all) do
        get '/api/v1/used_model', params: { 'group[by]': 'brand', 'group[calculate]': 'count', 'group[fields]': 'transmission' }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records grouped brand queried' do
        expect(JSON.parse(response.body)).to eq(UsedModel.group(:brand).count)
      end
    end

    context 'with sorting' do
      before(:all) do
        get '/api/v1/used_model', params: { 'per_page': -1, 'sort': '+brand,+model' }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records sorted queried' do
        used_model_sorted = UsedModel.order(:brand, :model).map(&:id)
        entries = JSON.parse(response.body)['entries'].map { |model| model['id'] }
        expect(entries).to eq(used_model_sorted)
      end
    end

    context 'with field selecting' do
      before(:all) do
        get '/api/v1/used_model', params: { 'select': 'brand' }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records that have field queried' do
        JSON.parse(response.body)['entries'].each do |record|
          expect(record.keys).to include('brand')
        end
      end
    end

    context 'with include associations valid' do
      before(:all) do
        get '/api/v1/used_model', params: { 'include': 'files_blobs,files_url' }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records with includes queried' do
        JSON.parse(response.body)['entries'].each do |record|
          expect(record.keys).to include('files_blobs', 'files_url')
        end
      end
    end

    context 'with include associations invalid' do
      before(:all) do
        get '/api/v1/used_model', params: { 'include': 'files,file' }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records without includes queried' do
        JSON.parse(response.body)['entries'].each do |record|
          expect(record.keys).not_to include('files_blobs', 'files_url')
        end
      end
    end
  end

  describe 'GET /api/v1/used_model/:id' do
    before(:all) do
      get '/api/v1/used_model/1', headers: access_token
    end

    it 'returns status ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a record with attributes' do
      expect(JSON.parse(response.body).keys).to include('id', 'active', 'account_id', 'unit_id', 'brand', 'name', 'slug', 'model', 'version', 'model_year', 'production_year', 'kind', 'new_vehicle', 'old_price', 'price_value', 'price', 'category', 'transmission', 'km_value', 'km', 'plate', 'color', 'doors', 'fuel', 'fuel_text', 'note', 'chassis', 'shielded', 'featured', 'integrator', 'ordination', 'visits', 'bait_id', 'fipe_id', 'identifier', 'synced_at', 'deleted_at', 'created_at', 'updated_at')
    end
  end

  describe 'GET /api/v1/used_model/:slug' do
    before(:all) do
      get '/api/v1/used_model/cr-v', headers: access_token
    end

    it 'returns status ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a record with attributes' do
      expect(JSON.parse(response.body).keys).to include('id', 'active', 'account_id', 'unit_id', 'brand', 'name', 'slug', 'model', 'version', 'model_year', 'production_year', 'kind', 'new_vehicle', 'old_price', 'price_value', 'price', 'category', 'transmission', 'km_value', 'km', 'plate', 'color', 'doors', 'fuel', 'fuel_text', 'note', 'chassis', 'shielded', 'featured', 'integrator', 'ordination', 'visits', 'bait_id', 'fipe_id', 'identifier', 'synced_at', 'deleted_at', 'created_at', 'updated_at')
    end
  end

  describe 'POST /api/v1/used_model/' do
    context 'with valid params' do
      before(:all) do
        post '/api/v1/used_model/', params: { 'used_model': { 'name': 'test', 'account_id': 1, 'unit_id': 1, 'slug': 'tests' }}, headers: access_token
      end

      it 'returns status created' do
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'return a error' do
        post '/api/v1/used_model/', params: { 'used_model': { 'slug': 'cr-v' }}, headers: access_token
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /api/v1/used_model/:id' do
    context 'with valid params' do
      before(:all) do
        patch '/api/v1/used_model/' + UsedModel.last.id.to_s, params: { 'used_model': { 'name': 'updated' }}, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates requested record' do
        expect(UsedModel.last.name).to eq('updated')
      end
    end

    context 'with invalid params' do
      it 'return a error' do
        patch '/api/v1/used_model/' + UsedModel.last.id.to_s, params: { 'used_model': { 'slug': 'cr-v' }}, headers: access_token
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/used_model/:id' do
    before(:all) do
      delete '/api/v1/used_model/' + UsedModel.last.id.to_s, headers: access_token
    end

    it 'returns status no content' do
      expect(response).to have_http_status(:no_content)
    end

    it 'detete a UsedModel record' do
      expect(UsedModel.all.size).to eq(10)
    end
  end
end
