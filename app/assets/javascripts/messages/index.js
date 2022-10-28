$(document).ready(function(){
    $("body")
        .on("submit", "#create_message_form", createMessage)
        .on("input", "p", updateEditForm)
        .on("submit", "#edit_message_form", submitEditMessageForm)
        .on("keypress", "p", triggerEditForm)
        .on("blur", "p", submitEditForm)
        .on("submit", ".delete_message_form", submitDeleteMessageForm)
        .on("submit", ".create_comment", submitCreateComment)
        .on("submit", "#edit_comment_form", submitEditCommentForm)
        .on("submit", ".delete_comment_form", submitDeleteCommentForm);
});

/**
* DOCU: To Submit Create message form
* Triggered by: .on("submit", "#create_message_form", createMessage)
*/
function createMessage() {
    let create_message_form = $(this)

    if(create_message_form.attr("data-is_processing") === "0"){
        create_message_form.attr("data-is_processing", "1");

        $.post(create_message_form.attr("action"), create_message_form.serialize(), function(message_data){
            if(message_data.status){
                create_message_form.find("textarea").val("");
                $('#messages-comments').prepend(message_data.result);
            }
            else{
                alert(message_data.error);
            }

            create_message_form.attr("data-is_processing", "0");
        }, "json");
    }

    return false;
}

/**
* DOCU: To Edit the text of the message or comment
* Triggered by: .on("input", "p", updateEditForm)
*/
function updateEditForm() {
    let p_tag = $(this);
    let text_type = (p_tag.attr("data-message_id") !== undefined) ? "message" : "comment";
    let edit_form = $("#edit_"+text_type+"_form");

    edit_form.find("input[name='"+text_type+"_id']").val(p_tag.attr("data-"+text_type+"_id"));
    edit_form.find("input[name='"+text_type+"']").val(p_tag.text());
}

/**
* DOCU: To trigger the submission of edit message/comment by pressing enter
* Triggered by: .on("keypress", "p", triggerEditForm)
*/
function triggerEditForm(event) {
    let p_tag = $(this);
    let keycode = (event.keyCode ? event.keyCode : event.which);

    if(keycode === 13){
        p_tag.blur();
    }
}

/**
* DOCU: To execute submit function of edit message/comment form
* Triggered by: .on("blur", "p", submitEditForm)
*/
function submitEditForm() {
    let text_type = ($(this).attr("data-message_id") !== undefined) ? "message" : "comment";
    $("#edit_"+text_type+"_form").submit();
}

/**
* DOCU: To submit edit message form.
* Triggered by: .on("submit", "#edit_message_form", submitEditMessageForm)
*/
function submitEditMessageForm() {
    let edit_message_form = $(this);

    if(edit_message_form.attr("data-is_processing") === "0"){
        edit_message_form.attr("data-is_processing", "1");

        $.post(edit_message_form.attr("action"), edit_message_form.serialize(), function(message_data){
            if(!message_data.status){
                alert(message_data.error);
            }

            edit_message_form.attr("data-is_processing", "0");
        }, "json");
    }

    return false;
}

/**
* DOCU: To submit delete message form.
* Triggered by: .on("submit", ".delete_message_form", submitDeleteMessageForm)
*/
function submitDeleteMessageForm() {
    let delete_message_form = $(this);

    if(confirm("Are you sure you want to delete this message?")){
        if(delete_message_form.attr("data-is_processing") === "0"){
            delete_message_form.attr("data-is_processing", "1");

            $.post(delete_message_form.attr("action"), delete_message_form.serialize(), function(message_data){
                if(message_data.status){
                    $("#messages-comments").find("#message_"+message_data.result).remove();
                }
                else{
                    alert(message_data.error);
                }

                delete_message_form.attr("data-is_processing", "0");
            }, "json");
        }
    }

    return false;
}

/**
* DOCU: To submit create comment form.
* Triggered by: .on("submit", ".create_comment", submitCreateComment)
*/
function submitCreateComment() {
    let create_comment_form = $(this)

    if(create_comment_form.attr("data-is_processing") === "0"){
        create_comment_form.attr("data-is_processing", "1");

        $.post(create_comment_form.attr("action"), create_comment_form.serialize(), function(comment_data){
            if(comment_data.status){
                create_comment_form.find("textarea").val("");
                $('#comment_list_'+comment_data.result.message_id).prepend(comment_data.result.html);
            }
            else{
                alert(comment_data.error);
            }

            create_comment_form.attr("data-is_processing", "0");
        }, "json");
    }

    return false;
}

/**
* DOCU: To submit edit comment form.
* Triggered by: .on("submit", "#edit_comment_form", submitEditCommentForm)
*/
function submitEditCommentForm() {
    let edit_comment_form = $(this);

    if(edit_comment_form.attr("data-is_processing") === "0"){
        edit_comment_form.attr("data-is_processing", "1");

        $.post(edit_comment_form.attr("action"), edit_comment_form.serialize(), function(comment_data){
            if(!comment_data.status){
                alert(comment_data.error);
            }

            edit_comment_form.attr("data-is_processing", "0");
        }, "json");
    }

    return false;
}

/**
* DOCU: To submit delete comment form.
* Triggered by: .on("submit", ".delete_comment_form", submitDeleteCommentForm)
*/
function submitDeleteCommentForm() {
    let delete_comment_form = $(this);

    if(confirm("Are you sure you want to delete this comment?")){
        if(delete_comment_form.attr("data-is_processing") === "0"){
            delete_comment_form.attr("data-is_processing", "1");

            $.post(delete_comment_form.attr("action"), delete_comment_form.serialize(), function(comment_data){
                if(comment_data.status){
                    $("#comment_"+comment_data.result).remove();
                }
                else{
                    alert(comment_data.error);
                }

                delete_comment_form.attr("data-is_processing", "0");
            }, "json");
        }
    }

    return false;
}