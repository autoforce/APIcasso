# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Apicasso Keys', type: :request do
  describe 'Generation keys' do
    context 'with scope manage' do
      apicasso_key = Apicasso::Key.create(scope: { manage: { used_model: true } })
      access_token = { 'AUTHORIZATION' => "Token token=#{apicasso_key.token}" }

      it 'returns ok to GET' do
        get '/api/v1/used_model', headers: access_token
        expect(response).to have_http_status(:ok)
      end

      it 'returns ok to POST' do
        size_before = UsedModel.all.size

        post '/api/v1/used_model/', params: {
          'used_model': {
            'active': Faker::Boolean.boolean,
            'account_id': Faker::Number.number(1),
            'unit_id': Faker::Number.number(1),
            'brand': Faker::Vehicle.make,
            'name': Faker::Vehicle.make_and_model,
            'model': Faker::Vehicle.model,
            'version': Faker::Number.decimal(1, 1),
            'model_year': Faker::Vehicle.year,
            'production_year': Faker::Vehicle.year,
            'kind': 'car',
            'new_vehicle': Faker::Boolean.boolean,
            'old_price': Faker::Number.decimal(4, 2).to_s,
            'price_value': Faker::Number.decimal(4, 2),
            'price': Faker::Number.decimal(4, 2).to_s,
            'category': Faker::Vehicle.car_type,
            'transmission': Faker::Vehicle.transmission,
            'km_value': Faker::Number.number(8),
            'km': Faker::Number.number(8),
            'plate': Faker::Number.number(4),
            'color': Faker::Vehicle.color,
            'doors': Faker::Number.number(1),
            'fuel':  Faker::Number.number(1),
            'fuel_text': Faker::Vehicle.fuel_type,
            'shielded': Faker::Boolean.boolean,
          }}, headers: access_token

        expect(UsedModel.all.size).to eq(size_before + 1)
        expect(response).to have_http_status(:created)
      end

      it 'returns ok to UPDATE' do
        id_to_del = UsedModel.all.sample.id.to_s

        patch '/api/v1/used_model/' + id_to_del, params: {'used_model': { 'name': Faker::Vehicle.make_and_model }}, headers: access_token
        expect(response).to have_http_status(:ok)
      end

      it 'returns ok to DELETE' do
        id_to_del = UsedModel.all.sample.id.to_s
        size_before = UsedModel.all.size

        delete '/api/v1/used_model/' + id_to_del, headers: access_token

        expect(UsedModel.all.size).to eq(size_before - 1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with scope to read' do
      apicasso_key = Apicasso::Key.create(scope: { read: { used_model: true } })
      access_token = { 'AUTHORIZATION' => "Token token=#{apicasso_key.token}" }

      it 'returns ok to GET' do
        get '/api/v1/used_model', headers: access_token
        expect(response).to have_http_status(:ok)
      end

      it 'returns a raise to POST' do
        size_before = UsedModel.all.size

        expect {
          post '/api/v1/used_model/', params: {
            'used_model': {
              'active': Faker::Boolean.boolean,
              'account_id': Faker::Number.number(1),
              'unit_id': Faker::Number.number(1),
              'brand': Faker::Vehicle.make,
              'name': Faker::Vehicle.make_and_model,
              'model': Faker::Vehicle.model,
              'version': Faker::Number.decimal(1, 1),
              'model_year': Faker::Vehicle.year,
              'production_year': Faker::Vehicle.year,
              'kind': 'car',
              'new_vehicle': Faker::Boolean.boolean,
              'old_price': Faker::Number.decimal(4, 2).to_s,
              'price_value': Faker::Number.decimal(4, 2),
              'price': Faker::Number.decimal(4, 2).to_s,
              'category': Faker::Vehicle.car_type,
              'transmission': Faker::Vehicle.transmission,
              'km_value': Faker::Number.number(8),
              'km': Faker::Number.number(8),
              'plate': Faker::Number.number(4),
              'color': Faker::Vehicle.color,
              'doors': Faker::Number.number(1),
              'fuel':  Faker::Number.number(1),
              'fuel_text': Faker::Vehicle.fuel_type,
              'shielded': Faker::Boolean.boolean
            }}, headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
        expect(UsedModel.all.size).to eq(size_before)
      end

      it 'returns a raise to UPDATE' do
        id_to_del = UsedModel.all.sample.id.to_s

        expect {
          patch '/api/v1/used_model/' + id_to_del, params: { 'used_model': { 'name': Faker::Vehicle.make_and_model }}, headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
      end

      it 'returns a raise to DELETE' do
        id_to_del = UsedModel.all.sample.id.to_s
        size_before = UsedModel.all.size

        expect {
          delete '/api/v1/used_model/' + id_to_del, headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
        expect(UsedModel.all.size).to eq(size_before)
      end
    end

    context 'with scope to write' do
      apicasso_key = Apicasso::Key.create(scope: { create: { used_model: true } })
      access_token = { 'AUTHORIZATION' => "Token token=#{apicasso_key.token}" }

      it 'returns a raise to GET' do
        expect {
          get '/api/v1/used_model', headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
      end

      it 'returns ok to POST' do
        size_before = UsedModel.all.size

        post '/api/v1/used_model/', params: {
          'used_model': {
            'active': Faker::Boolean.boolean,
            'account_id': Faker::Number.number(1),
            'unit_id': Faker::Number.number(1),
            'brand': Faker::Vehicle.make,
            'name': Faker::Vehicle.make_and_model,
            'model': Faker::Vehicle.model,
            'version': Faker::Number.decimal(1, 1),
            'model_year': Faker::Vehicle.year,
            'production_year': Faker::Vehicle.year,
            'kind': 'car',
            'new_vehicle': Faker::Boolean.boolean,
            'old_price': Faker::Number.decimal(4, 2).to_s,
            'price_value': Faker::Number.decimal(4, 2),
            'price': Faker::Number.decimal(4, 2).to_s,
            'category': Faker::Vehicle.car_type,
            'transmission': Faker::Vehicle.transmission,
            'km_value': Faker::Number.number(8),
            'km': Faker::Number.number(8),
            'plate': Faker::Number.number(4),
            'color': Faker::Vehicle.color,
            'doors': Faker::Number.number(1),
            'fuel':  Faker::Number.number(1),
            'fuel_text': Faker::Vehicle.fuel_type,
            'shielded': Faker::Boolean.boolean
          }}, headers: access_token

        expect(response).to have_http_status(:created)
        expect(UsedModel.all.size).to eq(size_before + 1)
      end

      it 'returns a raise to UPDATE' do
        id_to_del = UsedModel.all.sample.id.to_s

        expect {
          patch '/api/v1/used_model/' + id_to_del, params: { 'used_model': { 'name': Faker::Vehicle.make_and_model }}, headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
      end

      it 'returns a raise to DELETE' do
        id_to_del = UsedModel.all.sample.id.to_s
        size_before = UsedModel.all.size

        expect {
          delete '/api/v1/used_model/' + id_to_del, headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
        expect(UsedModel.all.size).to eq(size_before)
      end
    end

    context 'with scope to update' do
      apicasso_key = Apicasso::Key.create(scope: { update: { used_model: true } })
      access_token = { 'AUTHORIZATION' => "Token token=#{apicasso_key.token}" }

      it 'returns a raise to GET' do
        expect {
          get '/api/v1/used_model', headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
      end

      it 'returns a raise to POST' do
        size_before = UsedModel.all.size

        expect {
          post '/api/v1/used_model/', params: {
            'used_model': {
              'active': Faker::Boolean.boolean,
              'account_id': Faker::Number.number(1),
              'unit_id': Faker::Number.number(1),
              'brand': Faker::Vehicle.make,
              'name': Faker::Vehicle.make_and_model,
              'model': Faker::Vehicle.model,
              'version': Faker::Number.decimal(1, 1),
              'model_year': Faker::Vehicle.year,
              'production_year': Faker::Vehicle.year,
              'kind': 'car',
              'new_vehicle': Faker::Boolean.boolean,
              'old_price': Faker::Number.decimal(4, 2).to_s,
              'price_value': Faker::Number.decimal(4, 2),
              'price': Faker::Number.decimal(4, 2).to_s,
              'category': Faker::Vehicle.car_type,
              'transmission': Faker::Vehicle.transmission,
              'km_value': Faker::Number.number(8),
              'km': Faker::Number.number(8),
              'plate': Faker::Number.number(4),
              'color': Faker::Vehicle.color,
              'doors': Faker::Number.number(1),
              'fuel':  Faker::Number.number(1),
              'fuel_text': Faker::Vehicle.fuel_type,
              'shielded': Faker::Boolean.boolean
            }}, headers: access_token
          }.to raise_exception(CanCan::AccessDenied)
        expect(UsedModel.all.size).to eq(size_before)
      end

      it 'returns ok to UPDATE' do
        id_to_del = UsedModel.all.sample.id.to_s

        patch '/api/v1/used_model/' + id_to_del, params: { 'used_model': { 'name': Faker::Vehicle.make_and_model }}, headers: access_token
        expect(response).to have_http_status(:ok)
      end

      it 'returns a raise to DELETE' do
        id_to_del = UsedModel.all.sample.id.to_s
        size_before = UsedModel.all.size

        expect {
          delete '/api/v1/used_model/' + id_to_del, headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
        expect(UsedModel.all.size).to eq(size_before)
      end
    end

    context 'with scope to destroy' do
      apicasso_key = Apicasso::Key.create(scope: { destroy: { used_model: true } })
      access_token = { 'AUTHORIZATION' => "Token token=#{apicasso_key.token}" }

      it 'returns a raise to GET' do
        expect {
          get '/api/v1/used_model', headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
      end

      it 'returns a raise to POST' do
        size_before = UsedModel.all.size

        expect {
          post '/api/v1/used_model/', params: {
            'used_model': {
              'active': Faker::Boolean.boolean,
              'account_id': Faker::Number.number(1),
              'unit_id': Faker::Number.number(1),
              'brand': Faker::Vehicle.make,
              'name': Faker::Vehicle.make_and_model,
              'model': Faker::Vehicle.model,
              'version': Faker::Number.decimal(1, 1),
              'model_year': Faker::Vehicle.year,
              'production_year': Faker::Vehicle.year,
              'kind': 'car',
              'new_vehicle': Faker::Boolean.boolean,
              'old_price': Faker::Number.decimal(4, 2).to_s,
              'price_value': Faker::Number.decimal(4, 2),
              'price': Faker::Number.decimal(4, 2).to_s,
              'category': Faker::Vehicle.car_type,
              'transmission': Faker::Vehicle.transmission,
              'km_value': Faker::Number.number(8),
              'km': Faker::Number.number(8),
              'plate': Faker::Number.number(4),
              'color': Faker::Vehicle.color,
              'doors': Faker::Number.number(1),
              'fuel':  Faker::Number.number(1),
              'fuel_text': Faker::Vehicle.fuel_type,
              'shielded': Faker::Boolean.boolean
            }}, headers: access_token
          }.to raise_exception(CanCan::AccessDenied)
        expect(UsedModel.all.size).to eq(size_before)
      end

      it 'returns a raise to UPDATE' do
        id_to_del = UsedModel.all.sample.id.to_s

        expect {
          patch '/api/v1/used_model/' + id_to_del, params: { 'used_model': { 'name': Faker::Vehicle.make_and_model }}, headers: access_token
        }.to raise_exception(CanCan::AccessDenied)
      end

      it 'returns ok to DELETE' do
        id_to_del = UsedModel.all.sample.id.to_s
        size_before = UsedModel.all.size

        delete '/api/v1/used_model/' + id_to_del, headers: access_token
        expect(response).to have_http_status(:no_content)
        expect(UsedModel.all.size).to eq(size_before - 1)
      end
    end

    context 'with a false key' do
      access_token = { 'AUTHORIZATION' => "Token token=notavalidtoken" }

      it 'returns unauthorized to request' do
        get '/api/v1/used_model', headers: access_token
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with an empty key' do
      access_token = { 'AUTHORIZATION' => "Token token=" }

      it 'returns unauthorized to request' do
        get '/api/v1/used_model', headers: access_token
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
