class User < ApplicationRecord
    include :: QueryHelper

    # DOCU: Create the user based on information provided
    # Triggered by: UsersController.register
    # Requires: params - first_name, last_name, email, password, confirm_password
    # Returns: {:status => true/false, :result => {}, :error => error}
    def self.create_user(params)
        response_data = {:status => false, :result => {}, :error => nil}

        begin
            # Validate User Parameters
            validate_parameter = self.validate_user_form(params)

            if validate_parameter[:status]
                # Check email if existing on database
                get_user = query_select_one(["SELECT id FROM users WHERE email = ?", validate_parameter[:result][:email]])

                if !get_user
                    # Encrypt password in MD5 format
                    validate_parameter[:result][:password] = Digest::MD5.hexdigest(validate_parameter[:result][:password])

                    # Prepare query parameters for insert new user
                    query_params = validate_parameter[:result].values_at(:first_name, :last_name, :email, :password)

                    # Insert user record
                    insert_user_record = query_insert([
                        "INSERT INTO users (first_name, last_name, email, password, created_at, updated_at)
                        VALUES (?, ?, ?, ?, NOW(), NOW());", *query_params
                    ])

                    if insert_user_record > 0
                        response_data.merge!({
                            :status => true,
                            :result => {
                                :id => insert_user_record,
                                :first_name => validate_parameter[:result][:first_name],
                                :last_name  => validate_parameter[:result][:last_name]
                            }
                        })
                    else
                        raise "Insert new user record failed"
                    end
                else
                    response_data[:error] = {:email => "Email address already registered. Please try another one."}
                end
            else
                response_data[:error] = validate_parameter[:error]
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    # DOCU: Get the user information based on credentials for login
    # Triggered by: UsersController.login
    # Requires: params - email, password
    # Returns: {:status => true/false, :result => {}, :error => error}
    def self.authenticate_user(params)
        response_data = {:status => false, :result => {}, :error => nil}

        begin
            get_user = query_select_one([
                "SELECT id, first_name, last_name FROM users WHERE email = ? and password = ?;",
                params[:email], Digest::MD5.hexdigest(params[:password])
            ])

            if get_user.present?
                response_data[:status] = true
                response_data[:result] = OpenStruct.new(get_user)
            else
                response_data[:error] = "Email address or password is incorrect."
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        return response_data
    end

    private
        # DOCU: Get the user information based on credentials for login
        # Triggered by: self.create_user
        # Requires: user_form_params - first_name, last_name, email, password, confirm_password
        # Returns: {:status => true/false, :result => user_form_params, :error => {:first_name, :last_name, :email, :password, :confirm_password}}
        def self.validate_user_form(user_form_params)
            response_data = {:status => false, :result => {}, :error => {}}

            user_form_params.each do |key, value|
                # Check current key. If first name or last name, set key to :name to reuse checker for special keys.
                user_param_key = ['first_name', 'last_name'].include?(key) ? :name : key.to_sym

                # Validation for names. If they have special characters, store the error.
                response_data[:error][key] = "Name has Special Characters." if user_param_key == :name && (user_form_params[key] =~ /[@%^&!"\\\*\.,\-\:?\/\'=`{}()+_\]\|\[\><~;$#0-9]/)

                # Validation for email address. If email is not in correct format, store the error.
                response_data[:error][:email] = "Email Address not in correct format." if user_param_key == :email && !(user_form_params[:email] !=~ URI::MailTo::EMAIL_REGEXP)

                # Validation for password. If length is less than 8, store the error.
                response_data[:error][:password] = "Password too short. Need at least 8 characters" if user_param_key == :password && user_form_params[:password].length < 8

                # Validation for confirm password. If confirm password is not the same as first password, store the error.
                response_data[:error][:confirm_password] = "Password and confirm password are not the same" if user_param_key == :confirm_password && user_form_params[:confirm_password] != user_form_params[:password]
            end

            # If the error is empty, set status to true and return parameters
            if response_data[:error].empty?
                response_data[:status] = true
                response_data[:result] = user_form_params
            end

            return response_data
        end
end
