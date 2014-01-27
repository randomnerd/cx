class FastJson
  def self.name_fields(klass)
    klass.json_fields.map do |field|
      field.kind_of?(String) ? field.split(' as ').last : field
    end
  end

  def self.dump(rel)
    data = rel.pluck(*rel.json_fields).map do |attrs|
      Hash[FastJson.name_fields(rel).zip(attrs)]
    end

    JrJackson::Json.dump({ rel.name.pluralize.underscore => data })
  end

  def self.dump_one(obj, wrap = true)
    o = Object.const_get("#{obj.class.name}Serializer")
    data = o.new(obj, root: false)
  rescue
    data = obj.as_json(only: obj.class.try(:json_fields))
  ensure
    data = { obj.class.name.underscore.pluralize => [data] } if wrap
    return JrJackson::Json.dump(data)
  end

  def self.raw_dump(rel, *fields)
    query = rel.select(rel.json_fields).arel
    JrJackson::Json.dump(rel.connection.select_all(query).to_a)
  end
end
