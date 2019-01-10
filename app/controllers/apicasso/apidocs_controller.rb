# frozen_string_literal: true

module Apicasso
  # Controller used to generate an application Swagger JSON, used by
  # SwaggerUI to generate beautiful API documentation
  class ApidocsController < Apicasso::ApplicationController
    skip_before_action :restrict_access

    include Swagger::Blocks
    # Default application settings for documentation generation.
    # Define here the title of the application, logo, description, terms
    # of service, contact of the developer and the license of the application.
    swagger_root do
      MODELS_EXCLUDED = [
        'ApplicationRecord',
        'ActiveRecord::SchemaMigration',
        'Apicasso::ApplicationRecord',
        'Apicasso::Key',
        'Apicasso::Request',
        'Apicasso::ApidocsController',
        'ActiveStorage::Attachment',
        'ActiveStorage::Blob'
      ].freeze
      key :swagger, '2.0'
      info do
        key :title, ENV.fetch('APP_NAME', I18n.t('application.name'))
        # The x-logo key is responsible for the logo in the documentation
        key 'x-logo', url: I18n.t('app.logo.url', default: 'https://raw.githubusercontent.com/ErvalhouS/APIcasso/master/APIcasso.png'),
                      altText: I18n.t('app.logo.alttext', default: 'Application Logo')
        key :description, ENV.fetch('APP_DESCRIPTION', I18n.t('application.description'))
        key :termsOfService, I18n.t('application.terms_of_service')
        contact do
          key :name, I18n.t('application.contact_name')
        end
        license do
          key :name, I18n.t('application.license')
        end
      end
      # Auto generated default application setting for each model of application
      ActiveRecord::Base.descendants.each do |model|
        next if MODELS_EXCLUDED.include?(model.name) || model.abstract_class

        tag do
          key :name, I18n.t("activerecord.models.#{model.name.underscore}", default: model.name.underscore)
          key :description, I18n.t("activerecord.models.#{model.name.underscore}.description", default: model.name)
        end
      end
      key :host, I18n.t('application.apicasso_host', default: ENV.fetch('ROOT', 'localhost:3000'))
      key :basePath, I18n.t('application.apicasso_path', default: '/')
      key :consumes, ['application/json']
      key :produces, ['application/json']

      security_definition :api_key do
        key :type, :apiKey
        key :name, :api_key
        key :in, :header
      end
    end

    # Eager load application to be able to list all models
    Rails.application.eager_load!
    # A list of all classes that have swagger_* declarations, which gets
    # injected by this gem in all `ActiveRecord::Base` classes
    SWAGGERED_CLASSES = [
      *ActiveRecord::Base.descendants,
      self
    ].freeze
    ASSOCIATION_EXCLUDED = [
      'ActiveStorage::Attachment',
      'ActiveStorage::Blob'
    ].freeze
    swagger_schema :ErrorModel do
      key :required, [:code, :message]
      property :code do
        key :type, :integer
        key :format, :int32
      end
      property :message do
        key :type, :string
      end
    end

    # Generate metadata to each class of application
    SWAGGERED_CLASSES.each do |klass|
      next if MODELS_EXCLUDED.include?(klass.name) || klass.abstract_class

      swagger_schema klass.name.to_sym do
        key :required, klass.presence_validators if klass.presence_validators?
        klass.columns_hash.each do |name, type|
          property name.to_sym do
            key :type, type.type
          end
        end
      end
      swagger_schema "#{klass.name}Input".to_sym do
        allOf do
          schema do
            key :'$ref', "#{klass.name}Input".to_sym
          end
          schema do
            key :required, %i[*presence_validators] if klass.presence_validators?
            klass.columns_hash.each do |name, type|
              property name.to_sym do
                key :type, type.type
              end
            end
          end
        end
      end
      swagger_schema "#{klass.name}Metadata".to_sym do
        allOf do
          schema do
            key :'$ref', "#{klass.name}Metadata".to_sym
          end
          schema do
            klass.columns_hash.each do |name, type|
              property name.to_sym do
                key :description, type.type
                key :type, :string
              end
            end
          end
        end
      end
    end

    # Builds JSON of definitions with operations from each model
    ActiveRecord::Base.descendants.each do |model|
      # byebug if model.name == 'Show'

      next if MODELS_EXCLUDED.include?(model.name) || model.abstract_class

      # Resource definitions of GET, OPTIONS, POST
      swagger_path "/#{model.name.underscore}" do
        operation :get do
          key :summary, I18n.t("activerecord.models.#{model.name.underscore}.index.summary", default: model.name)
          key :description, I18n.t("activerecord.models.#{model.name.underscore}.index.description", default: model.name)
          key :operationId, "find#{model.name.pluralize}"
          key :produces, ['application/json']
          key :tags, [model.name.underscore]
          parameter do
            key :name, :sort
            key :in, :query
            key :description, I18n.t('apicasso.sort.description',
                                    default: 'Parameters sorting splitted by `,` preffixed by `+` or `-` which translates into ascending or descending order')
            key :required, false
            key :type, :string
            key :collectionFormat, :json
          end
          parameter do
            key :name, :q
            key :in, :query
            key :description, I18n.t('apicasso.q.description',
                                    default: 'Records filtering by attribute and search query as affix. Usage: `?q[{attribute}{search_affix}]={matcher}`. All available search affixes are listed on: https://github.com/activerecord-hackery/ransack#search-matchers')
            key :required, false
            key :type, :json
          end
          parameter do
            key :name, :page
            key :in, :query
            key :description, I18n.t('apicasso.page.description',
                                    default: 'Records pagination paging, which offsets collection based on `params[:per_page]`')
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :per_page
            key :in, :query
            key :description, I18n.t('apicasso.per_page.description',
                                    default: 'Records pagination size, which sets how many records will be rendered per request')
            key :required, false
            key :type, :integer
          end
          response 200 do
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.index.response",
                                    default: "#{model.name} response, which include records matching current query and pagination metadata")
            schema do
              key :name, :total
              key :description, I18n.t('apicasso.total.description',
                                      default: 'Total records contained in current collection, as if there was no pagination.')
              key :required, true
              key :type, :integer
            end
            schema do
              key :name, :total_pages
              key :description, I18n.t('apicasso.total_pages.description',
                                      default: 'How many pages of data the current collection has.')
              key :required, true
              key :type, :integer
            end
            schema do
              key :name, :last_page
              key :description, I18n.t('apicasso.last_page.description',
                                      default: 'An indication if current request is the last to paginate in the current collection')
              key :required, true
              key :type, :boolean
            end
            schema do
              key :name, :previous_page
              key :description, I18n.t('apicasso.previous_page.description',
                                      default: "The link of the previous page for the current collection. It can be null if there isn't any")
              key :required, false
              key :type, :string
            end
            schema do
              key :name, :next_page
              key :description, I18n.t('apicasso.next_page.description',
                                      default: "The link of the next page for the current collection. It can be null if there isn't any")
              key :required, false
              key :type, :string
            end
            schema do
              key :name, :out_of_bounds
              key :description, I18n.t('apicasso.out_of_bounds.description',
                                      default: 'An indication if current request is out of pagination bounds for the current collection')
              key :required, true
              key :type, :boolean
            end
            schema do
              key :name, :offset
              key :description, I18n.t('apicasso.offset.description',
                                      default: 'How many records were offsetted from the collection to render the current page')
              key :required, true
              key :type, :integer
            end
            schema do
              key :name, :entries
              key :description, I18n.t('apicasso.entries.description',
                                      default: 'The records collection in the current pagination scope.')
              key :required, true
              key :type, :array
              items do
                key :'$ref', model.name.to_sym
              end
            end
          end
        end
        operation :options do
          key :description, I18n.t("activerecord.models.#{model.name.underscore}.schema.description",
                                  default: "#{model.name} metadata information.")
          key :operationId, "schema#{model.name.pluralize}"
          key :produces, ['application/json']
          key :tags, [model.name.underscore]
          response 200 do
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.schema.response",
                                    default: "#{model.name} metadata as a json with field names as keys and field types as values.")
            schema do
              key :'$ref', "#{model.name}".to_sym
            end
          end
        end
        operation :post do
          key :description, I18n.t("activerecord.models.#{model.name.underscore}.create.response",
                                  default: "Creates a #{model.name}")
          key :operationId, "add#{model.name}"
          key :produces, ['application/json']
          key :tags, [model.name.underscore]
          parameter do
            key :name, model.name.underscore.to_sym
            key :in, :body
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.create.description",
                                  default: "#{model.name} to add into application")
            key :required, true
            schema do
              key :'$ref', "#{model.name}".to_sym
            end
          end
          response 201 do
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.show.description",
                                    default: "#{model.name} response")
            schema do
              key :'$ref', model.name.to_sym
            end
          end
        end
      end
      swagger_path "/#{model.name.underscore}/{id}" do
        operation :patch do
          key :description, I18n.t("activerecord.models.#{model.name.underscore}.update.response",
                                  default: "Updates a #{model.name}")
          key :operationId, "edit#{model.name}"
          key :produces, ['application/json']
          key :tags, [model.name.underscore]
          parameter do
            key :name, :id
            key :in, :path
            key :description, I18n.t("activerecord.models.attributes.#{model.name.underscore}.id",
                                    default: "ID of #{model.name} to update on the application")
            key :required, true
            schema do
              key :'$ref', "#{model.name}".to_sym
            end
          end
          parameter do
            key :name, model.name.underscore.to_sym
            key :in, :body
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.update.description",
                                    default: "Existing #{model.name} to update on the application")
            key :required, true
            schema do
              key :'$ref', "#{model.name}".to_sym
            end
          end
          response 200 do
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.show.description",
                                    default: "#{model.name} response")
            schema do
              key :'$ref', model.name.to_sym
            end
          end
        end
        operation :get do
          key :description, I18n.t("activerecord.models.#{model.name.underscore}.show.response",
                                  default: "Creates a #{model.name}")
          key :operationId, "show#{model.name}"
          key :produces, ['application/json']
          key :tags, [model.name.underscore]
          parameter do
            key :name, :id
            key :in, :path
            key :description, I18n.t("activerecord.models.attributes.#{model.name.underscore}.id",
                                    default: "ID of #{model.name} to fetch on the application")
            key :required, true
            schema do
              key :'$ref', "#{model.name}".to_sym
            end
          end
          response 200 do
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.show.description",
                                    default: "#{model.name} response")
            schema do
              key :'$ref', model.name.to_sym
            end
          end
        end
        operation :delete do
          key :description, I18n.t("activerecord.models.#{model.name.underscore}.destroy.response",
                                  default: "Deletes a #{model.name}")
          key :operationId, "destroy#{model.name}"
          key :produces, ['application/json']
          key :tags, [model.name.underscore]
          parameter do
            key :name, :id
            key :in, :path
            key :description, I18n.t("activerecord.models.attributes.#{model.name.underscore}.id",
                                    default: "ID of #{model.name} to delete on the application")
            key :required, true
            schema do
              key :'$ref', "#{model.name}".to_sym
            end
          end
          response 200 do
            key :description, I18n.t("activerecord.models.#{model.name.underscore}.destroy.description",
                                    default: "#{model.name} response")
          end
        end
      end

      # Resource's associations definitions
      model.reflect_on_all_associations.each do |association|
        begin
          inner_name = association.class_name.to_s.classify
        rescue NoMethodError, ActionController::RoutingError
          inner_name = association.name.to_s.classify
        end

        next if Apicasso.configuration.model_definitions_excluded.include?(inner_name)
        next if association.polymorphic?
        next if ASSOCIATION_EXCLUDED.include?(inner_name)
        inner_klass = begin inner_name.constantize rescue NameError; false end
        swagger_path "/#{model.name.underscore}/{id}/#{association.name}" do
          operation :get do
            key :summary, I18n.t("activerecord.models.#{inner_name.underscore}.index.summary", default: inner_name)
            key :description, I18n.t("activerecord.models.#{inner_name.underscore}.index.description", default: inner_name)
            key :operationId, "find#{inner_name.pluralize}"
            key :produces, ['application/json']
            key :tags, [inner_name.underscore]
            parameter do
              key :name, :sort
              key :in, :query
              key :description, I18n.t('apicasso.sort.description',
                                      default: 'Parameters sorting splitted by `,` preffixed by `+` or `-` which translates into ascending or descending order')
              key :required, false
              key :type, :string
              key :collectionFormat, :json
            end
            parameter do
              key :name, :q
              key :in, :query
              key :description, I18n.t('apicasso.q.description',
                                      default: 'Records filtering by attribute and search query as affix. Usage: `?q[{attribute}{search_affix}]={matcher}`. All available search affixes are listed on: https://github.com/activerecord-hackery/ransack#search-matchers')
              key :required, false
              key :type, :json
            end
            parameter do
              key :name, :page
              key :in, :query
              key :description, I18n.t('apicasso.page.description',
                                      default: 'Records pagination paging, which offsets collection based on `params[:per_page]`')
              key :required, false
              key :type, :integer
            end
            parameter do
              key :name, :per_page
              key :in, :query
              key :description, I18n.t('apicasso.per_page.description',
                                      default: 'Records pagination size, which sets how many records will be rendered per request')
              key :required, false
              key :type, :integer
            end
            response 200 do
              key :description, I18n.t("activerecord.models.#{inner_name.underscore}.index.response",
                                      default: "#{inner_name} response, which include records matching current query and pagination metadata")
              schema do
                key :name, :total
                key :description, I18n.t('apicasso.total.description',
                                        default: 'Total records contained in current collection, as if there was no pagination.')
                key :required, true
                key :type, :integer
              end
              schema do
                key :name, :total_pages
                key :description, I18n.t('apicasso.total_pages.description',
                                        default: 'How many pages of data the current collection has.')
                key :required, true
                key :type, :integer
              end
              schema do
                key :name, :last_page
                key :description, I18n.t('apicasso.last_page.description',
                                        default: 'An indication if current request is the last to paginate in the current collection')
                key :required, true
                key :type, :boolean
              end
              schema do
                key :name, :previous_page
                key :description, I18n.t('apicasso.previous_page.description',
                                        default: "The link of the previous page for the current collection. It can be null if there isn't any")
                key :required, false
                key :type, :string
              end
              schema do
                key :name, :next_page
                key :description, I18n.t('apicasso.next_page.description',
                                        default: "The link of the next page for the current collection. It can be null if there isn't any")
                key :required, false
                key :type, :string
              end
              schema do
                key :name, :out_of_bounds
                key :description, I18n.t('apicasso.out_of_bounds.description',
                                        default: 'An indication if current request is out of pagination bounds for the current collection')
                key :required, true
                key :type, :boolean
              end
              schema do
                key :name, :offset
                key :description, I18n.t('apicasso.offset.description',
                                        default: 'How many records were offsetted from the collection to render the current page')
                key :required, true
                key :type, :integer
              end
              schema do
                key :name, :entries
                key :description, I18n.t('apicasso.entries.description',
                                        default: 'The records collection in the current pagination scope.')
                key :required, true
                key :type, :array
                items do
                  key :'$ref', "#{inner_name}".to_sym
                end
              end
            end
            response :default do
              key :description, I18n.t("activerecord.errors.models.#{inner_name.underscore}",
                                      default: "Unexpected error in #{inner_name}")
              schema do
                key :'$ref', :ErrorModel
              end
            end
          end
          operation :options do
            key :description, I18n.t("activerecord.models.#{inner_name.underscore}.schema.description",
                                    default: "#{inner_name} metadata information.")
            key :operationId, "schema#{inner_name.pluralize}"
            key :produces, ['application/json']
            key :tags, [inner_name.underscore]
            response 200 do
              key :description, I18n.t("activerecord.models.#{inner_name.underscore}.schema.response",
                                      default: "#{inner_name} metadata as a json with field names as keys and field types as values.")
              schema do
                key :'$ref', "#{inner_name}".to_sym
              end
            end
            response :default do
              key :description, I18n.t("activerecord.errors.models.#{inner_name.underscore}",
                                      default: "Unexpected error in #{inner_name}")
              schema do
                key :'$ref', :ErrorModel
              end
            end
          end
        end
      end
    end

    # Method that serves the generated Swagger JSON
    def index
      render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES).to_json
    end
  end
end
