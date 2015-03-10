

after = (ms, fn)-> tid = setTimeout fn, ms; stop: -> clearTimeout tid
every = (ms, fn)-> iid = setInterval fn, ms; stop: -> clearInterval iid

debug = (args...)-> console?.debug? args...

Notification = window.Notification ? window.mozNotification ? window.webkitNotification

class Countdown
	constructor: ->
		# every 150, =>
		# 	status = if @interval then "running" else if @paused then "paused" else "stopped"
		# 	console.info "Status: #{status}, elapsed: #{@elapsed_seconds}s / #{@total_seconds}s"
		# 	if @paused and @interval
		# 		console.warn "Paused while running!"
		
		@total_seconds = 0
		@elapsed_seconds = 0
		@paused = no
		
		@audio = new Audio
		@audio.src = "audio/breeeewrrwrrrrhrrmnyarrerew.mp3"
		
		@el = ($ "<div class='timer'>").appendTo "body"
		center = ($ "<center>").appendTo @el
		#@input = ($ "<textarea rows=1 class=time>").appendTo @el
		@input = ($ "<input class='time input'>").appendTo center
		@input.focus()
		@countdown = ($ "<div class='time countdown'>").appendTo center
		
		do resize = =>
			@el.css fontSize: @el.width() / 10
		
		($ window).on "resize", resize
		
		($ window).on "keydown", (e)=>
			debug e.keyCode
			unless document.activeElement.tagName.match /input|textarea/i
				debug "(no textarea active)"
				switch e.keyCode
					when 13, 32 # enter, space
						if @paused or @elapsed_seconds is 0
							if @isTimeUp()
								@reset()
							else
								@start()
						else
							@pause()
					when 8 # backspace
						if @isTimeUp()
							@reset()
						else
							@pause()
						@input.focus()
		
		@input.on "keydown", (e)=>
			return if e.ctrlKey or e.altKey or e.shiftKey
			
			was_running = @interval?
			@pause()
			
			@el.removeClass "error alarm"
			
			if e.keyCode is 13
				e.preventDefault()
				unless was_running
					total_time = @input.val() ? location.hash
					if total_time is "0" and location.hash isnt "0"
						@reset()
					else
						try
							@set total_time
							@start()
							location.hash = total_time
						catch e
							@el.addClass "error"
							console?.error? e
	
	update: ->
		text = juration.stringify @total_seconds - @elapsed_seconds
		@countdown.flippers text
		@input.val text
	
	set: (total_time)->
		@stop()
		debug "SET!", total_time
		@el.removeClass "error alarm"
		@elapsed_seconds = 0
		
		if typeof total_time is "number"
			@total_seconds = total_time
		else
			@total_seconds = juration.parse total_time
		
		@update()
		
		Notification.requestPermission()
		@stop_alarm()
	
	start: ->
		@stop()
		debug "START!"
		started_seconds = @elapsed_seconds
		started_time = Date.now()
		@interval = every 30, =>
			@elapsed_seconds = (Date.now() - started_time) / 1000 + started_seconds
			if @elapsed_seconds >= @total_seconds
				@alarm()
			else
				@update()
		@el.addClass "running"
	
	pause: ->
		debug "PAUSE!"
		@paused = yes
		@interval?.stop()
		@interval = null
		@el.removeClass "running alarm"
	
	stop: ->
		@pause()
		debug "STOP!"
		@paused = no
	
	reset: ->
		@set location.hash
		@input.focus()
	
	alarm: ->
		@stop()
		@elapsed_seconds = 0
		@input.val "0"
		
		@el.addClass "alarm"
		
		@audio.play()
		
		if Notification.permission is "granted"
			@notification = new Notification "Hey!",
				body: "The timer's up!"
				icon: "img/alarm.png"
			@notification.onclick = @notification.onclose = => @reset()
		else
			alert "Hey! The timer's up!"
			@reset()
	
	stop_alarm: ->
		@notification?.close()
		@audio.pause()
		@audio.currentTime = 0
	
	isTimeUp: ->
		@input.val() in ["0", ""]

c = new Countdown

set_from_hash = ->
	c.set location.hash
	c.start()

set_from_hash() if location.hash
($ window).on "hashchange", set_from_hash
