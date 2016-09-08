public extension <%= model.name %> {
    var itself: String { get { return "WHERE \(<%= model.name %>.tableName.unwrapped).\("id".unwrapped) = \(id)" } }

    func delete() {
        let deleteSQL = "DELETE FROM \(<%= model.name %>.tableName.unwrapped) \(itself)"
        executeSQL(deleteSQL)
    }

    <% model.properties_exclude_id.each do |property| %><%= """mutating func update(#{property.name} #{property.name}: #{property.type}) -> #{model.name} {
        return self.update([.#{property.name}: #{property.name}])
    }""" %>
    <% end %>
    mutating func update(attributes: [<%= model.name %>.Column: Any]) -> <%= model.name %> {
        var setSQL: [String] = []
        for (key, _) in attributes {
            switch key {
            <% model.properties_exclude_id.each do |property| %><%= """case .#{property.name}: setSQL.append(\"\\(key.unwrapped) = \\(#{property.name}#{property.is_optional? ? "?" : ""}.unwrapped)\")""" %>
            <% end %>default: break
            }
        }
        let updateSQL = "UPDATE \(<%= model.name %>.tableName.unwrapped) SET \(setSQL.joinWithSeparator(", ")) \(itself)"
        executeSQL(updateSQL) {
            for (key, value) in attributes {
                switch key {
                <% model.properties_exclude_id.each do |property| %><%= """case .#{property.name}: self.#{property.name} = value as#{property.is_optional? ? "?" : "!"} #{property.type_without_optional}""" %>
                <% end %>default: break
                }
            }
        }
        return self
    }
    var save: <%= model.name %> {
        mutating get {
            if let _ = <%= model.name %>.find(id) {
                update([<% column_values = model.properties.map do |property| %><% ".#{property.name}: #{property.name}" %><% end %><%= column_values.join(", ") %>])
            } else {
                <%= model.name %>.create(id<%= model.property_exclude_id_key_value_pairs %>)
            }
            return self
        }
    }
}