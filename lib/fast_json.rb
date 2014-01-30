[Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
  klass.class_eval do
    def to_json(opts = {})
      MultiJson::dump(self.as_json(opts), opts)
    end
  end
end

class FastJson
  def self.dump(rel)
    fields = rel.try(:json_fields) || rel.attribute_names
    sfields = fields.map { |f| "#{rel.klass.name.underscore.pluralize}.#{f}" }
    data = rel.pluck(*sfields).map do |attrs|
      jattrs = attrs.map do |a|
        a.kind_of?(ActiveSupport::TimeWithZone) ? a.iso8601 : a
      end
      Hash[fields.zip(jattrs)]
    end

    MultiJson.dump({ rel.name.pluralize.underscore => data })
  end

  def self.dump_one(obj, wrap = true)
    o = Object.const_get("#{obj.class.name}Serializer")
    data = o.new(obj, root: false)
  rescue
    data = obj
  ensure
    data = { obj.class.name.underscore.pluralize => [data] } if wrap
    return MultiJson.dump(data)
  end

  def self.raw_dump(rel)
    fields = rel.try(:json_fields) || rel.attribute_names
    fields.map! { |f| "#{rel.klass.name.underscore.pluralize}.#{f}" }
    query = rel.select(fields).arel
    MultiJson.dump(rel.connection.select_rows(query.to_sql))
  end
end
