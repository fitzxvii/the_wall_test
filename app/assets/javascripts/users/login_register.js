$(document).ready(function(){
    $("body")
        .on("submit", "#register_form", submitRegisterForm)
        .on("submit", "#login_form", submitLoginForm)
        .on("focus", "p", function(){                                           /* To remove all errors message and error state of the input text after focus */
            $(this).find("input").removeClass("error");
            $(".error_msg").addClass("hidden");
        });
});

/**
* DOCU: To Submit Register form
* Triggered by: .on("submit", "#register_form", submitRegisterForm)
*/
function submitRegisterForm() {
    let register_form           = $(this);
    let email_input             = $("#register_email_input");
    let first_name_input        = $("#first_name_input");
    let last_name_input         = $("#last_name_input");
    let password_input          = $("#register_password_input");
    let confirm_password_input  = $("#confirm_password_input");

    if(register_form.attr("data-is_processing") === "0"){
        register_form.attr("data-is_processing", "1");

        $.post(register_form.attr("action"), register_form.serialize(), function(register_response){
            if(register_response.status){
                /** Proceed to the wall main page */
                window.location.href = "/main"
            }
            else{
                /** Set email input in error state if there is an error or value is missing */
                if(register_response.error.email || email_input.val() === ""){
                    email_input.addClass("error");
                    $("#register_email_error_msg").removeClass("hidden").text(register_response.error.email || "");
                }

                /** Set first name input in error state if there is an error or value is missing */
                if(register_response.error.first_name || first_name_input.val() === ""){
                    first_name_input.addClass("error");
                    $("#first_name_error_msg").removeClass("hidden").text(register_response.error.first_name || "");
                }

                /** Set last name input in error state if there is an error or value is missing */
                if(register_response.error.last_name || last_name_input.val() === ""){
                    last_name_input.addClass("error");
                    $("#last_name_error_msg").removeClass("hidden").text(register_response.error.last_name || "");
                }

                /** Set password input in error state if there is an error or value is missing */
                if(register_response.error.password || password_input.val() === ""){
                    password_input.addClass("error");
                    $("#register_password_error_msg").removeClass("hidden").text(register_response.error.password || "");
                }

                /** Set confirm password input in error state if there is an error or value is missing */
                if(register_response.error.confirm_password || confirm_password_input.val() === ""){
                    confirm_password_input.addClass("error");
                    $("#confirm_password_error_msg").removeClass("hidden").text(register_response.error.confirm_password || "");
                }

                /** Set alert for exception errors and the error is not about missing parameter */
                if(register_response.error.exception && !register_response.error.exception.match(/param/gi)){
                    alert(register_response.error.exception);
                }
            }

            register_form.attr("data-is_processing", "0");
        }, "json");
    }

    return false;
}

/**
* DOCU: To Submit Login form
* Triggered by: .on("submit", "#login_form", submitLoginForm)
*/
function submitLoginForm() {
    let login_form = $(this);

    if(login_form.attr("data-is_processing") === "0"){
        login_form.attr("data-is_processing", "1");

        $.post(login_form.attr("action"), login_form.serialize(), function(login_response){
            if(login_response.status){
                /** Proceed to the wall main page */
                window.location.href = "/main"
            }
            else{
                /** Set email and password to error state */
                $("#login_email_input").addClass("error");
                $("#login_password_input").addClass("error");

                /** Set error message if any and the error is not about missing parameter */
                if(login_response.error && !login_response.error.match(/param/gi)){
                    $("#login_error_msg").removeClass("hidden").text(login_response.error || "");
                }
            }
            login_form.attr("data-is_processing", "0");
        }, "json");
    }

    return false;
}