// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require google-code-prettify/prettify
//= require bootstrap

var num_comments = 0
var comments = null;

$(document).ready(function(){

	// Convert all <pre> tags into nice code blocks
	prettyPrint();
	
	$("#submit-comment").click(function(e){
		e.preventDefault();
		submitComment();
	});
});

function pullComments() {
	$.ajax({
    type: 'GET',
    url: '/api/pull_comments',
    data: { page: page },
    dataType: "json",
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    beforeSend: function(){

    },
    success: function(result) {
      console.log('pull_comments():success');
      console.log(result);

      if (result.success == false) {

      }
      else {
        num_comments = parseInt(result.num_comments);
				comments = result.comments;
      }

    },
    error: function() {

    },
    complete: function() {
      console.log('pull_comments():complete');
    } // complete:
  });
}
function validateComment() {
	comment_text = $("#comment_text").val();
	if (comment_text.length > 0) {
		return true;
	}
	return false;
}
function submitComment() {
	
	comment_text = $("#comment_text").val();
	
	if (validateComment) {
		$.ajax({
	    type: 'POST',
	    url: '/api/submit_comment',
	    data: { page: page, comment_text: comment_text },
	    dataType: "json",
	    headers: {
	      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
	    },
	    beforeSend: function(){

	    },
	    success: function(result) {
	      console.log('submit_comment():success');
	      console.log(result);

	      if (result.success == false) {

	      }
	      else {
	        
	      }

	    },
	    error: function() {

	    },
	    complete: function() {
	      console.log('submit_comment():complete');
	    } // complete:
	  });
	}
}