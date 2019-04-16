# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Batch requests', type: :request do
  token = Apicasso::Key.create(scope: { manage: { used_model: true }, index: { used_model: true } }).token
  access_token = { "CONTENT_TYPE" => "application/json",
                   'AUTHORIZATION' => "Token token=#{token}" }

  describe 'GET /api/v1/ql' do
    context 'with valid params' do
      before(:all) do
        @attribute = UsedModel.column_names.sample
        @used_model = create(:used_model)
        @another_used_model = create(:used_model)
        while @another_used_model.send(@attribute) == @used_model.send(@attribute)
          @another_used_model = create(:used_model)
        end
        post '/api/v1/ql/', params: { used_models: { "#{@attribute}_eq": @used_model.send(@attribute) } }.to_json, headers: access_token
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes queried records' do
        expect(response.body).to include(@used_model.to_json)
      end

      it 'does not return records other than the ones queried' do
        expect(JSON.parse(response.body)['used_models']).not_to include(JSON.parse(@another_used_model.to_json))
      end

      it 'returns params structure reflecting the batch parameter' do
        expect(JSON.parse(response.body)['used_models']).to include(JSON.parse(@used_model.to_json))
        expect(JSON.parse(response.body)['used_model']).to be_nil
        post '/api/v1/ql/', params: { used_model: { "#{@attribute}_eq": @used_model.send(@attribute) } }.to_json, headers: access_token
        expect(JSON.parse(response.body)['used_model']).to include(JSON.parse(@used_model.to_json))
        expect(JSON.parse(response.body)['used_models']).to be_nil
      end
    end
  end

  describe 'POST /api/v1/batch_create' do
    context 'with valid params' do
      before(:all) do
        post '/api/v1/batch_create/', params: {
          used_models: [
            { unit_id: 123, account_id: 123, name: 'Batch Create Used Model 1' },
            { unit_id: 123, account_id: 123, name: 'Batch Create Used Model 2' }
          ]
        }.to_json, headers: access_token
      end

      it 'returns status created' do
        expect(response).to have_http_status(:created)
      end

      it 'creates records based on request body' do
        expect {
          post '/api/v1/batch_create/', params: {
            used_models: [
              { unit_id: 123, account_id: 123, name: 'Batch Create Used Model 1' },
              { unit_id: 123, account_id: 123, name: 'Batch Create Used Model 2' }
            ]
          }.to_json, headers: access_token
        }.to change(UsedModel, :count).by(2)
      end
    end
  end
 
  describe 'PATCH /api/v1/batch_update' do
    context 'with valid params' do
      before(:all) do
        @used_model1 = UsedModel.all.sample
        @used_model2 = UsedModel.where.not(id: @used_model1.id).sample
      end

      it 'returns status accepted' do
        patch '/api/v1/batch_update/', params: {
          used_models: [
            { id: @used_model1.id, name: 'A name' },
            { id: @used_model2.id, name: 'Another name' }
          ]
        }.to_json, headers: access_token
        expect(response).to have_http_status(:accepted)
      end

      it 'updates records based on request body' do
        patch '/api/v1/batch_update/', params: {
          used_models: [
            { id: @used_model1.id, name: 'A different name' },
            { id: @used_model2.id, name: 'Another different name' }
          ]
        }.to_json, headers: access_token
        @used_model1.reload
        @used_model2.reload
        expect(@used_model1.name).to eq 'A different name'
        expect(@used_model2.name).to eq 'Another different name'
      end
    end
  end
end
