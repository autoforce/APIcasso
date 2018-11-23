# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Used Model plurarized bad requests', type: :request do
  token = Apicasso::Key.create(scope: { manage: { used_model: true } }).token
  access_token = { 'AUTHORIZATION' => "Token token=#{token}" }

  context 'raise a bad request when using SQL injection' do
    it 'for grouping in fields' do
      expect {
        get '/api/v1/used_models', params: {
          'group[by]': 'brand',
          'group[calculate]': 'count',
          'group[fields]': "'OR 1=1;"
        }, headers: access_token
      }.to raise_exception(ActionController::BadRequest)
    end

    it 'for sorting' do
      expect {
        get '/api/v1/used_models', params: { 'per_page': -1, 'sort': "'OR 1=1;" }, headers: access_token
      }.to raise_exception(ActionController::BadRequest)
    end

    it 'for include' do
      expect {
        get '/api/v1/used_models', params: { 'include': "'OR 1=1;" }, headers: access_token
      }.to raise_exception(ActionController::BadRequest)
    end
  end

  context 'raise a bad request when using invalid resources' do
    it 'for root resource' do
      expect {
        get '/api/v1/admins', headers: access_token
      }.to raise_exception(ActionController::BadRequest)
    end

    it 'for nested resource' do
      expect {
        get '/api/v1/used_models/1/admins', headers: access_token
      }.to raise_exception(ActionController::BadRequest)
    end

    it 'for include' do
      expect {
        get '/api/v1/used_models', params: { 'include': 'admins' }, headers: access_token
      }.to raise_exception(ActionController::BadRequest)
    end
  end
end
