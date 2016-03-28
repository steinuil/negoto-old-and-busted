get "/error/:err" do |err|
  case err
  when "no_board"
    @err = "No such board"
  when "no_thread"
    @err = "No such thread"
  when "no_subject"
    @err = "You can't start a thread without a subject"
  when "no_image"
    @err = "You can't start a thread without a file"
  when "no_comment"
    @err = "You can't post without both a comment and a picture"
  when "subject_too_long"
    @err = "Your subject is too long"
  when "name_too_long"
    @err = "Your name is too long"
  when "post_too_long"
    @err = "Your post is too long"
  when "cooldown"
    @err = "You must wait 15 seconds before posting again"
  when "thread_locked"
    @err = "You can't reply to this thread"
  end
  @title = "Error"

  @type = :error
  haml @type
end

not_found do
  @err = "404 not found"
  @title = "Error"

  @type = :error
  haml @type
end

