module ApplicationHelper
  def state_link_to(opts = {})
    state = opts[:state]

    message = if state 
      opts[:yes_text]
    else
      opts[:no_text]
    end
    
    html = <<-HTML
    <a href="#" data-remote="true" 
                data-yes-uri="#{opts[:yes_uri]}" 
                data-yes-text="#{opts[:yes_text]}" 
                data-no-uri="#{opts[:no_uri]}" 
                data-no-text="#{opts[:no_text]}"
                data-state="#{state}"
                onclick="App.updateState(this);" 
                class="btn btn-danger btn-xs" >
                #{message}
    </a>
    HTML
    
    html.html_safe
  end
end
