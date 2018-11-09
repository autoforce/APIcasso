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
      it 'returns UsedModel records equal to WillPaginate.per_page or all UsedModels' do
        if JSON.parse(response.body)['last_page'] == false
          expect(JSON.parse(response.body)['entries'].size).to eq(WillPaginate.per_page)
        else
          expect(JSON.parse(response.body)['entries'].size).to eq(UsedModel.count)
        end
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
      per_page = (1..UsedModel.all.size).to_a.sample
      page = (1..5).to_a.sample

      before(:all) do
        get '/api/v1/used_model', params: { per_page: per_page, page: page }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns size of records from UsedModel if not last page' do
        expect(JSON.parse(response.body)['entries'].size).to be(per_page) if JSON.parse(response.body)['last_page'] == false
      end
    end

    context 'by searching' do
      brand_to_search = UsedModel.all.sample.brand
      before(:all) do
        get '/api/v1/used_model', params: { 'q[brand_matches]': brand_to_search }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records with brand queried' do
        JSON.parse(response.body)['entries'].each do |record|
          expect(record['brand']).to eq(brand_to_search)
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
      field_select = UsedModel.column_names.sample
      before(:all) do
        get '/api/v1/used_model', params: { 'select': field_select }, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all records that have field queried' do
        JSON.parse(response.body)['entries'].each do |record|
          expect(record.keys).to include(field_select)
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
    id_to_get_id = UsedModel.all.sample.id.to_s
    before(:all) do
      get '/api/v1/used_model/' + id_to_get_id, headers: access_token
    end

    it 'returns status ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a record with attributes' do
      expect(JSON.parse(response.body).keys).to include('id', 'active', 'account_id', 'unit_id', 'brand', 'name', 'slug', 'model', 'version', 'model_year', 'production_year', 'kind', 'new_vehicle', 'old_price', 'price_value', 'price', 'category', 'transmission', 'km_value', 'km', 'plate', 'color', 'doors', 'fuel', 'fuel_text', 'note', 'chassis', 'shielded', 'featured', 'integrator', 'ordination', 'visits', 'bait_id', 'fipe_id', 'identifier', 'synced_at', 'deleted_at', 'created_at', 'updated_at')
    end

    it 'return matches with object searched' do
      expect(UsedModel.find(id_to_get_id.to_i).attributes.to_json).to eq(response.body)
    end
  end

  describe 'GET /api/v1/used_model/:slug' do
    id_to_get_slug = UsedModel.all.sample.slug.to_s
    before(:all) do
      get '/api/v1/used_model/' + id_to_get_slug, headers: access_token
    end

    it 'returns status ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a record with attributes' do
      expect(JSON.parse(response.body).keys).to include('id', 'active', 'account_id', 'unit_id', 'brand', 'name', 'slug', 'model', 'version', 'model_year', 'production_year', 'kind', 'new_vehicle', 'old_price', 'price_value', 'price', 'category', 'transmission', 'km_value', 'km', 'plate', 'color', 'doors', 'fuel', 'fuel_text', 'note', 'chassis', 'shielded', 'featured', 'integrator', 'ordination', 'visits', 'bait_id', 'fipe_id', 'identifier', 'synced_at', 'deleted_at', 'created_at', 'updated_at')
    end

    it 'return matches with object searched' do
      expect(UsedModel.friendly.find(id_to_get_slug).attributes.to_json).to eq(response.body)
    end
  end

  describe 'POST /api/v1/used_model/' do
    slug_to_post = Faker::Lorem.word

    context 'with valid params' do
      before(:all) do
        @quantity = UsedModel.all.size
        post '/api/v1/used_model/', params: { 'used_model': { 'name': 'test', 'account_id': 1, 'unit_id': 1, 'slug': slug_to_post, 'brand': 'BMW' }}, headers: access_token
      end

      it 'returns status created' do
        byebug if response.status == 422
        expect(response).to have_http_status(:created)
      end

      it 'check records size into db' do
        expect(UsedModel.all.size).to eq(@quantity + 1)
      end

      it 'find record into db' do
        expect(UsedModel.find_by(slug: slug_to_post)).not_to eq nil
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
    id_to_put = UsedModel.all.sample.id.to_s
    name_to_put = Faker::Lorem.word
    slug_to_put = UsedModel.all.sample.slug

    context 'with valid params' do
      before(:all) do
        patch '/api/v1/used_model/' + id_to_put, params: { 'used_model': { 'name': name_to_put }}, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates requested record' do
        expect(UsedModel.find(id_to_put).name).to eq(name_to_put)
      end
    end

    context 'with invalid params' do
      it 'return a error' do
        patch '/api/v1/used_model/' + id_to_put, params: { 'used_model': { 'unit_id': nil }}, headers: access_token
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/used_model/:id' do
    id_to_del = UsedModel.all.sample.id.to_s

    context 'with valid params' do
      before(:all) do
        @quantity = UsedModel.all.size
        delete '/api/v1/used_model/' + id_to_del, headers: access_token
      end

      it 'returns status no content' do
        expect(response).to have_http_status(:no_content)
      end

      it 'detete a UsedModel record' do
        expect(UsedModel.all.size).to eq(@quantity - 1)
      end

      it 'check if record was deleted' do
        expect{ UsedModel.find(id_to_del.to_i) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
