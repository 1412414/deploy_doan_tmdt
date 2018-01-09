module SessionHelper	
    def flash_class(key)
		case key
		when "login_error"
			"alert-danger"
		end
	end
end
