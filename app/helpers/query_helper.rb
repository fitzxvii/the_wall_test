module QueryHelper
    extend ActiveSupport::Concern
    module ClassMethods
        # DOCU: Select only one table record
        # Triggered by: Models
        # Requires: query_statement - SELECT
        # Returns: {}
		def query_select_one(query_statement)
            ActiveRecord::Base.connection.select_one(ActiveRecord::Base.send(:sanitize_sql_array, query_statement))
		end

        # DOCU: Select multiple table records
        # Triggered by: Models
        # Requires: sql_statement - SELECT
        # Returns: [{}, {}]
		def query_select_all(query_statement)
            ActiveRecord::Base.connection.exec_query(ActiveRecord::Base.send(:sanitize_sql_array, query_statement)).to_hash
        end

        # DOCU: Insert new table records
        # Triggered by: Models
        # Requires: query_statement - INSERT
        # Returns: ID
        def query_insert(query_statement)
            ActiveRecord::Base.connection.insert(ActiveRecord::Base.send(:sanitize_sql_array, query_statement))
        end

        # DOCU: Update table record/s
        # Triggered by: Models
        # Requires: query_statement - UPDATE
        # Returns: Affected rows count
        def query_update(query_statement)
            ActiveRecord::Base.connection.update(ActiveRecord::Base.send(:sanitize_sql_array, query_statement))
        end

        # DOCU: Delete table record/s
        # Triggered by: Queries from different models
        # Requires: query_statement - DELETE
        # Returns: Affected rows count
        def query_delete(query_statement)
            ActiveRecord::Base.connection.delete(ActiveRecord::Base.send(:sanitize_sql_array, query_statement))
        end
    end
end