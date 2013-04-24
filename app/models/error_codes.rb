module ErrorCodes

  # Format of Errors
  # [0] = Error Code
  # [1] = Error Message
  # [2] = Friendly Help Text, Tips, etc.

  GLOBAL_ERRORS = {
      :not_authenticated => [-1, "You must Log In in to make comments.",
                             "You didn't authorize with Github yet, and that's required for making comments on this site."]
  }

  COMMENTING_ERRORS = {
      :no_page_id => [10, "A page_id is required!",
                    "The page_id was not supplied, this is an internal error."],

      :no_text => [11, "You have to have some text for your comment!",
                   "A comment without text is like a bird without wings."]

  }

end