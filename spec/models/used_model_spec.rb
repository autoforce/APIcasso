# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsedModel, type: :model do
  context 'validations' do
    it 'is valid with valid attributes' do
      expect(build :used_model).to be_valid
    end
    it 'is invalid with slug duplicate' do
      used_model = build(:used_model)
      used_model.slug = 'duplicate'
      used_model.save

      used_model_dup = build(:used_model)
      used_model_dup.slug = 'duplicate'
      expect { used_model_dup.save! }.to raise_exception ActiveRecord::RecordInvalid
    end
    it 'is invalid without valid slug attribute' do
      used_model = build(:used_model)
      used_model.slug = ''
      expect { used_model.save! }.to raise_exception ActiveRecord::RecordInvalid
    end
    it 'is invalid without valid account_id attribute' do
      used_model = build(:used_model)
      used_model.account_id = nil
      expect { used_model.save! }.to raise_exception ActiveRecord::RecordInvalid
    end
    it 'is invalid without valid unit_id attribute' do
      used_model = build(:used_model)
      used_model.unit_id = nil
      expect { used_model.save! }.to raise_exception ActiveRecord::RecordInvalid
    end
  end
end
