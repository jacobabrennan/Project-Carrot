driver
	var
		driver/focus // Currently Focused sub-driver.
		list/drivers // Convenient container of non-focused sub-drivers.
	proc
		focus(driver/new_driver)
			if(focus && hascall(focus, "blurred"))
				focus.blurred()
			focus = new_driver
			if(hascall(focus, "focused"))
				new_driver.focused()
		focused(){}
		blurred(){}
		command(command)
			var/break_chain = FALSE
			if(focus && hascall(focus, "command"))
				break_chain = focus.command(command)
			return break_chain
		/*handle_event: function (event){
			var break_chain = false;
			if(this.driver && this.driver.handle_event){
				break_chain = this.driver.handle_event(event);
			}
			return break_chain;
		},
		display: function (){
			var break_chain = false;
			if(this.driver && this.driver.display){
				break_chain = this.driver.display();
			}
			return break_chain;
		}*/