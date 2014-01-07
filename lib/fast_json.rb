class FastJson
  def self.dump(relation, *fields)
    fields = relation.json_fields if fields.empty?
    raise 'You have to either provide fields parameter or define `json_fields` class method' unless fields.present?

    name_fields = fields.map do |field|
      field.kind_of?(String) ? field.split(' as ').last : field
    end

    data = relation.pluck(*fields).map do |attrs|
      Hash[name_fields.zip(attrs)]
    end

    hash = { relation.name.pluralize.underscore => data }
    Oj.dump hash
  end

  def self.raw_dump(relation, *fields)
    fields = relation.json_fields if fields.empty?
    raise 'You have to either provide fields parameter or define `json_fields` class method' unless fields.present?

    query = relation.select(fields).arel
    Oj.dump relation.connection.select_all(query).to_a
  end
end
