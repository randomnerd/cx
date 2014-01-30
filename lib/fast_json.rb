class FastJson
  def self.dump(rel)
    data = rel.pluck(*rel.json_fields).map do |attrs|
      jattrs = attrs.map do |a|
        a.kind_of?(ActiveSupport::TimeWithZone) ? a.iso8601 : a
      end
      Hash[rel.json_fields.zip(jattrs)]
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

  def self.raw_dump(rel, *fields)
    query = rel.select(rel.json_fields).arel
    MultiJson.dump(rel.connection.select_rows(query.to_sql))
  end
end
