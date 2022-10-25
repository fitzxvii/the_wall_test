Rails.application.routes.draw do

    # Users controller
    root to: "users#login_register"

    post "/register"    => "users#register"
    post "/login"       => "users#login"
    get "/logout"       => "users#logout"

    # Messages controller
    get "/main"             => "messages#index"

    post "/post_message"    => "messages#create_message"
    post "/update_message"  => "messages#update_message"
    post "/delete_message"  => "messages#delete_message"

    # Comments controller
    post "/post_comment"    => "comments#create_comment"
    post "/update_comment"  => "comments#update_comment"
    post "/delete_comment"  => "comments#delete_comment"
end
