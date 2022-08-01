require 'faraday_middleware'
require 'multi_json'
require 'active_model'
require 'tariff_jsonapi_parser'
require 'errors'

module ApiEntity
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    include Faraday
    include MultiJson

    attr_reader :resource_id, :attributes
    attr_writer :resource_type

    attr_accessor :casted_by

    delegate :relationships, to: :class

    def inspect
      attrs = if defined?(@attributes) && @attributes.any?
                attributes_for_inspect
              else
                instance_variables_for_inspect
              end

      inspection = attrs.any? ? attrs.join(', ') : 'not initialised'

      "#<#{self.class.name.presence || self.class} #{inspection}>"
    end

    def resource_path
      "/#{self.class.name.underscore.pluralize}/#{to_param}"
    end

    def to_param
      id
    end

    def resource_type
      @attributes['resource_type'] || self.class.name.underscore.singularize
    end
  end

  def initialize(attributes = {})
    attributes = HashWithIndifferentAccess.new(attributes)

    self.attributes = attributes
  end

  def resource_id=(resource_id)
    @resource_id ||= resource_id # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def attributes=(attributes = {})
    @attributes = attributes

    attributes.each do |name, value|
      if respond_to?(:"#{name}=")
        public_send(:"#{name}=", value)
      end
    end
  end

  def persisted?
    true
  end

private

  def attributes_for_inspect
    @attributes.except(*(relationships.to_a + [:casted_by]))
               .map { |k, v| "#{k}: #{v.inspect}" }
  end

  def instance_variables_for_inspect
    instance_variables.without(%i[@attributes @casted_by])
                      .map { |k| k.to_s.sub('@', '') }
                      .select(&method(:respond_to?))
                      .map { |k| "#{k}: #{public_send(k).inspect}" }
  end

  module ClassMethods
    delegate :get, :post, to: :api

    def relationships
      @relationships ||= superclass.include?(ApiEntity) ? superclass.relationships.dup : []
    end

    def find(id, opts = {})
      retries = 0
      begin
        resp = api.get("/#{name.pluralize.underscore}/#{id}", opts)
        new parse_jsonapi(resp)
      rescue Faraday::Error, UnparseableResponseError
        if retries < Rails.configuration.x.http.max_retry
          retries += 1
          retry
        else
          raise
        end
      end
    end

    def all(opts = {})
      collection(collection_path, opts)
    end

    def search(opts = {})
      collection("#{collection_path}/search", opts)
    end

    def collection(collection_path, opts = {})
      retries = 0
      begin
        resp = api.get(collection_path, opts)
        collection = parse_jsonapi(resp)
        collection = collection.map { |entry_data| new(entry_data) }
        collection = paginate_collection(collection, resp.body.dig('meta', 'pagination')) if resp.body.is_a?(Hash) && resp.body.dig('meta', 'pagination').present?
        collection
      rescue Faraday::Error, UnparseableResponseError
        if retries < Rails.configuration.x.http.max_retry
          retries += 1
          retry
        else
          raise
        end
      end
    end

    def has_one(association, opts = {})
      options = {
        class_name: association.to_s.singularize.classify,
        polymorphic: false,
      }.merge(opts)

      relationships << association

      attr_reader association.to_sym

      define_method("#{association}=") do |attributes|
        entity = if attributes.nil?
                   nil
                 else
                   class_name = if options[:polymorphic]
                                  attributes['resource_type'].classify
                                else
                                  options[:class_name]
                                end
                   class_name.constantize.new((attributes.presence || {}).merge(casted_by: self))
                 end

        instance_variable_set("@#{association}", entity)
      end
    end

    def has_many(association, opts = {})
      options = {
        class_name: association.to_s.singularize.classify,
        polymorphic: false,
      }.merge(opts)

      relationships << association

      define_method(association) do
        collection = instance_variable_get("@#{association}").presence || []
        collection = options[:wrapper].new(collection) if options[:wrapper]

        if options[:filter].present?
          collection.public_send(options[:filter])
        else
          collection
        end
      end

      define_method("#{association}=") do |data|
        data = data.presence || []

        collection = data.map do |attributes|
          class_name = if options[:polymorphic]
                         attributes['resource_type'].classify
                       else
                         options[:class_name]
                       end

          entity = class_name.constantize.new((attributes.presence || {}).merge(casted_by: self))

          if options[:presenter].present?
            options[:presenter].new(entity)
          else
            entity
          end
        end

        instance_variable_set("@#{association}", collection)
      end

      define_method("add_#{association.to_s.singularize}") do |entity|
        instance_variable_set("@#{association}", []) unless instance_variable_defined?("@#{association}")
        instance_variable_get("@#{association}").public_send('<<', entity)
      end
    end

    def enum(field, enum_config)
      enum_config.each do |method_name, value|
        define_method("#{method_name}?") do
          public_send(field).in?(value)
        end
      end
    end

    def paginate_collection(collection, pagination)
      Kaminari.paginate_array(
        collection,
        total_count: pagination['total_count'],
      ).page(pagination['page']).per(pagination['per_page'])
    end

    def collection_path(path = nil)
      return @collection_path if path.blank?

      @collection_path = path
    end

    def api
      TradeTariffFrontend::ServiceChooser.api_client
    end

    def parse_jsonapi(resp)
      TariffJsonapiParser.new(resp.body).parse
    rescue TariffJsonapiParser::ParsingError
      raise UnparseableResponseError, resp
    end
  end
end
