class UsedModel < ApplicationRecord
  include Rails.application.routes.url_helpers

  validates :account_id, presence: true
  validates :unit_id, presence: true
  validates :slug, presence: true, uniqueness: true

  has_one_attached :file_highlighted
  has_many_attached :files

  extend FriendlyId
  friendly_id :name, use: :slugged

  def file_highlighted_url
    rails_blob_path(file_highlighted, only_path: true) if nil? { file_highlighted_url = nil }
  end

  def files_url
    used_model_attachments = self.files.attachments
    urls = []
    used_model_attachments.each do |attachment|
      urls << rails_blob_path(attachment, only_path: true)
    end
    urls
  end

  def cache_key(*timestamp_names)
    case
    when new_record?
      "#{model_name.cache_key}/new"
    when timestamp_names.any?
      timestamp = max_updated_column_timestamp(timestamp_names = timestamp_attributes_for_update_in_model)
      timestamp = timestamp.utc.to_s(cache_timestamp_format)
      "#{model_name.cache_key}/#{id}-#{timestamp}"
    when timestamp = max_updated_column_timestamp
      timestamp = timestamp.utc.to_s(cache_timestamp_format)
      "#{model_name.cache_key}/#{id}-#{timestamp}"
    else
      "#{model_name.cache_key}/#{id}"
    end
  end
end
