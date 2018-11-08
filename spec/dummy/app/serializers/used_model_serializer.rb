class UsedModelSerializer < ActiveModel::Serializer
  cache key: 'cache_key', expires_in: 24.hours
end
