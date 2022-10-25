class MessagesController < ApplicationController
    # DOCU: The main page of The Wall
    # Triggered by: (GET) /main
    # Returns: @all_messages
    def index
        @all_messages = Message.get_all_messages[:result]
    end

    # DOCU: Create new message of the current user
    # Triggered by: (POST) /post_message
    # Session: session - user_id
    # Requires: params - message
    # Returns: {:status => true/false, :result => new_message_partial, :error => error}
    def create_message
        response_data = {:status => false, :result => {}, :error => nil}

        begin
            require_params = params.permit!.require(:message)

            if require_params.present?
                # Create message for current user session
                create_message = Message.create_message({:user_id => session[:user_id], :message => params[:message]})

                # If create message successful, add result to current list of messages
                if create_message[:status]
                    response_data[:status] = true
                    response_data[:result] = render_to_string :partial => "messages/partials/new_message_partial", :locals => {:id => create_message[:result][:id], :message => create_message[:result][:message]}
                else
                    response_data[:error] = create_message[:error]
                end
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        render :json => response_data
    end

    # DOCU: Update the message of the current user
    # Triggered by: (POST) /update_message
    # Session: session - user_id
    # Requires: params - message_id, message
    # Returns: {:status => true/false, :result => {}, :error => error}
    def update_message
        response_data = {:status => false, :result => {}, :error => nil}

        begin
            require_params = params.permit!.require([:message_id, :message])

            if require_params.present?
                update_message = Message.update_message({:user_id => session[:user_id], :message_id => params[:message_id], :message => params[:message]})
                response_data  = update_message
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        render :json => response_data
    end

    # DOCU: Delete the message of the current user
    # Triggered by: (POST) /delete_message
    # Session: session - user_id
    # Requires: params - message_id
    # Returns: {:status => true/false, :result => {}, :error => error}
    def delete_message
        response_data = {:status => false, :result => {}, :error => nil}

        begin
            require_params = params.permit!.require(:message_id)

            if require_params.present?
                delete_message = Message.delete_message({:user_id => session[:user_id], :message_id => params[:message_id]})
                response_data  = delete_message
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        render :json => response_data
    end
end
