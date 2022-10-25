class Message < ApplicationRecord
    include :: QueryHelper

    # DOCU: Fetch all the messages and their comments for main page
    # Triggered by: MessagesController.index
    # Returns: {:status => true/false, :result => all_messages, :error => error}
    def self.get_all_messages
        response_data = {:status => false, :result => {}, :error => nil }

        begin
            all_messages = query_select_all([
                "SELECT messages.id AS message_id, message_owner.id AS message_owner_id, CONCAT(message_owner.first_name, ' ', message_owner.last_name) AS message_owner_name, messages.message, messages.updated_at AS last_message_update_data,
                CASE
                    WHEN comments.id IS NOT NULL THEN JSON_ARRAYAGG(JSON_OBJECT('comment_id', comments.id, 'comment',  comments.comment, 'comment_owner_id', comment_owner.id, 'comment_owner_name', CONCAT(comment_owner.first_name, ' ', comment_owner.last_name), 'last_comment_update_date', comments.updated_at))
                    ELSE NULL
                END AS comments
                FROM messages
                INNER JOIN users AS message_owner ON message_owner.id = messages.user_id
                LEFT JOIN comments ON comments.message_id = messages.id
                LEFT JOIN users AS comment_owner ON comment_owner.id = comments.user_id
                GROUP BY messages.id
                ORDER BY messages.updated_at DESC;"
            ])

            if all_messages.present?
                response_data[:status] = true
                response_data[:result] = all_messages
            else
                response_data[:message] = "No message posted yet."
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    # DOCU: Insert new message of the current user to messages record
    # Triggered by: MessagesController.create_message
    # Requires: params - user_id, message
    # Returns: {:status => true/false, :result => {:id, :message}, :error => error}
    def self.create_message(params)
        response_data = {:status => false, :result => {}, :error => nil }

        begin
            new_message_id = query_insert([
                "INSERT INTO messages (user_id, message, created_at, updated_at)
                VALUES (? , ?, NOW(), NOW());", params[:user_id], params[:message]
            ])

            if new_message_id > 0
                response_data[:status] = true
                response_data[:result] = {:id => new_message_id, :message => params[:message]}
            else
                response_data[:error] = "Insert new message failed"
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    # DOCU: Update existing message of the current user
    # Triggered by: MessagesController.update_message
    # Requires: params - user_id, message_id, message
    # Returns: {:status => true/false, :result => {}, :error => error}
    def self.update_message(params)
        response_data = {:status => false, :result => {}, :error => nil }

        begin
            # Check if the current user is the owner of the message.
            message_to_edit = self.check_message_owner({:message_id => params[:message_id], :user_id => params[:user_id]})

            # If the owner of the message to edit is the current user, execute update message. Else, throw an error.
            if message_to_edit[:status]
                update_message = query_update(["UPDATE messages SET message = ?, updated_at = NOW() WHERE id = ?", params[:message], params[:message_id]])

                (update_message > 0) ? response_data[:status] = true : response_data[:error] = "Update message query execution failed."
            else
                raise message_to_edit[:error]
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    # DOCU: Delete selected message record of the current user
    # Triggered by: MessagesController.delete_message
    # Requires: params - user_id, message_id, message
    # Returns: {:status => true/false, :result => {}, :error => error}
    def self.delete_message(params)
        response_data = {:status => false, :result => {}, :error => nil }

        begin
            # Check if the current user is the owner of the message.
            message_to_delete = self.check_message_owner({:message_id => params[:message_id], :user_id => params[:user_id]})

            # If the owner of the message to edit is the current user, execute update message. Else, throw an error.
            if message_to_delete[:status]
                delete_message = query_delete(["DELETE FROM messages WHERE id = ?", params[:message_id]])

                if delete_message > 0
                    response_data[:status] = true
                    response_data[:result] = params[:message_id]
                else
                    response_data[:error] = "Delete message query execution failed."
                end
            else
                raise message_to_delete[:error]
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    private
        # DOCU: Check if the owner of the message is the current user before making alterations to the record
        # Triggered by: self.update_message, self.delete_message
        # Requires: params - user_id, message_id
        # Returns: {:status => true/false, :result => {}, :error => error}
        def self.check_message_owner(params)
            response_data = {:status => false, :result => {}, :error => nil }

            begin
                message_to_check = query_select_one(["SELECT id, user_id, message FROM messages WHERE id = ? AND user_id = ?;", params[:message_id], params[:user_id]])

                (message_to_check.present?) ? response_data[:status] = true : response_data[:error] = "The current user is not the owner of the message to edit."
            rescue Exception => ex
                response_data[:error] = ex
            end

            return response_data
        end
end