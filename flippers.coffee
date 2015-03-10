
after = (ms, fn)-> tid = setTimeout fn, ms; stop: -> clearTimeout tid
every = (ms, fn)-> iid = setInterval fn, ms; stop: -> clearInterval iid

do ($ = jQuery)->
	
	$Flipper = (part)->
		$new_flipper = $("<span class='flipper'>").text(part)
		$new_flipper.addClass "numerical" if part.match /^\d/
		$new_flipper
	
	$.fn.flippers = (text, splitter=" ")->
		
		parts = text.split splitter
		
		@each ->
			$container = $(@)
			
			# Match new parts with old flippers 
			$old_flippers = $container.children().not(".removed")
			$matched_flippers = $()
			matched_$flippers = for part in parts
				found_first = no
				$old_flippers.not($matched_flippers).filter (i, flipper)->
					return no if found_first
					matches = $(flipper).text() is part
					if matches
						$matched_flippers = $matched_flippers.add flipper
						found_first = yes
					matches
			
			# Remove non-matching flippers
			$old_flippers.not($matched_flippers).each (i, flipper)->
				$flipper = $(flipper)
					.removeClass "added"
					.addClass "removed"
				
				after 2000, ->
					$flipper.remove()
			
			# Add new flippers
			$current_flippers = for part, i in parts
				$old_flipper = matched_$flippers[i]
				$prev_flipper = matched_$flippers[i-1] if i > 0
				$next_flipper = matched_$flippers[i+1]
				
				$current_flipper = $old_flipper
				
				unless $old_flipper?.length
					$current_flipper = $new_flipper = $Flipper(part)
					
					# @TODO: utilize more information when deciding where to place new flippers
					if $next_flipper?.length
						$new_flipper.insertBefore($next_flipper)
					else if $prev_flipper?.length
						$new_flipper.insertAfter($prev_flipper)
					else if i is 0
						$new_flipper.prependTo($container)
					else
						$new_flipper.appendTo($container)
					
					$new_flipper.addClass "added"
					
				$current_flipper
			
			# Update the layout
			# @TODO: also relayout removed flippers
			$layout = $(@cloneNode(no)).insertBefore(@)
			
			$layed_out_flippers = for part, i in parts
				$Flipper(part).appendTo($layout)
			
			for part, i in parts
				$flipper = $current_flippers[i]
				$layed_out_flipper = $layed_out_flippers[i]
				console.error $flipper.text(), $layed_out_flipper.text() if $flipper.text() isnt $layed_out_flipper.text()
				# @TODO: allow transitions to occur uninterrupted by checking to see if it needs to move before moving it?
				$flipper.css
					left: $layed_out_flipper.position().left
					top: $layed_out_flipper.position().top
					width: $layed_out_flipper.width()
					height: $layed_out_flipper.height()
				.css
					position: "absolute"
			
			$layout.remove()
