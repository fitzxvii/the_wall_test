class UsersController < ApplicationController
    before_action :session_exists?, except: [:logout]

    # DOCU: The login-register page
    # Triggered by: (GET) /
    def login_register
    end

    # DOCU: Register the user based on form answered
    # Triggered by: (POST) /register
    # Requires: params - :first_name, :last_name, :email, :password, :confirm_password
    # Returns: {:status => true/false, :result => {}, :error => {:first_name, :last_name, :email, :password, :confirm_password, :exception}}
    def register
        response_data = {:status => false, :result => {}, :error => nil}

        begin
            # Check required parameters if given
            require_params = params.permit!.require([:first_name, :last_name, :email, :password, :confirm_password])

            if require_params.present?
                # Create create_user
                create_user = User.create_user(params)

                if create_user[:status]
                    # Set New User Session
                    set_session(create_user[:result])
                    response_data[:status] = true
                else
                    response_data[:error] = create_user[:error]
                end
            end
        rescue Exception => ex
            response_data[:error] = {:exception => ex}
        end

        render :json => response_data
    end

    # DOCU: Logins the user based on credenetial given
    # Triggered by: (POST) /login
    # Requires: params - :email, :password
    # Returns: {:status => true/false, :result => {}, :error => error}
    def login
        response_data = {:status => false, :result => {}, :error => nil}

        begin
            # Check required parameters if given
            require_params = params.permit!.require([:email, :password])

            if require_params.present?
                # Select user if present
                authenticate_user = User.authenticate_user(params)

                if authenticate_user[:status]
                    # Set New User Session
                    set_session(authenticate_user[:result])
                    response_data[:status] = true
                else
                    response_data[:error] = authenticate_user[:error]
                end
            end
        rescue Exception => ex
            response_data[:error] = ex
        end

        render :json => response_data
    end

    # DOCU: Log out the user on main page
    # Triggered by: (POST) /logout
    def logout
        reset_session
		redirect_to "/"
    end

    private
        # DOCU: Set the user session after login/signout
        # Triggered by: self.register, self.login
        # Requires: params - :id, :first_name, :last_name
        def set_session(user_data)
            session[:user_id] = user_data[:id]
            session[:first_name] = user_data[:first_name]
            session[:last_name] = user_data[:last_name]
        end

        # DOCU: Log out the user on main page
        # Triggered by: before_action
        def session_exists?
            redirect_to "/main" if session[:user_id].present?
        end
end
